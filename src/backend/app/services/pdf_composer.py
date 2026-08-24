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
                    if bbox and text and len(bbox) == 4:
                        rect = pymupdf.Rect(bbox[0], bbox[1], bbox[2], bbox[3])
                        # Insert invisible text layer over exact bounding box coordinates
                        page.insert_textbox(
                            rect,
                            text,
                            fontsize=10,
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
