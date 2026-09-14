import logging
from pathlib import Path
from typing import Any, Dict

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)


def rotate_pdf_pages(
    input_path: Path,
    output_path: Path,
    rotations: Dict[int, int],
) -> Dict[str, Any]:
    """
    Applies page-specific rotations to a PDF document and saves the result.

    Args:
        input_path: Absolute or relative path to the source PDF file.
        output_path: Destination path for the rotated PDF.
        rotations: Mapping of 0-indexed page number to rotation angle in degrees
                   (must be multiples of 90, e.g. 90, 180, 270, -90).

    Returns:
        Dictionary summarizing modified pages, total pages, and applied angles.

    Raises:
        ValueError: If page index is out of bounds or rotation angle is not a multiple of 90.
        RuntimeError: If PDF loading or saving fails.
    """
    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF document %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    total_pages = len(doc)

    # Validate inputs prior to applying changes
    for raw_idx, raw_angle in rotations.items():
        try:
            page_idx = int(raw_idx)
        except (ValueError, TypeError):
            doc.close()
            raise ValueError(f"Page index '{raw_idx}' is not a valid integer.")

        if page_idx < 0 or page_idx >= total_pages:
            doc.close()
            raise ValueError(
                f"Page index {page_idx} is out of bounds (document contains {total_pages} pages, valid range: 0 to {total_pages - 1})."
            )

        try:
            angle = int(raw_angle)
        except (ValueError, TypeError):
            doc.close()
            raise ValueError(f"Rotation angle '{raw_angle}' is not a valid integer.")

        if angle % 90 != 0:
            doc.close()
            raise ValueError(
                f"Rotation angle {angle}° must be a multiple of 90 degrees (e.g. 90, 180, 270)."
            )

    applied_count = 0
    # Apply rotations
    for raw_idx, raw_angle in rotations.items():
        page_idx = int(raw_idx)
        angle = int(raw_angle)
        page = doc[page_idx]
        current_rot = page.rotation
        new_rot = (current_rot + angle) % 360
        page.set_rotation(new_rot)
        applied_count += 1

    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(str(output_path), deflate=True, garbage=3)
    except Exception as exc:
        logger.error("Failed to save rotated PDF document to %s: %s", output_path, exc)
        raise RuntimeError(f"Failed to save rotated PDF document: {exc}") from exc
    finally:
        doc.close()

    return {
        "modified_pages": applied_count,
        "total_pages": total_pages,
        "rotations": {int(k): int(v) for k, v in rotations.items()},
    }
