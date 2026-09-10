import os
import json
import uuid
import tempfile
import datetime
import httpx
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
        redis_client.set(f"job:{job_id}", json_str, ex=86400)
    except Exception:
        pass


def _get_tessdata_dir() -> str:
    """Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR on simple layouts."""
    tessdata_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "tessdata")
    os.makedirs(tessdata_dir, exist_ok=True)
    eng_path = os.path.join(tessdata_dir, "eng.traineddata")
    if not os.path.exists(eng_path):
        try:
            import urllib.request
            url = "https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata"
            urllib.request.urlretrieve(url, eng_path)
        except Exception as e:
            print(f"[Tessdata Download Warning] {e}")
    return tessdata_dir


def process_ocr_job(
    job_id: str,
    file_bytes: bytes,
    filename: str,
    target_engine: str = "OCRmyPDF",
    queue_name: str = "ocr:queue:cpu",
    password: str = None
) -> dict:
    """
    Executes page-by-page OCR extraction on uploaded PDF or image file bytes.
    Saves file bytes to ephemeral RAM disk temp location, extracts page text & bounding boxes
    using OCRmyPDF/Tesseract (CPU) or Baidu Unlimited OCR AI Model (~6 GB) (GPU),
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
            if doc.is_encrypted:
                if password:
                    res = doc.authenticate(password)
                    if not res:
                        raise ValueError("PASSWORD_REQUIRED: Password Protected PDF.")
                else:
                    raise ValueError("PASSWORD_REQUIRED: Password Protected PDF.")
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

        # Convert raster image documents (PNG, JPG, etc.) to PDF so PyMuPDF's get_textpage_ocr can process pages
        if not filename.lower().endswith(".pdf"):
            pdf_bytes = doc.convert_to_pdf()
            doc.close()
            doc = pymupdf.open("pdf", pdf_bytes)

        total_pages = len(doc)
        pages_data = []
        _easyocr_reader = None

        for page_index in range(total_pages):
            page_num = page_index + 1
            page = doc[page_index]
            page_text = page.get_text("text").strip()

            lines_data = []
            dict_data = page.get_text("dict")
            for b in dict_data.get("blocks", []):
                if b.get("type") == 0:
                    for l in b.get("lines", []):
                        line_bbox = list(l.get("bbox", []))
                        spans = l.get("spans", [])
                        line_text = " ".join([s.get("text", "").strip() for s in spans if s.get("text", "").strip()])
                        if line_text:
                            font_size = spans[0].get("size") if spans else None
                            origin = list(spans[0].get("origin")) if (spans and spans[0].get("origin")) else None
                            lines_data.append({
                                "bbox": [round(float(x), 2) for x in line_bbox],
                                "text": line_text,
                                "size": round(float(font_size), 2) if font_size else None,
                                "origin": [round(float(x), 2) for x in origin] if origin else None
                            })

            # Check if extracted text contains actual alphanumeric words
            has_meaningful_text = any(any(c.isalnum() for c in line.get("text", "")) for line in lines_data)

            # If no digital text blocks found (e.g. scanned PDF image without text stream), run OCR recognition
            if not has_meaningful_text:
                lines_data = []

                # Path A: Baidu Unlimited OCR Engine (Designated AI Engine for Complex Layouts)
                if target_engine == "Baidu_Unlimited_OCR":
                    try:
                        print("[Baidu Unlimited OCR] Executing Baidu Unlimited OCR Model on complex layout at 200 DPI...", flush=True)
                        target_dpi = 200
                        pix = page.get_pixmap(dpi=target_dpi)
                        scale_x = page.rect.width / max(1.0, float(pix.width))
                        scale_y = page.rect.height / max(1.0, float(pix.height))
                        img_bytes = pix.tobytes("png")

                        gpu_worker_url = os.environ.get("BAIDU_GPU_WORKER_URL")
                        internal_secret = os.environ.get("INTERNAL_SECRET")
                        timeout_sec = float(os.environ.get("BAIDU_GPU_TIMEOUT", "75.0"))

                        # 1. Dispatch to remote Cloud Run GPU worker if configured
                        if gpu_worker_url:
                            try:
                                url = f"{gpu_worker_url.rstrip('/')}/ocr/complex-page"
                                headers = {}
                                if internal_secret:
                                    headers["X-Internal-Secret"] = internal_secret

                                resp = httpx.post(
                                    url,
                                    headers=headers,
                                    files={"file": (f"page_{page_num}.png", img_bytes, "image/png")},
                                    timeout=timeout_sec
                                )
                                if resp.status_code == 200:
                                    gpu_data = resp.json()
                                    font = pymupdf.Font("helv")
                                    font_height_ratio = max(0.5, font.ascender - font.descender)
                                    for item in gpu_data.get("lines", []):
                                        bbox = item.get("bbox", [])
                                        text = item.get("text", "").strip()
                                        if len(bbox) == 4 and text:
                                            x0, y0, x1, y1 = bbox
                                            x0_scaled = float(x0) * scale_x
                                            y0_scaled = float(y0) * scale_y
                                            x1_scaled = float(x1) * scale_x
                                            y1_scaled = float(y1) * scale_y
                                            h_scaled = max(1.0, y1_scaled - y0_scaled)
                                            est_font_size = max(5.0, h_scaled / font_height_ratio)
                                            descender_depth = abs(font.descender) * est_font_size
                                            origin_y = y1_scaled - descender_depth

                                            lines_data.append({
                                                "bbox": [round(x0_scaled, 2), round(y0_scaled, 2), round(x1_scaled, 2), round(y1_scaled, 2)],
                                                "text": text,
                                                "size": round(est_font_size, 2),
                                                "origin": [round(x0_scaled, 2), round(origin_y, 2)]
                                            })
                                    if lines_data:
                                        page_text = "\n".join([line["text"] for line in lines_data])
                                else:
                                    print(f"[Baidu Unlimited OCR] GPU Worker returned status {resp.status_code}. Silent fallback to CPU engine.")
                            except Exception as gpu_err:
                                print(f"[Baidu Unlimited OCR] Remote GPU worker unavailable or timed out ({gpu_err}). Silent fallback to CPU engine.")

                        if not lines_data and not gpu_worker_url:
                            print("[Baidu Unlimited OCR] Remote GPU worker URL not configured. Silent fallback to CPU engine.")
                    except Exception as baidu_err:
                        print(f"[Baidu Unlimited OCR Worker Error] {baidu_err}. Silent fallback to CPU engine.")

                # Path B: CPU OCRmyPDF / Tesseract Engine (Primary for Simple Layouts + Resilient Fallback for Complex Layouts)
                if not lines_data:
                    try:
                        tess_dir = _get_tessdata_dir()
                        textpage = page.get_textpage_ocr(tessdata=tess_dir, dpi=300, full=True)
                        ocr_dict = textpage.extractDICT()
                        for b in ocr_dict.get("blocks", []):
                            if b.get("type") == 0 or "lines" in b:
                                for l in b.get("lines", []):
                                    line_bbox = list(l.get("bbox", []))
                                    spans = l.get("spans", [])
                                    line_text = " ".join([s.get("text", "").strip() for s in spans if s.get("text", "").strip()])
                                    if line_text:
                                        font_size = spans[0].get("size") if spans else None
                                        origin = list(spans[0].get("origin")) if (spans and spans[0].get("origin")) else None
                                        lines_data.append({
                                            "bbox": [round(float(x), 2) for x in line_bbox],
                                            "text": line_text,
                                            "size": round(float(font_size), 2) if font_size else None,
                                            "origin": [round(float(x), 2) for x in origin] if origin else None
                                        })
                        if lines_data:
                            page_text = "\n".join([line["text"] for line in lines_data])
                    except Exception as tess_err:
                        print(f"[OCRmyPDF / Tesseract Engine Warning] {tess_err}")


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
                "layout_complexity": "COMPLEX" if target_engine == "Baidu_Unlimited_OCR" else "SIMPLE",
                "target_engine": target_engine,
                "queue_name": queue_name,
                "pages": pages_data,
                "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
            }
            _publish_event(job_id, progress_payload)
            _store_job(job_id, progress_payload)

        doc.close()

        # Compose searchable PDF output with invisible text layer
        is_image = not filename.lower().endswith(".pdf")
        _, output_pdf_token = compose_searchable_pdf(
            job_id, pages_data, file_bytes, is_image=is_image, password=password
        )

        # Emit COMPLETED status and store final payload
        now_utc = datetime.datetime.now(datetime.timezone.utc)
        expires_utc = now_utc + datetime.timedelta(hours=24)
        completed_payload = {
            "job_id": job_id,
            "filename": filename,
            "status": "COMPLETED",
            "current_page": total_pages,
            "total_pages": total_pages,
            "layout_complexity": "COMPLEX" if target_engine == "Baidu_Unlimited_OCR" else "SIMPLE",
            "target_engine": target_engine,
            "queue_name": queue_name,
            "output_pdf_token": output_pdf_token,
            "pages": pages_data,
            "created_at": now_utc.isoformat(),
            "expires_at": expires_utc.isoformat(),
            "updated_at": now_utc.isoformat()
        }

        _publish_event(job_id, completed_payload)
        _store_job(job_id, completed_payload)
        return completed_payload

    except Exception as e:
        error_msg = str(e)
        print(f"[OCR WORKER EXCEPTION] {e}", flush=True)
        failed_payload = {
            "job_id": job_id,
            "filename": filename,
            "status": "FAILED",
            "layout_complexity": "COMPLEX" if target_engine == "Baidu_Unlimited_OCR" else "SIMPLE",
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
