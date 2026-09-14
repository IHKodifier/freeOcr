import logging
from pathlib import Path
from typing import Optional

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)


def crop_pdf(
    input_path: Path,
    output_path: Path,
    left: float = 0.0,
    top: float = 0.0,
    right: float = 0.0,
    bottom: float = 0.0,
    apply_to_all: bool = True,
    target_page: int = 0,
) -> Path:
    """
    Applies margin cropping by updating page /CropBox dimensions without deleting
    underlying vector graphics, text layers, or embedded resources.

    Args:
        input_path: Path to source PDF document.
        output_path: Destination path for cropped PDF.
        left: Left margin trim in points.
        top: Top margin trim in points.
        right: Right margin trim in points.
        bottom: Bottom margin trim in points.
        apply_to_all: Whether to apply crop margins across all pages or target_page only.
        target_page: Zero-based page index to crop when apply_to_all is False.

    Returns:
        Path to the successfully generated cropped PDF.

    Raises:
        ValueError: If margins are negative, exceed page dimensions, or page is out of bounds.
        RuntimeError: If document processing fails.
    """
    if left < 0 or top < 0 or right < 0 or bottom < 0:
        raise ValueError("Crop margin values cannot be negative.")

    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    try:
        total_pages = len(doc)
        if total_pages == 0:
            raise ValueError("PDF document has 0 pages.")

        if apply_to_all:
            page_indices = list(range(total_pages))
        else:
            if target_page < 0 or target_page >= total_pages:
                raise ValueError(
                    f"Target page index {target_page} is out of bounds for document with {total_pages} pages."
                )
            page_indices = [target_page]

        for p_idx in page_indices:
            page = doc[p_idx]
            base_rect = page.rect

            new_x0 = base_rect.x0 + left
            new_y0 = base_rect.y0 + top
            new_x1 = base_rect.x1 - right
            new_y1 = base_rect.y1 - bottom

            remaining_w = new_x1 - new_x0
            remaining_h = new_y1 - new_y0

            if remaining_w <= 10 or remaining_h <= 10:
                raise ValueError(
                    f"Crop margins exceed page dimensions on page {p_idx + 1}. "
                    f"Remaining dimensions must be greater than 10pt (got width {remaining_w:.1f}pt, height {remaining_h:.1f}pt)."
                )

            new_crop_rect = fitz.Rect(new_x0, new_y0, new_x1, new_y1)
            page.set_cropbox(new_crop_rect)

        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(str(output_path), deflate=True, garbage=3)
        return output_path

    except Exception:
        raise
    finally:
        doc.close()
