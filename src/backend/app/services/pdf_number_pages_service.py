import logging
from pathlib import Path
from typing import Set

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)

VALID_POSITIONS: Set[str] = {
    "top-left",
    "top-center",
    "top-right",
    "bottom-left",
    "bottom-center",
    "bottom-right",
}


def number_pdf_pages(
    input_path: Path,
    output_path: Path,
    position: str = "bottom-center",
    format_str: str = "Page {n} of {total}",
    skip_first_page: bool = False,
    start_number: int = 1,
    font_size: float = 10.0,
    margin: float = 36.0,
) -> Path:
    """
    Applies formatted page numbers to pages of a PDF document at specified anchor positions.

    Args:
        input_path: Path to the source PDF file.
        output_path: Destination path for the generated numbered PDF.
        position: Alignment anchor: 'top-left', 'top-center', 'top-right',
                  'bottom-left', 'bottom-center', 'bottom-right'.
        format_str: Template string with '{n}' and optional '{total}' placeholders.
        skip_first_page: If True, leaves page 0 untouched and begins numbering on page 1.
        start_number: The starting number for the first numbered page (default 1).
        font_size: Size of the Helvetica font overlay (default 10.0pt).
        margin: Distance in points (72 pt/in) from page edges (default 36.0pt = 0.5in).

    Returns:
        Path to the output PDF file.

    Raises:
        ValueError: If PDF is empty or position is invalid.
        RuntimeError: If document processing fails.
    """
    pos = (position or "").strip().lower().replace("_", "-")
    if pos not in VALID_POSITIONS:
        raise ValueError(
            f"Invalid position: '{position}'. Supported positions: {', '.join(sorted(VALID_POSITIONS))}"
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

        # Compute total count of pages that will actually receive a number
        if skip_first_page and total_pages > 1:
            total_numbered = total_pages - 1
        else:
            total_numbered = total_pages

        total_display = start_number + total_numbered - 1

        box_height = max(font_size * 2.5, 20.0)

        for i in range(total_pages):
            if skip_first_page and i == 0:
                continue

            # Sequential number for current page
            page_offset = i - 1 if (skip_first_page and total_pages > 1) else i
            n_val = start_number + page_offset

            # Build text string
            template = format_str if format_str and format_str.strip() else "Page {n}"
            text_str = template.replace("{n}", str(n_val)).replace("{total}", str(total_display))

            page = doc[i]
            page_rect = page.rect
            w = page_rect.width
            h = page_rect.height

            # Determine vertical coordinate bounds
            if pos.startswith("top"):
                y0 = margin
                y1 = margin + box_height
            else:
                y0 = h - margin - box_height
                y1 = h - margin

            # Determine horizontal bounds and text alignment
            if pos.endswith("left"):
                box_rect = fitz.Rect(margin, y0, min(margin + 350.0, w - margin), y1)
                align = fitz.TEXT_ALIGN_LEFT
            elif pos.endswith("right"):
                box_rect = fitz.Rect(max(margin, w - margin - 350.0), y0, w - margin, y1)
                align = fitz.TEXT_ALIGN_RIGHT
            else:  # center
                box_rect = fitz.Rect(margin, y0, w - margin, y1)
                align = fitz.TEXT_ALIGN_CENTER

            # Insert textbox with Helvetica font
            page.insert_textbox(
                box_rect,
                text_str,
                fontsize=font_size,
                fontname="helv",
                align=align,
                color=(0.15, 0.15, 0.15),
            )

        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(str(output_path), deflate=True, garbage=3)
        return output_path

    except Exception:
        raise
    finally:
        doc.close()
