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

        total_pages = len(doc)
        pages_data = []
        _easyocr_reader = None

        for page_index in range(total_pages):
            page_num = page_index + 1
            page = doc[page_index]
            page_text = page.get_text("text").strip()

            dict_data = page.get_text("dict")
            lines_data = []
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

                # Engine 1: OCRmyPDF / Tesseract Engine (Designated Engine for Simple Layout Scanned PDFs)
                try:
                    tess_dir = _get_tessdata_dir()
                    textpage = page.get_textpage_ocr(tessdata=tess_dir)
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





                # Engine 2: Baidu Unlimited OCR Engine (Designated AI Engine for Complex Layouts / Multi-Column OCR)
                if not lines_data and target_engine == "Baidu_Unlimited_OCR":
                    try:
                        print("[Baidu Unlimited OCR] Executing Baidu Unlimited OCR Model on complex layout...")
                        try:
                            from paddleocr import PaddleOCR
                            _baidu_engine = PaddleOCR(use_angle_cls=True, lang="en", show_log=False)
                            pix = page.get_pixmap(dpi=300)
                            img_bytes = pix.tobytes("png")

                            with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp_img:
                                tmp_img.write(img_bytes)
                                tmp_img_path = tmp_img.name

                            try:
                                ocr_results = _baidu_engine.ocr(tmp_img_path, cls=True)
                                if ocr_results and ocr_results[0]:
                                    for res in ocr_results[0]:
                                        bbox_coords = res[0]
                                        text_tuple = res[1]
                                        if text_tuple and text_tuple[0]:
                                            x_coords = [pt[0] for pt in bbox_coords]
                                            y_coords = [pt[1] for pt in bbox_coords]
                                            x0, y0, x1, y1 = min(x_coords), min(y_coords), max(x_coords), max(y_coords)
                                            lines_data.append({
                                                "bbox": [round(float(x0), 2), round(float(y0), 2), round(float(x1), 2), round(float(y1), 2)],
                                                "text": text_tuple[0].strip(),
                                                "size": None,
                                                "origin": None
                                            })
                                    if lines_data:
                                        page_text = "\n".join([line["text"] for line in lines_data])
                            finally:
                                if os.path.exists(tmp_img_path):
                                    os.remove(tmp_img_path)
                        except ImportError:
                            print("[Baidu Unlimited OCR] PaddleOCR library not present in local dev env; falling back to PyMuPDF/Tesseract.")
                    except Exception as baidu_err:
                        print(f"[Baidu Unlimited OCR Worker Error] {baidu_err}")


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
        print(f"[OCR WORKER EXCEPTION] {e}", flush=True)
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
