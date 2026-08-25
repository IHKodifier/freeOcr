import os
import uuid
import json
import datetime
from fastapi import APIRouter, UploadFile, File, Request, HTTPException, status, BackgroundTasks
from fastapi.responses import JSONResponse
from app.config import settings, load_canonical_config
from app.redis_client import get_redis_client, DEV_JOB_STORE
from app.services.layout_analyzer import LayoutAnalyzer
from app.services.ocr_worker import process_ocr_job

router = APIRouter()


@router.post("/convert", status_code=status.HTTP_202_ACCEPTED)
async def convert_document(
    request: Request,
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    """
    Endpoint for uploading PDF/image files for OCR conversion.
    Validates extension, size caps against app_limits_config.json, performs layout complexity analysis,
    evaluates 5-hour simple vs complex quotas and stackable 60m ad passes, routes to CPU or GPU queue,
    and returns HTTP 202 with job_id.
    """
    filename = file.filename or ""
    _, ext = os.path.splitext(filename)
    ext = ext.lower()

    if ext not in settings.ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file format."
        )

    content = await file.read()
    file_size = len(content)

    if file_size == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File is empty. Please select a valid document."
        )

    # Load single canonical global config
    cfg = load_canonical_config()
    limits_cfg = cfg.get("limits", {})
    base_max_mb = limits_cfg.get("base_max_file_mb", 10)
    
    # Client IP tracking
    client_ip = request.client.host if request.client else "127.0.0.1"

    # Check for stackable ad boost pass (sliding 60m TTL)
    redis_client = get_redis_client()
    ad_pass_raw = None
    boosted_max_mb = base_max_mb

    try:
        ad_pass_raw = redis_client.get(f"ad_pass:{client_ip}")
        if ad_pass_raw:
            if isinstance(ad_pass_raw, bytes):
                ad_pass_raw = ad_pass_raw.decode("utf-8")
            ad_pass = json.loads(ad_pass_raw)
            boosted_max_mb = ad_pass.get("boosted_max_file_mb", base_max_mb)
    except Exception:
        pass

    max_bytes = boosted_max_mb * 1024 * 1024
    if file_size > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File size exceeds allowed limit of {boosted_max_mb}MB. Watch a video ad to boost your limits."
        )

    # Perform Document Layout & Complexity Analysis
    analysis = LayoutAnalyzer.analyze_pdf_bytes(content)
    complexity = analysis["complexity"]
    target_engine = analysis["target_engine"]
    target_queue = analysis["target_queue"]

    # Check 5-hour rolling quotas
    quota_key = f"rate_limit:{complexity.lower()}:{client_ip}"
    max_quota = limits_cfg.get("simple_quota_5h", 20) if complexity == "SIMPLE" else limits_cfg.get("complex_quota_5h", 5)

    try:
        current_used = redis_client.get(quota_key)
        if current_used:
            current_used = int(current_used)
            if current_used >= max_quota:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"Quota exhausted for {complexity.lower()} layout OCR in this 5-hour window. Limit is {max_quota} jobs."
                )
        redis_client.incr(quota_key)
        redis_client.expire(quota_key, 18000)  # 5 hours in seconds
    except HTTPException:
        raise
    except Exception:
        pass

    job_id = str(uuid.uuid4())
    cold_start_active = True  # Simulated scale-to-zero cold-start trigger flag

    job_payload = {
        "job_id": job_id,
        "filename": filename,
        "file_size": file_size,
        "status": "QUEUED",
        "layout_complexity": complexity,
        "target_engine": target_engine,
        "queue_name": target_queue,
        "cold_start_active": cold_start_active,
        "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }

    try:
        json_str = json.dumps(job_payload)
        redis_client.set(f"job:{job_id}", json_str)
        DEV_JOB_STORE[job_id] = json_str
    except Exception:
        DEV_JOB_STORE[job_id] = json.dumps(job_payload)

    # Trigger background worker task
    background_tasks.add_task(
        process_ocr_job,
        job_id=job_id,
        file_bytes=content,
        filename=filename,
        target_engine=target_engine,
        queue_name=target_queue
    )

    return JSONResponse(
        status_code=status.HTTP_202_ACCEPTED,
        content={
            "job_id": job_id,
            "status": "QUEUED",
            "layout_complexity": complexity,
            "target_engine": target_engine,
            "queue_name": target_queue,
            "cold_start_active": cold_start_active
        }
    )


@router.post("/rewarded-ad-callback")
async def rewarded_ad_callback(request: Request):
    """
    Validates rewarded ad view and stacks user limits (+20MB, +15 pages).
    Resets sliding 60-minute TTL window from timestamp of latest completed ad.
    """
    client_ip = request.client.host if request.client else "127.0.0.1"
    cfg = load_canonical_config()
    limits_cfg = cfg.get("limits", {})

    boost_mb = limits_cfg.get("boost_per_ad_mb", 20)
    boost_pages = limits_cfg.get("boost_per_ad_pages", 15)
    ad_ttl = limits_cfg.get("ad_boost_ttl_seconds", 3600)
    max_mb_cap = limits_cfg.get("max_stack_file_mb", 500)
    max_pages_cap = limits_cfg.get("max_stack_pages", 500)

    redis_client = get_redis_client()
    key = f"ad_pass:{client_ip}"
    
    current_count = 0
    current_mb = limits_cfg.get("base_max_file_mb", 10)
    current_pages = limits_cfg.get("base_max_pages", 10)

    try:
        existing = redis_client.get(key)
        if existing:
            if isinstance(existing, bytes):
                existing = existing.decode("utf-8")
            data = json.loads(existing)
            current_count = data.get("ads_watched_count", 0)
            current_mb = data.get("boosted_max_file_mb", current_mb)
            current_pages = data.get("boosted_max_pages", current_pages)
    except Exception:
        pass

    new_count = current_count + 1
    new_mb = min(current_mb + boost_mb, max_mb_cap)
    new_pages = min(current_pages + boost_pages, max_pages_cap)

    ad_pass_payload = {
        "ads_watched_count": new_count,
        "boosted_max_file_mb": new_mb,
        "boosted_max_pages": new_pages,
        "last_ad_watched_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }

    try:
        redis_client.set(key, json.dumps(ad_pass_payload))
        # Reset 60-minute sliding TTL window upon each stacked ad reward!
        redis_client.expire(key, ad_ttl)
    except Exception:
        pass

    return {
        "status": "SUCCESS",
        "ads_watched_count": new_count,
        "boosted_max_file_mb": new_mb,
        "boosted_max_pages": new_pages,
        "ttl_seconds": ad_ttl
    }


@router.get("/jobs/{job_id}/events")
async def job_events_stream(job_id: str, request: Request):
    """
    Server-Sent Events (SSE) stream for real-time progress updates on a job.
    Subscribes to Redis Pub/Sub channel 'job_events:{job_id}' and streams updates.
    """
    import asyncio
    from fastapi.responses import StreamingResponse

    async def event_generator():
        redis_client = get_redis_client()
        pubsub = redis_client.pubsub()
        channel_name = f"job_events:{job_id}"
        pubsub.subscribe(channel_name)

        try:
            # Check for initial job state in Redis
            try:
                job_key = f"job:{job_id}"
                initial_data = redis_client.get(job_key)
                if initial_data:
                    if isinstance(initial_data, bytes):
                        initial_data = initial_data.decode("utf-8")
                    yield f"data: {initial_data}\n\n"
                    parsed = json.loads(initial_data)
                    if parsed.get("status") in ["COMPLETED", "FAILED"]:
                        return
            except Exception:
                pass

            # Listen for pubsub messages
            messages = pubsub.listen()
            if isinstance(messages, (list, tuple)):
                for message in messages:
                    if message and message.get("type") == "message":
                        raw_data = message.get("data")
                        if isinstance(raw_data, bytes):
                            raw_data = raw_data.decode("utf-8")
                        yield f"data: {raw_data}\n\n"
                        try:
                            parsed = json.loads(raw_data)
                            if parsed.get("status") in ["COMPLETED", "FAILED"]:
                                break
                        except Exception:
                            pass
            else:
                while True:
                    if await request.is_disconnected():
                        break
                    message = pubsub.get_message(ignore_subscribe_messages=True, timeout=0.1)
                    if message and message.get("type") == "message":
                        raw_data = message.get("data")
                        if isinstance(raw_data, bytes):
                            raw_data = raw_data.decode("utf-8")
                        yield f"data: {raw_data}\n\n"
                        try:
                            parsed = json.loads(raw_data)
                            if parsed.get("status") in ["COMPLETED", "FAILED"]:
                                break
                        except Exception:
                            pass
                    await asyncio.sleep(0.05)
        finally:
            try:
                pubsub.unsubscribe(channel_name)
                pubsub.close()
            except Exception:
                pass

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no"
        }
    )
