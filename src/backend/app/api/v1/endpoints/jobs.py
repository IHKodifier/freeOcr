import os
import glob
import tempfile
import json
import asyncio
import time
import datetime
import io
import zipfile
import urllib.parse
import pymupdf
from fastapi import APIRouter, Request, HTTPException, status, Query
from fastapi.responses import StreamingResponse, Response, JSONResponse
from app.redis_client import get_redis_client, DEV_JOB_STORE, EphemeralRamStore
from app.services.pdf_composer import get_searchable_pdf

router = APIRouter()
DEV_PAGE_IMAGE_STORE: EphemeralRamStore = EphemeralRamStore("page_img", is_bytes=True)


@router.get("/{job_id}")
async def get_job_status(job_id: str):
    """
    Returns job status and progress for polling or verification.
    """
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
        return parsed
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error parsing job data."
        )


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
                    last_ping = time.time()
                    while True:
                        if await request.is_disconnected():
                            break
                        message = pubsub.get_message(ignore_subscribe_messages=True, timeout=0.1)
                        if message and message.get("type") == "message":
                            raw_data = message.get("data")
                            data_str = raw_data.decode("utf-8") if isinstance(raw_data, bytes) else str(raw_data)
                            yield f"data: {data_str}\n\n"
                            last_ping = time.time()
                            try:
                                parsed = json.loads(data_str)
                                if parsed.get("status") in ("COMPLETED", "FAILED"):
                                    break
                            except Exception:
                                pass
                        elif time.time() - last_ping > 10.0:
                            yield ": keepalive\n\n"
                            last_ping = time.time()
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
            last_ping = time.time()
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
                            last_ping = time.time()
                            if curr_status in ("COMPLETED", "FAILED"):
                                break
                    except Exception:
                        pass
                if time.time() - last_ping > 10.0:
                    yield ": keepalive\n\n"
                    last_ping = time.time()
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


@router.get("/{job_id}/pages/{page_number}/image")
async def get_job_page_image(job_id: str, page_number: int = 1):
    """
    Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given job and page.
    """
    if page_number < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Page number must be 1 or greater."
        )

    cache_key = f"{job_id}_{page_number}"
    if cache_key in DEV_PAGE_IMAGE_STORE:
        return Response(
            content=DEV_PAGE_IMAGE_STORE[cache_key],
            media_type="image/png",
            headers={"Cache-Control": "public, max-age=3600"}
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

    pdf_bytes = None
    output_token = parsed.get("output_pdf_token")
    if output_token:
        pdf_bytes = get_searchable_pdf(output_token)

    # If searchable PDF is available in store
    if pdf_bytes:
        try:
            doc = pymupdf.open(stream=pdf_bytes, filetype="pdf")
            total_doc_pages = len(doc)
            if page_number > total_doc_pages:
                doc.close()
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Page not found. Document has {total_doc_pages} pages."
                )
            page = doc[page_number - 1]
            pix = page.get_pixmap(dpi=150)
            img_bytes = pix.tobytes("png")
            doc.close()
            DEV_PAGE_IMAGE_STORE[cache_key] = img_bytes
            return Response(
                content=img_bytes,
                media_type="image/png",
                headers={"Cache-Control": "public, max-age=3600"}
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to render document page: {e}"
            )

    # Fallback to ephemeral input file in RAM disk if processing
    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    matching_inputs = glob.glob(os.path.join(ram_disk_base, f"ephemeral_{job_id}_*"))
    for input_file in matching_inputs:
        try:
            doc = pymupdf.open(input_file)
            if not input_file.lower().endswith(".pdf"):
                pdf_bytes_conv = doc.convert_to_pdf()
                doc.close()
                doc = pymupdf.open("pdf", pdf_bytes_conv)
            total_doc_pages = len(doc)
            if page_number > total_doc_pages:
                doc.close()
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Page not found. Document has {total_doc_pages} pages."
                )
            page = doc[page_number - 1]
            pix = page.get_pixmap(dpi=150)
            img_bytes = pix.tobytes("png")
            doc.close()
            DEV_PAGE_IMAGE_STORE[cache_key] = img_bytes
            return Response(
                content=img_bytes,
                media_type="image/png",
                headers={"Cache-Control": "public, max-age=3600"}
            )
        except HTTPException:
            raise
        except Exception:
            pass

    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Page preview unavailable."
    )


@router.get("/batch-download/zip")
async def batch_download_zip(
    job_ids: str = Query(..., description="Comma-separated list of job IDs"),
    format: str = "pdf"
):
    """
    Streams a single ZIP archive containing all completed documents in the batch.
    Prevents browser multi-download blocking and provides 1-click batch retrieval.
    """
    fmt = format.lower().strip()
    if fmt not in ("pdf", "txt", "md"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported format. Choose pdf, txt, or md."
        )

    id_list = [jid.strip() for jid in job_ids.split(",") if jid.strip()]
    if not id_list:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No job IDs provided."
        )

    zip_buffer = io.BytesIO()
    added_count = 0
    used_filenames = set()

    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zf:
        for job_id in id_list:
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
                continue

            try:
                data_str = job_data_bytes.decode("utf-8") if isinstance(job_data_bytes, bytes) else str(job_data_bytes)
                parsed = json.loads(data_str) if isinstance(data_str, str) else data_str
            except Exception:
                continue

            if parsed.get("status") != "COMPLETED":
                continue

            orig_filename = parsed.get("filename", f"doc_{job_id}")
            filename_stem = os.path.splitext(orig_filename)[0] or "document"

            file_bytes = None
            arc_name = ""

            if fmt == "pdf":
                output_token = parsed.get("output_pdf_token")
                file_bytes = get_searchable_pdf(output_token) if output_token else None
                arc_name = f"{filename_stem}_searchable.pdf"
            elif fmt == "txt":
                pages = parsed.get("pages", [])
                txt_parts = [p.get("text", "").strip() for p in pages if p.get("text", "").strip()]
                file_bytes = "\n\n".join(txt_parts).encode("utf-8")
                arc_name = f"{filename_stem}_extracted.txt"
            elif fmt == "md":
                pages = parsed.get("pages", [])
                md_parts = [f"# Page {p.get('page_number', 1)}\n\n{p.get('text', '').strip()}" for p in pages]
                file_bytes = "\n\n---\n\n".join(md_parts).encode("utf-8")
                arc_name = f"{filename_stem}_extracted.md"

            if file_bytes:
                final_arc_name = arc_name
                counter = 1
                while final_arc_name in used_filenames:
                    dot_idx = arc_name.rfind(".")
                    if dot_idx > 0:
                        final_arc_name = f"{arc_name[:dot_idx]}_{counter}{arc_name[dot_idx:]}"
                    else:
                        final_arc_name = f"{arc_name}_{counter}"
                    counter += 1
                used_filenames.add(final_arc_name)
                zf.writestr(final_arc_name, file_bytes)
                added_count += 1

                # Clean up ephemeral input files from RAM disk as mandate requires
                ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
                matching_inputs = glob.glob(os.path.join(ram_disk_base, f"ephemeral_{job_id}_*"))
                for input_file in matching_inputs:
                    try:
                        os.remove(input_file)
                    except Exception:
                        pass

    if added_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No completed files found for the provided job IDs."
        )

    zip_bytes = zip_buffer.getvalue()
    out_filename = "freeOCR_searchable_batch.zip" if fmt == "pdf" else f"freeOCR_{fmt}_batch.zip"
    return Response(
        content=zip_bytes,
        media_type="application/zip",
        headers={
            "Content-Disposition": f'attachment; filename="{out_filename}"'
        }
    )


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
        safe_filename = urllib.parse.quote(out_filename)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"; filename*=UTF-8\'\'{safe_filename}'
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
        safe_filename = urllib.parse.quote(out_filename)
        return Response(
            content=compiled_txt.encode("utf-8"),
            media_type="text/plain; charset=utf-8",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"; filename*=UTF-8\'\'{safe_filename}'
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
        safe_filename = urllib.parse.quote(out_filename)
        return Response(
            content=compiled_md.encode("utf-8"),
            media_type="text/markdown; charset=utf-8",
            headers={
                "Content-Disposition": f'attachment; filename="{out_filename}"; filename*=UTF-8\'\'{safe_filename}'
            }
        )


