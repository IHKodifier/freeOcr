import json
import asyncio
from fastapi import APIRouter, Request, HTTPException, status
from fastapi.responses import StreamingResponse
from app.redis_client import get_redis_client, DEV_JOB_STORE

router = APIRouter()


@router.get("/{job_id}/events", response_class=StreamingResponse)
async def stream_job_events(job_id: str, request: Request):
    """
    Real-time Server-Sent Events (SSE) progress streaming endpoint.
    Subscribes to Redis pub/sub channel job_events:{job_id} and streams
    page OCR conversion progress to the client.
    """
    redis_client = get_redis_client()
    job_data_bytes = None
    try:
        job_data_bytes = redis_client.get(f"job:{job_id}")
    except Exception:
        job_data_bytes = None

    if not job_data_bytes and job_id in DEV_JOB_STORE:
        job_data_bytes = DEV_JOB_STORE[job_id]

    if not job_data_bytes:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found or expired."
        )

    async def event_generator():
        pubsub = None
        try:
            pubsub = redis_client.pubsub()
            pubsub.subscribe(f"job_events:{job_id}")
        except Exception:
            pubsub = None

        # Send initial connection event if cached job state exists
        if job_data_bytes:
            try:
                data_str = job_data_bytes.decode("utf-8") if isinstance(job_data_bytes, bytes) else str(job_data_bytes)
                initial_payload = json.loads(data_str)
                yield f"data: {json.dumps(initial_payload)}\n\n"
                if initial_payload.get("status") in ("COMPLETED", "FAILED"):
                    return
            except Exception:
                pass

        if pubsub is not None:
            try:
                messages = pubsub.listen()
                if isinstance(messages, (list, tuple)):
                    for message in messages:
                        if message and message.get("type") == "message":
                            raw_data = message.get("data")
                            data_str = raw_data.decode("utf-8") if isinstance(raw_data, bytes) else str(raw_data)
                            yield f"data: {data_str}\n\n"
                            try:
                                parsed = json.loads(data_str)
                                if parsed.get("status") in ("COMPLETED", "FAILED"):
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
                            data_str = raw_data.decode("utf-8") if isinstance(raw_data, bytes) else str(raw_data)
                            yield f"data: {data_str}\n\n"
                            try:
                                parsed = json.loads(data_str)
                                if parsed.get("status") in ("COMPLETED", "FAILED"):
                                    break
                            except Exception:
                                pass
                        await asyncio.sleep(0.05)
            finally:
                try:
                    pubsub.unsubscribe(f"job_events:{job_id}")
                    pubsub.close()
                except Exception:
                    pass

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
