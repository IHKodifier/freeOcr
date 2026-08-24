import os
import uuid
import json
import datetime
from fastapi import APIRouter, UploadFile, File, Request, HTTPException, status
from fastapi.responses import JSONResponse
from app.config import settings
from app.redis_client import get_redis_client

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
        redis_client.set(f"job:{job_id}", json.dumps(job_payload))
    except Exception:
        # Fallback in case Redis fails locally in test/dev
        pass

    return JSONResponse(
        status_code=status.HTTP_202_ACCEPTED,
        content={"job_id": job_id, "status": "QUEUED"}
    )
