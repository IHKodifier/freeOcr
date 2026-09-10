import os
import uuid
import tempfile
import pymupdf

from app.redis_client import EphemeralRamStore, get_redis_client

DEV_PDF_STORE: EphemeralRamStore = EphemeralRamStore("pdf", is_bytes=True)



def compose_searchable_pdf(
    job_id: str,
    pages_data: list[dict],
    original_file_bytes: bytes,
    is_image: bool = False,
    password: str = None
) -> tuple[bytes, str]:
    """
    Overlays invisible text (render_mode=3) onto PDF or image pages using bounding box metadata from OCR.
    Outputs compiled PDF to ephemeral RAM disk storage, reads bytes, guarantees ephemeral file deletion,
    and returns (pdf_bytes, output_pdf_token).
    """
    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    temp_out_filepath = os.path.join(ram_disk_base, f"ephemeral_out_{job_id}.pdf")

    try:
        if is_image:
            doc = pymupdf.open()
            img_doc = pymupdf.open(stream=original_file_bytes, filetype="png")
            rect = img_doc[0].rect
            page = doc.new_page(width=rect.width, height=rect.height)
            page.insert_image(rect, stream=original_file_bytes)
            img_doc.close()
        else:
            doc = pymupdf.open(stream=original_file_bytes, filetype="pdf")
            if doc.is_encrypted and password:
                doc.authenticate(password)

        for page_idx, page_info in enumerate(pages_data):
            if page_idx < len(doc):
                page = doc[page_idx]

                # Apply page auto-orientation if rotation is detected
                detected_rotation = page_info.get("rotation")
                if detected_rotation in (90, 180, 270) and page.rotation != detected_rotation:
                    page.set_rotation(detected_rotation)

                lines = page_info.get("lines", [])
                for line in lines:
                    bbox = line.get("bbox")
                    text = (line.get("text") or "").strip()
                    size = line.get("size")

                    if bbox and text and len(bbox) == 4:
                        raw_x0, raw_y0, raw_x1, raw_y1 = float(bbox[0]), float(bbox[1]), float(bbox[2]), float(bbox[3])
                        page_w, page_h = float(page.rect.width), float(page.rect.height)
                        x0 = max(0.0, min(raw_x0, page_w - 1.0))
                        y0 = max(0.0, min(raw_y0, page_h - 1.0))
                        x1 = max(x0 + 1.0, min(raw_x1, page_w - 1.0))
                        y1 = max(y0 + 1.0, min(raw_y1, page_h - 1.0))

                        h = max(1.0, y1 - y0)
                        w = max(1.0, x1 - x0)
                        font = pymupdf.Font("helv")
                        font_height_ratio = max(0.5, font.ascender - font.descender)
                        font_size = max(4.0, h / font_height_ratio)

                        descender_depth = abs(font.descender) * font_size
                        baseline = y1 - descender_depth
                        origin = pymupdf.Point(x0, baseline)

                        nat_w = font.text_length(text, fontsize=font_size)
                        if nat_w > 0 and w > 0:
                            # Precision single-string horizontal morphing:
                            # sx stretches or condenses the line proportionally so it starts exactly at x0
                            # and spans cleanly to x1 without fragmenting words or showing whitespace gaps.
                            sx = w / nat_w
                            sx = max(0.2, min(sx, 4.0))
                            morph_matrix = pymupdf.Matrix(sx, 1.0)
                            page.insert_text(
                                origin,
                                text,
                                fontsize=font_size,
                                fontname="helv",
                                render_mode=3,
                                morph=(origin, morph_matrix),
                                overlay=True
                            )
                        else:
                            page.insert_text(
                                origin,
                                text,
                                fontsize=font_size,
                                fontname="helv",
                                render_mode=3,
                                overlay=True
                            )




        doc.save(temp_out_filepath)
        doc.close()


        with open(temp_out_filepath, "rb") as f:
            pdf_bytes = f.read()

        output_pdf_token = f"pdf_token_{uuid.uuid4().hex[:12]}"
        DEV_PDF_STORE[output_pdf_token] = pdf_bytes

        # Persist PDF bytes in Redis for serverless scale-to-zero container survival (24-hour TTL)
        try:
            redis_client = get_redis_client()
            redis_client.set(f"pdf:{output_pdf_token}", pdf_bytes, ex=86400)
        except Exception:
            pass

        return pdf_bytes, output_pdf_token

    finally:
        if temp_out_filepath and os.path.exists(temp_out_filepath):
            try:
                os.remove(temp_out_filepath)
            except Exception:
                pass


def get_searchable_pdf(token: str) -> bytes | None:
    """
    Retrieves compiled searchable PDF bytes by token from ephemeral dev store or Redis.
    """
    # 1. Check local RAM store
    pdf_bytes = DEV_PDF_STORE.get(token)
    if pdf_bytes:
        return pdf_bytes

    # 2. Check Redis (persists across cold starts and container scale-downs)
    try:
        redis_client = get_redis_client()
        redis_bytes = redis_client.get(f"pdf:{token}")
        if redis_bytes:
            DEV_PDF_STORE[token] = redis_bytes
            return redis_bytes
    except Exception:
        pass

    return None
