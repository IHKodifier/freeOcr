import json
import asyncio
from typing import AsyncGenerator
from fastapi import APIRouter, HTTPException, status
from fastapi.responses import StreamingResponse
from app.redis_client import get_redis_client

router = APIRouter()


@router.get("/{job_id}/events", response_class=StreamingResponse)
async def stream_job_events(job_id: str):
    """
    Real-time Server-Sent Events (SSE) progress streaming endpoint.
    Subscribes to Redis pub/sub channel job_events:{job_id} and streams
    page OCR conversion progress to the client.
    """
    redis_client = get_redis_client()
    job_data_bytes = redis_client.get(f"job:{job_id}")

    if not job_data_bytes:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found or expired."
        )

    def event_generator():
        pubsub = redis_client.pubsub()
        pubsub.subscribe(f"job_events:{job_id}")

        # Send initial connection event
        try:
            initial_payload = json.loads(job_data_bytes.decode("utf-8"))
            yield f"data: {json.dumps(initial_payload)}\n\n"
        except Exception:
            pass

        try:
            for message in pubsub.listen():
                if message.get("type") == "message":
                    raw_data = message.get("data")
                    if isinstance(raw_data, bytes):
                        data_str = raw_data.decode("utf-8")
                    else:
                        data_str = str(raw_data)

                    yield f"data: {data_str}\n\n"

                    # Parse status and terminate stream if job finished
                    try:
                        parsed = json.loads(data_str)
                        job_status = parsed.get("status")
                        if job_status in ("COMPLETED", "FAILED"):
                            break
                    except Exception:
                        pass
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
