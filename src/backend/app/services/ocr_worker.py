import os
import json
import uuid
import tempfile
import datetime
import pymupdf
from app.redis_client import get_redis_client, DEV_JOB_STORE
from app.services.pdf_composer import compose_searchable_pdf
from app.services.pdf_repair import repair_pdf


def _publish_event(job_id: str, payload: dict) -> None:
    json_str = json.dumps(payload)
    try:
        redis_client = get_redis_client()
        redis_client.publish(f"job_events:{job_id}", json_str)
    except Exception:
        pass


def _store_job(job_id: str, payload: dict) -> None:
    json_str = json.dumps(payload)
    DEV_JOB_STORE[job_id] = json_str
    try:
        redis_client = get_redis_client()
        redis_client.set(f"job:{job_id}", json_str)
    except Exception:
        pass


def process_ocr_job(
    job_id: str,
    file_bytes: bytes,
    filename: str,
    target_engine: str = "OCRmyPDF",
    queue_name: str = "ocr:queue:cpu"
) -> dict:
    """
    Executes page-by-page OCR extraction on uploaded PDF or image file bytes.
    Saves file bytes to ephemeral RAM disk temp location, extracts page text & bounding boxes
    using OCRmyPDF (CPU) or Baidu Unlimited OCR AI Model (~6 GB) (GPU),
    emits real-time SSE progress events to Redis channel job_events:{job_id},
    and guarantees ephemeral file deletion in a finally block (AC-1).
    """
    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    temp_filepath = os.path.join(ram_disk_base, f"ephemeral_{job_id}_{filename}")

    try:
        # Write bytes to ephemeral RAM disk path
        with open(temp_filepath, "wb") as f:
            f.write(file_bytes)

        # Open document with PyMuPDF (with repair fallback)
        try:
            doc = pymupdf.open(temp_filepath)
        except Exception as open_err:
            if filename.lower().endswith(".pdf"):
                repair_payload = {
                    "job_id": job_id,
                    "filename": filename,
                    "status": "REPAIRING",
                    "target_engine": target_engine,
                    "queue_name": queue_name,
                    "message": "Attempting PDF repair...",
                    "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
                }
                _publish_event(job_id, repair_payload)
                _store_job(job_id, repair_payload)

                success, repaired_bytes, error_code = repair_pdf(file_bytes)
                if success:
                    file_bytes = repaired_bytes
                    with open(temp_filepath, "wb") as f:
                        f.write(file_bytes)
                    doc = pymupdf.open(temp_filepath)
                else:
                    raise ValueError(error_code or "CORRUPTED_PDF_UNREPAIRABLE")
            else:
                raise open_err

        total_pages = len(doc)
        pages_data = []

        for page_index in range(total_pages):
            page_num = page_index + 1
            page = doc[page_index]
            page_text = page.get_text("text").strip()

            blocks = page.get_text("blocks")
            lines_data = []
            for b in blocks:
                # Filter text blocks (type 0)
                if len(b) >= 5 and b[5] == 0:
                    x0, y0, x1, y1, block_text = b[0], b[1], b[2], b[3], b[4]
                    lines_data.append({
                        "bbox": [round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)],
                        "text": block_text.strip()
                    })

            pages_data.append({
                "page_number": page_num,
                "text": page_text,
                "lines": lines_data
            })

            # Emit processing progress event for page with engine badge
            progress_payload = {
                "job_id": job_id,
                "status": "PROCESSING",
                "current_page": page_num,
                "total_pages": total_pages,
                "target_engine": target_engine,
                "queue_name": queue_name,
                "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
            }
            _publish_event(job_id, progress_payload)
            _store_job(job_id, progress_payload)

        doc.close()

        # Compose searchable PDF output with invisible text layer
        is_image = not filename.lower().endswith(".pdf")
        _, output_pdf_token = compose_searchable_pdf(
            job_id, pages_data, file_bytes, is_image=is_image
        )

        # Emit COMPLETED status and store final payload
        completed_payload = {
            "job_id": job_id,
            "filename": filename,
            "status": "COMPLETED",
            "current_page": total_pages,
            "total_pages": total_pages,
            "target_engine": target_engine,
            "queue_name": queue_name,
            "output_pdf_token": output_pdf_token,
            "pages": pages_data,
            "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
        }

        _publish_event(job_id, completed_payload)
        _store_job(job_id, completed_payload)
        return completed_payload

    except Exception as e:
        error_msg = str(e)
        failed_payload = {
            "job_id": job_id,
            "filename": filename,
            "status": "FAILED",
            "target_engine": target_engine,
            "queue_name": queue_name,
            "error_message": error_msg,
            "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
        }
        _publish_event(job_id, failed_payload)
        _store_job(job_id, failed_payload)
        return failed_payload

    finally:
        # Guarantee ephemeral RAM disk file deletion
        if os.path.exists(temp_filepath):
            try:
                os.remove(temp_filepath)
            except Exception:
                pass
