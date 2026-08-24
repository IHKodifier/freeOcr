import os
import uuid
import json
import datetime
from fastapi import APIRouter, UploadFile, File, Request, HTTPException, status
from fastapi.responses import JSONResponse
from app.config import settings
from app.redis_client import get_redis_client, DEV_JOB_STORE

router = APIRouter()


@router.post("/convert", status_code=status.HTTP_202_ACCEPTED)
async def convert_document(
    request: Request,
    file: UploadFile = File(...)
):
    """
    Endpoint for uploading PDF/image files for OCR conversion.
    Validates extension, file size, empty content, increments IP rate limit,
    stores job metadata in Redis, and returns HTTP 202 with job_id.
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

    max_bytes = settings.FREE_TIER_MAX_FILE_MB * 1024 * 1024
    if file_size > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File size exceeds free tier limit of {settings.FREE_TIER_MAX_FILE_MB}MB."
        )

    # Client IP and Rate Limit tracking
    client_ip = request.client.host if request.client else "127.0.0.1"
    job_id = str(uuid.uuid4())

    try:
        redis_client = get_redis_client()
        redis_client.incr(f"ip_limit:{client_ip}")

        job_payload = {
            "job_id": job_id,
            "filename": filename,
            "file_size": file_size,
            "status": "QUEUED",
            "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        }
        json_str = json.dumps(job_payload)
        redis_client.set(f"job:{job_id}", json_str)
        DEV_JOB_STORE[job_id] = json_str
    except Exception:
        job_payload = {
            "job_id": job_id,
            "filename": filename,
            "file_size": file_size,
            "status": "QUEUED",
            "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        }
        DEV_JOB_STORE[job_id] = json.dumps(job_payload)

    return JSONResponse(
        status_code=status.HTTP_202_ACCEPTED,
        content={"job_id": job_id, "status": "QUEUED"}
    )


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

