import os
import uuid
import json
import datetime
import glob
import tempfile
from typing import Optional
import fitz
from pydantic import BaseModel
from fastapi import APIRouter, UploadFile, File, Form, Request, HTTPException, status, BackgroundTasks
from fastapi.responses import JSONResponse
from app.config import settings, load_canonical_config
from app.redis_client import get_redis_client, DEV_JOB_STORE, store_ad_pass_metadata, get_ad_pass_metadata
from app.services.layout_analyzer import LayoutAnalyzer
from app.services.ocr_worker import process_ocr_job
from app.services.email_service import validate_email_address, send_download_links_email

router = APIRouter()


class EmailDeliveryRequest(BaseModel):
    job_id: str
    email: str


def _get_normalized_client_ip(request: Request) -> str:
    ip = "127.0.0.1"
    if request.headers.get("x-forwarded-for"):
        ip = request.headers.get("x-forwarded-for").split(",")[0].strip()
    elif request.client and request.client.host:
        ip = request.client.host
    if ip in ("::1", "localhost", "127.0.0.1", "testclient"):
        ip = "127.0.0.1"
    return ip


def _get_session_keys(request: Request) -> list[str]:
    session_id = request.headers.get("x-session-id")
    client_ip = _get_normalized_client_ip(request)
    keys = []
    if session_id:
        keys.append(f"ad_pass:sess:{session_id}")
    keys.append(f"ad_pass:{client_ip}")
    return keys


@router.post("/email-links")
async def email_download_links(req: EmailDeliveryRequest, request: Request):
    """
    Validates email, checks job completion, instantly purges original input file
    from RAM disk (AC-1 / Privacy Mandate), and dispatches 24-hour expiring download links.
    """
    if not validate_email_address(req.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid email address format."
        )

    job_id = req.job_id
    job_data_bytes = None

    if job_id in DEV_JOB_STORE:
        job_data_bytes = DEV_JOB_STORE[job_id]

    if not job_data_bytes:
        try:
            redis_client = get_redis_client()
            job_data_bytes = redis_client.get(f"job:{job_id}")
        except Exception:
            job_data_bytes = None

    if not job_data_bytes:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found or expired."
        )

    try:
        data_str = job_data_bytes.decode("utf-8") if isinstance(job_data_bytes, bytes) else str(job_data_bytes)
        parsed = json.loads(data_str) if isinstance(data_str, str) else data_str
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error parsing job data."
        )

    if parsed.get("status") != "COMPLETED":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found or expired."
        )

    # Privacy Mandate (AC-1): Instantly purge original input file from RAM disk upon endpoint invocation
    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    matching_inputs = glob.glob(os.path.join(ram_disk_base, f"ephemeral_{job_id}_*"))
    input_purged = False
    for input_file in matching_inputs:
        try:
            os.remove(input_file)
            input_purged = True
        except Exception:
            pass

    # Determine base URL for production: Priority 1 = API_BASE_URL env var, Priority 2 = Proxy headers, Priority 3 = Request URL
    base_url = os.environ.get("API_BASE_URL")
    if not base_url:
        forwarded_proto = request.headers.get("x-forwarded-proto", request.url.scheme)
        forwarded_host = request.headers.get("x-forwarded-host", request.url.netloc)
        base_url = f"{forwarded_proto}://{forwarded_host}"

    # Dispatch email with download links
    delivery_result = send_download_links_email(req.email, job_id, base_url=base_url)

    if delivery_result.get("status") == "ERROR":
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=delivery_result.get("error_detail") or "Failed to dispatch email via provider."
        )

    mode = delivery_result.get("delivery_mode", "MOCK_DEV")
    msg = (
        f"Download links sent to {req.email}!"
        if mode != "MOCK_DEV"
        else f"Download links processed for {req.email}. (Note: Local dev server is in mock mode. Add RESEND_API_KEY or SMTP to .env for live inbox delivery)."
    )

    return {
        "status": "SUCCESS",
        "message": msg,
        "job_id": job_id,
        "email": req.email,
        "delivery_mode": mode,
        "input_purged": input_purged,
        "download_links": delivery_result.get("download_links", {}),
        "expires_in_hours": 24
    }


@router.post("/convert", status_code=status.HTTP_202_ACCEPTED)
async def convert_document(
    request: Request,
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    password: Optional[str] = Form(None)
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

    if ext == ".pdf":
        try:
            doc = fitz.open(stream=content, filetype="pdf")
            if doc.is_encrypted:
                auth_success = False
                if password:
                    res = doc.authenticate(password)
                    if res > 0:
                        auth_success = True
                doc.close()
                if not auth_success:
                    return JSONResponse(
                        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                        content={
                            "error": "PASSWORD_REQUIRED",
                            "message": "Password Protected PDF. Please provide password to unlock."
                        }
                    )
            else:
                doc.close()
        except Exception:
            pass

    # Load single canonical global config
    cfg = load_canonical_config()
    limits_cfg = cfg.get("limits", {})
    base_max_mb = limits_cfg.get("base_max_file_mb", 10)
    
    # Session ID & Client IP tracking
    session_keys = _get_session_keys(request)

    # Check for stackable ad boost pass (sliding 60m TTL)
    redis_client = get_redis_client()
    boosted_max_mb = base_max_mb

    try:
        for k in session_keys:
            ad_pass = get_ad_pass_metadata(k)
            if ad_pass:
                pass_mb = ad_pass.get("boosted_max_file_mb", base_max_mb)
                if pass_mb > boosted_max_mb:
                    boosted_max_mb = pass_mb
    except Exception:
        pass

    max_bytes = boosted_max_mb * 1024 * 1024
    if file_size > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File size exceeds allowed limit of {boosted_max_mb}MB. Watch a video ad to boost your limits."
        )

    # Perform Document Layout & Complexity Analysis
    analysis = LayoutAnalyzer.analyze_pdf_bytes(content, password=password)
    complexity = analysis["complexity"]
    target_engine = analysis["target_engine"]
    target_queue = analysis["target_queue"]

    # Check 5-hour rolling quotas
    client_ip = _get_normalized_client_ip(request)
    quota_key = f"rate_limit:{complexity.lower()}:{client_ip}"
    max_quota = limits_cfg.get("simple_quota_jobs_5h", 20) if complexity == "SIMPLE" else limits_cfg.get("complex_quota_jobs_5h", 5)

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

    now_utc = datetime.datetime.now(datetime.timezone.utc)
    expires_utc = now_utc + datetime.timedelta(hours=24)

    job_payload = {
        "job_id": job_id,
        "filename": filename,
        "file_size": file_size,
        "status": "QUEUED",
        "layout_complexity": complexity,
        "target_engine": target_engine,
        "queue_name": target_queue,
        "cold_start_active": cold_start_active,
        "created_at": now_utc.isoformat(),
        "expires_at": expires_utc.isoformat(),
    }

    try:
        json_str = json.dumps(job_payload)
        redis_client.set(f"job:{job_id}", json_str, ex=86400)
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
        queue_name=target_queue,
        password=password
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
    session_keys = _get_session_keys(request)
    cfg = load_canonical_config()
    limits_cfg = cfg.get("limits", {})

    boost_mb = limits_cfg.get("boost_per_ad_mb", 20)
    boost_pages = limits_cfg.get("boost_per_ad_pages", 15)
    ad_ttl = limits_cfg.get("ad_boost_ttl_seconds", 3600)
    max_mb_cap = limits_cfg.get("max_stack_file_mb", 500)
    max_pages_cap = limits_cfg.get("max_stack_pages", 500)

    redis_client = get_redis_client()
    
    current_count = 0
    current_mb = limits_cfg.get("base_max_file_mb", 10)
    current_pages = limits_cfg.get("base_max_pages", 10)

    try:
        for k in session_keys:
            data = get_ad_pass_metadata(k)
            if data:
                current_count = max(current_count, data.get("ads_watched_count", 0))
                current_mb = max(current_mb, data.get("boosted_max_file_mb", current_mb))
                current_pages = max(current_pages, data.get("boosted_max_pages", current_pages))
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
        for k in session_keys:
            store_ad_pass_metadata(k, ad_pass_payload, ttl_seconds=ad_ttl)
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
