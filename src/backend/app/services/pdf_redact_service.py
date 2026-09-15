import logging
from pathlib import Path
from typing import Any, Optional

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)


def redact_pdf(
    input_path: Path,
    output_path: Path,
    search_phrase: Optional[str] = None,
    rects: Optional[list[dict[str, Any]]] = None,
    case_sensitive: bool = False,
) -> dict[str, Any]:
    """
    Permanently redacts sensitive text glyphs, vector shapes, and raster pixel streams
    from a PDF document using true cryptographic sanitization (PyMuPDF apply_redactions).

    Args:
        input_path: Path to source PDF document.
        output_path: Destination path for the sanitized PDF.
        search_phrase: Optional text query to search and redact across all pages.
        rects: Optional list of bounding rectangles to redact. Each entry can be:
               {"page_index": int, "x0": float, "y0": float, "x1": float, "y1": float}
               or {"page_index": int, "rect": [x0, y0, x1, y1]}
        case_sensitive: Boolean flag whether text search should be strictly case-sensitive.

    Returns:
        Dictionary containing redaction summary:
        {"redaction_count": int, "pages_modified": int, "output_path": Path}

    Raises:
        ValueError: If PDF is empty or neither search_phrase nor rects are specified.
        RuntimeError: If document processing or saving fails.
    """
    clean_phrase = (search_phrase or "").strip()
    clean_rects = [r for r in (rects or []) if isinstance(r, dict)]

    if not clean_phrase and not clean_rects:
        raise ValueError("At least one redaction target (search_phrase or rects) must be specified.")

    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    try:
        total_pages = len(doc)
        if total_pages == 0:
            raise ValueError("PDF document has 0 pages.")

        total_redactions = 0
        pages_modified: set[int] = set()

        # 1. Apply keyword/phrase search redactions across all pages
        if clean_phrase:
            for page in doc:
                found_rects = page.search_for(clean_phrase)
                if case_sensitive:
                    # Filter for exact case match within the bounding rect
                    matched_rects = []
                    for r in found_rects:
                        box_text = page.get_textbox(r)
                        clip_text = page.get_text("text", clip=r)
                        if clean_phrase in box_text or clean_phrase in clip_text:
                            matched_rects.append(r)
                    found_rects = matched_rects

                for r in found_rects:
                    page.add_redact_annot(r, fill=(0, 0, 0))
                    total_redactions += 1
                    pages_modified.add(page.number)

        # 2. Apply coordinate-based rect redactions
        if clean_rects:
            for item in clean_rects:
                p_idx = int(item.get("page_index", 0))
                if p_idx < 0 or p_idx >= total_pages:
                    logger.warning("Skipping out-of-bounds page_index %s in rects", p_idx)
                    continue

                page = doc[p_idx]
                r_box = None
                if "rect" in item and isinstance(item["rect"], (list, tuple)) and len(item["rect"]) >= 4:
                    r_box = fitz.Rect(item["rect"][0], item["rect"][1], item["rect"][2], item["rect"][3])
                elif all(k in item for k in ("x0", "y0", "x1", "y1")):
                    r_box = fitz.Rect(item["x0"], item["y0"], item["x1"], item["y1"])

                if r_box is not None:
                    page.add_redact_annot(r_box, fill=(0, 0, 0))
                    total_redactions += 1
                    pages_modified.add(p_idx)

        # 3. Permanently apply redactions to purge glyphs and raster pixel streams
        for page in doc:
            page.apply_redactions(images=fitz.PDF_REDACT_IMAGE_PIXELS)

        output_path.parent.mkdir(parents=True, exist_ok=True)
        # deflate=True and garbage=4 ensures orphaned glyph objects and unused streams are purged
        doc.save(str(output_path), deflate=True, garbage=4)

        logger.info(
            "Successfully redacted PDF %s -> %s (redactions: %d, pages: %d)",
            input_path.name,
            output_path.name,
            total_redactions,
            len(pages_modified),
        )

        return {
            "redaction_count": total_redactions,
            "pages_modified": len(pages_modified),
            "output_path": output_path,
        }

    except Exception:
        raise
    finally:
        doc.close()
