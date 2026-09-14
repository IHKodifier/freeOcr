import io
import logging
from pathlib import Path
from typing import Optional

import fitz  # PyMuPDF
from PIL import Image

logger = logging.getLogger(__name__)

SUPPORTED_WATERMARK_TYPES = {"text", "image"}


def watermark_pdf(
    input_path: Path,
    output_path: Path,
    watermark_type: str = "text",
    text: str = "CONFIDENTIAL",
    image_path: Optional[Path] = None,
    rotation: float = -45.0,
    opacity: float = 0.3,
    font_size: float = 48.0,
    position: str = "center",
) -> Path:
    """
    Applies custom text or transparent image watermark to all pages of a PDF document.

    Args:
        input_path: Path to the source PDF.
        output_path: Destination path for the watermarked PDF.
        watermark_type: 'text' or 'image'.
        text: Text string for text watermark.
        image_path: Path to logo image (PNG/JPG) for image watermark.
        rotation: Text rotation angle in degrees (e.g. -45.0, 0.0, 45.0).
        opacity: Alpha transparency from 0.05 to 1.0.
        font_size: Font size in points for text watermark (default 48.0pt).
        position: Overlay position anchor (defaults to 'center').

    Returns:
        Path to generated watermarked PDF file.

    Raises:
        ValueError: If PDF is empty, watermark type is unsupported, or parameters invalid.
        RuntimeError: If document processing fails.
    """
    w_type = (watermark_type or "").strip().lower()
    if w_type not in SUPPORTED_WATERMARK_TYPES:
        raise ValueError(
            f"Invalid watermark type: '{watermark_type}'. Supported types: {', '.join(sorted(SUPPORTED_WATERMARK_TYPES))}"
        )

    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    try:
        total_pages = len(doc)
        if total_pages == 0:
            raise ValueError("PDF document has 0 pages.")

        clamped_opacity = max(0.05, min(1.0, float(opacity)))

        if w_type == "text":
            watermark_text = (text or "CONFIDENTIAL").strip()
            if not watermark_text:
                watermark_text = "CONFIDENTIAL"

            font_name = "helv"
            rot_float = float(rotation)
            size_float = max(8.0, min(144.0, float(font_size)))

            for i in range(total_pages):
                page = doc[i]
                page_rect = page.rect
                w = page_rect.width
                h = page_rect.height

                center = fitz.Point(w / 2.0, h / 2.0)
                text_len = fitz.get_text_length(watermark_text, fontname=font_name, fontsize=size_float)
                start_point = fitz.Point(center.x - text_len / 2.0, center.y + size_float / 3.0)

                rot_matrix = fitz.Matrix(rot_float)

                page.insert_text(
                    start_point,
                    watermark_text,
                    fontname=font_name,
                    fontsize=size_float,
                    morph=(center, rot_matrix),
                    color=(0.6, 0.6, 0.6),
                    fill_opacity=clamped_opacity,
                )

        elif w_type == "image":
            if image_path is None or not Path(image_path).exists():
                raise ValueError("Image file is required for image watermark.")

            try:
                with Image.open(image_path) as img:
                    img_rgba = img.convert("RGBA")
                    if clamped_opacity < 1.0:
                        alpha = img_rgba.split()[3]
                        alpha = alpha.point(lambda p: int(p * clamped_opacity))
                        img_rgba.putalpha(alpha)

                    buf = io.BytesIO()
                    img_rgba.save(buf, format="PNG")
                    processed_img_bytes = buf.getvalue()
                    img_w, img_h = img_rgba.size
            except Exception as img_exc:
                logger.error("Failed to process watermark image %s: %s", image_path, img_exc)
                raise ValueError(f"Invalid watermark image: {img_exc}") from img_exc

            for i in range(total_pages):
                page = doc[i]
                page_rect = page.rect
                w = page_rect.width
                h = page_rect.height

                max_w = w * 0.6
                max_h = h * 0.6
                scale = min(max_w / max(1, img_w), max_h / max(1, img_h), 1.0)
                target_w = img_w * scale
                target_h = img_h * scale

                target_rect = fitz.Rect(
                    (w - target_w) / 2.0,
                    (h - target_h) / 2.0,
                    (w + target_w) / 2.0,
                    (h + target_h) / 2.0,
                )

                page.insert_image(
                    target_rect,
                    stream=processed_img_bytes,
                    keep_proportion=True,
                    overlay=True,
                )

        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(str(output_path), deflate=True, garbage=3)
        return output_path

    except Exception:
        raise
    finally:
        doc.close()
