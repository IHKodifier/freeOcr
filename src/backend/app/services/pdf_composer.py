import os
import uuid
import tempfile
import pymupdf

DEV_PDF_STORE: dict[str, bytes] = {}


def compose_searchable_pdf(
    job_id: str,
    pages_data: list[dict],
    original_file_bytes: bytes,
    is_image: bool = False
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

        for page_idx, page_info in enumerate(pages_data):
            if page_idx < len(doc):
                page = doc[page_idx]
                lines = page_info.get("lines", [])
                for line in lines:
                    bbox = line.get("bbox")
                    text = line.get("text", "").strip()
                    origin = line.get("origin")
                    size = line.get("size")
                    if bbox and text and len(bbox) == 4:
                        x0, y0, x1, y1 = float(bbox[0]), float(bbox[1]), float(bbox[2]), float(bbox[3])
                        h = max(1.0, y1 - y0)
                        w = max(1.0, x1 - x0)
                        avail_w = max(1.0, min(w, page.rect.width - x0 - 2.0))

                        if size:
                            font_size = float(size)
                        else:
                            font_size = min(h * 0.75, avail_w / max(1, len(text) * 0.55))

                        font_size = max(5.0, font_size)


                        if origin and len(origin) == 2:
                            org_pt = pymupdf.Point(float(origin[0]), float(origin[1]))
                        else:
                            org_pt = pymupdf.Point(x0, y1 - h * 0.2)

                        # Insert invisible text layer (render_mode=3) over exact line coordinates
                        page.insert_text(
                            org_pt,
                            text,
                            fontsize=font_size,
                            render_mode=3,
                            overlay=True
                        )


        doc.save(temp_out_filepath)
        doc.close()


        with open(temp_out_filepath, "rb") as f:
            pdf_bytes = f.read()

        output_pdf_token = f"pdf_token_{uuid.uuid4().hex[:12]}"
        DEV_PDF_STORE[output_pdf_token] = pdf_bytes

        return pdf_bytes, output_pdf_token

    finally:
        if temp_out_filepath and os.path.exists(temp_out_filepath):
            try:
                os.remove(temp_out_filepath)
            except Exception:
                pass


def get_searchable_pdf(token: str) -> bytes | None:
    """
    Retrieves compiled searchable PDF bytes by token from ephemeral dev store.
    """
    return DEV_PDF_STORE.get(token)
