import os
import re
import json
import uuid
import tempfile
import datetime
import httpx
import pymupdf
from app.redis_client import get_redis_client, DEV_JOB_STORE
from app.services.pdf_composer import compose_searchable_pdf
from app.services.pdf_repair import repair_pdf

COMMON_ENGLISH_WORDS = {
    'the', 'of', 'and', 'to', 'in', 'is', 'you', 'that', 'it', 'he', 'was', 'for', 'on', 'are', 'as', 'with', 'his', 'they',
    'at', 'be', 'this', 'have', 'from', 'or', 'one', 'had', 'by', 'word', 'but', 'not', 'what', 'all', 'were', 'we', 'when',
    'your', 'can', 'said', 'there', 'use', 'an', 'each', 'which', 'she', 'do', 'how', 'their', 'if', 'will', 'up', 'other',
    'about', 'out', 'many', 'then', 'them', 'these', 'so', 'some', 'her', 'would', 'make', 'like', 'him', 'into', 'time',
    'has', 'look', 'two', 'more', 'write', 'go', 'see', 'number', 'no', 'way', 'could', 'people', 'my', 'than', 'first',
    'water', 'been', 'call', 'who', 'oil', 'its', 'now', 'find', 'long', 'down', 'day', 'did', 'get', 'come', 'made', 'may',
    'part', 'balance', 'total', 'year', 'date', 'cost', 'assets', 'office', 'rate', 'value', 'charge', 'note', 'page', 'bank',
    'rupees', 'december', 'january', 'written', 'depreciation', 'operating', 'furniture', 'motor', 'cash', 'tax', 'income',
    'loss', 'profit', 'report', 'amount', 'amounts', 'financial', 'statement', 'statements', 'audit', 'auditor', 'limited'
}


def detect_page_orientation(page: pymupdf.Page, tess_dir: str = None) -> int:
    """
    Quickly checks whether the page has rotated text (90, 180, 270 deg)
    using dictionary-based scoring on low-DPI OCR sample.
    Returns the best rotation angle (0, 90, 180, or 270).
    """
    try:
        orig_rot = page.rotation

        def _score_rotation(rot: int) -> int:
            page.set_rotation(rot)
            try:
                tp = page.get_textpage_ocr(tessdata=tess_dir, dpi=72, full=False)
                txt = tp.extractTEXT().lower()
                words = [w.strip(".,;:()[]\"'") for w in txt.split() if w.isalpha()]
                return sum(1 for w in words if w in COMMON_ENGLISH_WORDS)
            except Exception:
                return 0

        # 1. Fast check: rotation 0 (already upright in PDF)
        score_0 = _score_rotation(0)
        if score_0 >= 5:
            page.set_rotation(orig_rot)
            return 0

        # 2. If score_0 < 5, evaluate 90, 180, 270 degrees
        best_rot = 0
        best_score = score_0
        for rot in [90, 180, 270]:
            score = _score_rotation(rot)
            if score > best_score:
                best_score = score
                best_rot = rot

        page.set_rotation(orig_rot)
        if best_score >= 3 and best_rot != 0:
            return best_rot
        return 0
    except Exception as e:
        print(f"[Orientation Detection Warning] {e}")
        return 0


def parse_html_table_to_lines(html_str: str, bbox: list) -> list:
    """
    Parses an HTML table string into structured lines with computed bboxes.
    Decomposes multi-row financial tables into bounded horizontal text lines.
    """
    row_pattern = re.compile(r"<tr>(.*?)</tr>", re.DOTALL)
    cell_pattern = re.compile(r"<td[^>]*>(.*?)</td>", re.DOTALL)
    rows = row_pattern.findall(html_str)
    if not rows:
        clean = re.sub(r"<[^>]+>", " ", html_str).strip()
        return [{"bbox": bbox, "text": clean}] if clean else []

    x0, y0, x1, y1 = float(bbox[0]), float(bbox[1]), float(bbox[2]), float(bbox[3])
    total_h = max(1.0, y1 - y0)
    row_h = total_h / len(rows)
    lines = []

    for r_idx, r in enumerate(rows):
        cells = [re.sub(r"<[^>]+>", "", c).strip() for c in cell_pattern.findall(r)]
        row_text = "   ".join([c for c in cells if c])
        if row_text:
            ry0 = y0 + (r_idx * row_h)
            ry1 = ry0 + row_h
            lines.append({
                "bbox": [round(x0, 2), round(ry0, 2), round(x1, 2), round(ry1, 2)],
                "text": row_text
            })
    return lines



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

                # Detect physical page orientation (0, 90, 180, 270) to prevent sideways scanning corruption
                tess_dir = _get_tessdata_dir()
                detected_rot = detect_page_orientation(page, tess_dir=tess_dir)
                if detected_rot != page.rotation:
                    page.set_rotation(detected_rot)

                # Path A: Baidu Unlimited OCR Engine (Designated AI Engine for Complex Layouts)
                if target_engine == "Baidu_Unlimited_OCR":
                    try:
                        print(f"[Baidu Unlimited OCR] Executing Baidu Unlimited OCR Model on complex layout (rot={page.rotation}) at 200 DPI...", flush=True)
                        target_dpi = 200
                        pix = page.get_pixmap(dpi=target_dpi)
                        scale_x = page.rect.width / max(1.0, float(pix.width))
                        scale_y = page.rect.height / max(1.0, float(pix.height))
                        img_bytes = pix.tobytes("png")

                        gpu_worker_url = os.environ.get("BAIDU_GPU_WORKER_URL")
                        internal_secret = os.environ.get("INTERNAL_SECRET")
                        timeout_sec = float(os.environ.get("BAIDU_GPU_TIMEOUT", "120.0"))

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
                                            # If text contains an HTML table, decompose into structured rows
                                            if "<table" in text:
                                                sub_lines = parse_html_table_to_lines(text, bbox)
                                                for sl in sub_lines:
                                                    sb = sl.get("bbox", bbox)
                                                    st = sl.get("text", "").strip()
                                                    if st and len(sb) == 4:
                                                        x0, y0, x1, y1 = sb
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
                                                            "text": st,
                                                            "size": round(est_font_size, 2),
                                                            "origin": [round(x0_scaled, 2), round(origin_y, 2)]
                                                        })
                                            else:
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
                "lines": lines_data,
                "rotation": page.rotation
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
