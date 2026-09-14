import logging
from pathlib import Path
from typing import Any, Dict, List

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)


def delete_pdf_pages(
    input_path: Path,
    output_path: Path,
    pages_to_delete: List[int],
) -> Dict[str, Any]:
    """
    Deletes specified 0-indexed pages from a PDF document and saves the pruned result.

    Args:
        input_path: Path to the source PDF file.
        output_path: Path where the pruned PDF will be saved.
        pages_to_delete: List of 0-indexed page numbers to delete.

    Returns:
        Dictionary summarizing deletion count, remaining pages, and original page count.

    Raises:
        ValueError: If page index is out of bounds, or if deletion of all pages is requested.
        RuntimeError: If PDF loading or saving fails.
    """
    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF document %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    total_pages = len(doc)

    # Validate and normalize page indices
    parsed_indices: List[int] = []
    for raw_p in pages_to_delete:
        try:
            page_idx = int(raw_p)
        except (ValueError, TypeError):
            doc.close()
            raise ValueError(f"Page index '{raw_p}' is not a valid integer.")

        if page_idx < 0 or page_idx >= total_pages:
            doc.close()
            raise ValueError(
                f"Page index {page_idx} is out of bounds (document contains {total_pages} pages, valid range: 0 to {total_pages - 1})."
            )
        parsed_indices.append(page_idx)

    unique_pages = sorted(list(set(parsed_indices)))

    if len(unique_pages) >= total_pages:
        doc.close()
        raise ValueError("Cannot delete all pages from a PDF. A PDF must retain at least one page.")

    # Delete pages in descending order to avoid shifting subsequent indices
    for p in sorted(unique_pages, reverse=True):
        doc.delete_page(p)

    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(str(output_path), deflate=True, garbage=3)
    except Exception as exc:
        logger.error("Failed to save pruned PDF document to %s: %s", output_path, exc)
        raise RuntimeError(f"Failed to save pruned PDF document: {exc}") from exc
    finally:
        doc.close()

    return {
        "deleted_pages_count": len(unique_pages),
        "remaining_pages_count": total_pages - len(unique_pages),
        "total_original_pages": total_pages,
        "deleted_indices": unique_pages,
    }
