import os
import glob
import tempfile
import json
import asyncio
import datetime
from fastapi import APIRouter, Request, HTTPException, status
from fastapi.responses import StreamingResponse, Response, JSONResponse
from app.redis_client import get_redis_client, DEV_JOB_STORE
from app.services.pdf_composer import get_searchable_pdf

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
        else:
            # Fallback for local development when Redis is unavailable
            last_status = None
            while True:
                if await request.is_disconnected():
                    break
                job_raw = DEV_JOB_STORE.get(job_id)
                if job_raw:
                    try:
                        parsed = json.loads(job_raw) if isinstance(job_raw, str) else job_raw
                        curr_status = parsed.get("status")
                        curr_page = parsed.get("current_page")
                        state_key = f"{curr_status}:{curr_page}"
                        if state_key != last_status:
                            last_status = state_key
                            yield f"data: {json.dumps(parsed)}\n\n"
                            if curr_status in ("COMPLETED", "FAILED"):
                                break
                    except Exception:
                        pass
                await asyncio.sleep(0.2)


    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/{job_id}/preview")
async def get_job_preview(job_id: str):
    """
    Returns extracted text blocks and page layout metadata for an OCR job.
    Returns 404 if job_id is expired or invalid.
    """
    job_data_bytes = None

    # Check in-memory DEV_JOB_STORE first for immediate dev updates
    if job_id in DEV_JOB_STORE:
        job_data_bytes = DEV_JOB_STORE[job_id]

    if not job_data_bytes: 
        try:
            redis_client = get_redis_client()
            job_data_bytes = redis_client.get(f"job:{job_id}")
        except Exception:
            job_data_bytes = None

    if not job_data_bytes:
        return JSONResponse(
            status_code=status.HTTP_410_GONE,
            content={
                "detail": "Download link expired.",
                "expired_at": None
            }
        )


    try:
        data_str = job_data_bytes.decode("utf-8") if isinstance(job_data_bytes, bytes) else str(job_data_bytes)
        parsed = json.loads(data_str) if isinstance(data_str, str) else data_str
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error parsing job preview data."
        )

    return {
        "job_id": job_id,
        "filename": parsed.get("filename", ""),
        "status": parsed.get("status", "UNKNOWN"),
        "total_pages": parsed.get("total_pages", 0),
        "pages": parsed.get("pages", []),
        "output_pdf_token": parsed.get("output_pdf_token")
    }


@router.get("/{job_id}/download/{format}")
async def download_job_file(job_id: str, format: str):
    """
    1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).
    Streams requested document format, and immediately unlinks/purges
    the original input file from RAM disk upon download stream initiation (AC-1).
    """
    fmt = format.lower().strip()
    if fmt not in ("pdf", "txt", "md"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported format. Choose pdf, txt, or md."
        )

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
        return JSONResponse(
            status_code=status.HTTP_410_GONE,
            content={
                "detail": "Download link expired.",
                "expired_at": None
            }
        )

    try:
        data_str = job_data_bytes.decode("utf-8") if isinstance(job_data_bytes, bytes) else str(job_data_bytes)
        parsed = json.loads(data_str) if isinstance(data_str, str) else data_str
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error parsing job data."
        )

    # Check 24-hour expiration timestamp if present in job metadata
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    expires_at_str = parsed.get("expires_at")
    if expires_at_str:
        try:
            exp_dt = datetime.datetime.fromisoformat(expires_at_str)
            if exp_dt.tzinfo is None:
                exp_dt = exp_dt.replace(tzinfo=datetime.timezone.utc)
            if now_utc > exp_dt:
                return JSONResponse(
                    status_code=status.HTTP_410_GONE,
                    content={
                        "detail": "Download link expired.",
                        "expired_at": expires_at_str
                    }
                )
        except Exception:
            pass
    elif parsed.get("created_at"):
        try:
            created_dt = datetime.datetime.fromisoformat(parsed["created_at"])
            if created_dt.tzinfo is None:
                created_dt = created_dt.replace(tzinfo=datetime.timezone.utc)
            exp_dt = created_dt + datetime.timedelta(hours=24)
            if now_utc > exp_dt:
                return JSONResponse(
                    status_code=status.HTTP_410_GONE,
                    content={
                        "detail": "Download link expired.",
                        "expired_at": exp_dt.isoformat()
                    }
                )
        except Exception:
            pass

    if parsed.get("status") != "COMPLETED":
        return JSONResponse(
            status_code=status.HTTP_410_GONE,
            content={
                "detail": "Download link expired.",
                "expired_at": expires_at_str
            }
        )

    filename = parsed.get("filename", "document")
    filename_stem = os.path.splitext(filename)[0] or "document"

    # Immediately purge ephemeral input file from RAM disk (AC-1 / Privacy Mandate)
    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    matching_inputs = glob.glob(os.path.join(ram_disk_base, f"ephemeral_{job_id}_*"))
    for input_file in matching_inputs:
        try:
            os.remove(input_file)
        except Exception:
            pass

    if fmt == "pdf":
        output_token = parsed.get("output_pdf_token")
        pdf_bytes = get_searchable_pdf(output_token) if output_token else None
        if not pdf_bytes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Searchable PDF output not found or expired."
            )
        out_filename = f"{filename_stem}_searchable.pdf"
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"'
            }
        )

    pages = parsed.get("pages", [])
    if fmt == "txt":
        txt_parts = []
        for page in pages:
            page_text = page.get("text", "").strip()
            if page_text:
                txt_parts.append(page_text)
        compiled_txt = "\n\n".join(txt_parts)
        out_filename = f"{filename_stem}_extracted.txt"
        return Response(
            content=compiled_txt.encode("utf-8"),
            media_type="text/plain; charset=utf-8",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"'
            }
        )

    elif fmt == "md":
        md_parts = []
        for page in pages:
            page_num = page.get("page_number", 1)
            page_text = page.get("text", "").strip()
            md_parts.append(f"# Page {page_num}\n\n{page_text}")
        compiled_md = "\n\n---\n\n".join(md_parts)
        out_filename = f"{filename_stem}_extracted.md"
        return Response(
            content=compiled_md.encode("utf-8"),
            media_type="text/markdown; charset=utf-8",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"'
            }
        )


