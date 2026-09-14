import json
import logging
from pathlib import Path
from typing import List, Union
import zipfile

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)


def parse_extract_page_numbers(
    page_spec: Union[str, List[Union[int, str]]],
    max_pages: int,
) -> List[int]:
    """
    Parses a page selection specification (comma-separated, ranges like '2-4', JSON array, or list)
    into a sorted, deduplicated list of 0-indexed page numbers.

    Args:
        page_spec: Comma-separated string (e.g. '1, 3, 5-7'), JSON array, or integer list.
        max_pages: Total number of pages in the document for bounds checking.

    Returns:
        Sorted list of unique 0-indexed integers (e.g. [0, 2, 4, 5, 6]).

    Raises:
        ValueError: If input is empty, non-numeric, or contains out-of-bounds page numbers.
    """
    if page_spec is None:
        raise ValueError("Page range expression cannot be empty.")

    chunks: List[str] = []

    if isinstance(page_spec, list):
        for item in page_spec:
            s_item = str(item).strip()
            if s_item:
                chunks.append(s_item)
    elif isinstance(page_spec, str):
        s = page_spec.strip()
        if not s:
            raise ValueError("Page range expression cannot be empty.")

        # Check if it's a JSON array
        try:
            parsed = json.loads(s)
            if isinstance(parsed, list):
                for item in parsed:
                    s_item = str(item).strip()
                    if s_item:
                        chunks.append(s_item)
            else:
                chunks = [s]
        except Exception:
            # Comma-separated string
            chunks = [c.strip() for c in s.split(",") if c.strip()]
    else:
        raise ValueError(f"Unsupported page specification type: {type(page_spec)}")

    if not chunks:
        raise ValueError("Page range expression cannot be empty.")

    page_indices: set[int] = set()

    for chunk in chunks:
        if "-" in chunk:
            parts = chunk.split("-")
            if len(parts) != 2:
                raise ValueError(f"Invalid range syntax: '{chunk}'. Expected 'start-end'.")
            try:
                start = int(parts[0].strip())
                end = int(parts[1].strip())
            except ValueError:
                raise ValueError(f"Invalid non-integer range: '{chunk}'.")

            if start < 1:
                raise ValueError(f"Page numbers must be at least 1, got start page {start}.")
            if end < 1:
                raise ValueError(f"Page numbers must be at least 1, got end page {end}.")
            if start > end:
                raise ValueError(f"Invalid range '{chunk}': start page ({start}) cannot exceed end page ({end}).")
            if start > max_pages:
                raise ValueError(f"Start page {start} is out of bounds (document has {max_pages} pages).")
            if end > max_pages:
                raise ValueError(f"End page {end} is out of bounds (document has {max_pages} pages).")

            for p in range(start, end + 1):
                page_indices.add(p - 1)
        else:
            try:
                page_num = int(chunk)
            except ValueError:
                raise ValueError(f"Invalid non-integer page number: '{chunk}'.")

            if page_num < 1:
                raise ValueError(f"Page numbers must be at least 1, got {page_num}.")
            if page_num > max_pages:
                raise ValueError(f"Page {page_num} is out of bounds (document has {max_pages} pages).")

            page_indices.add(page_num - 1)

    if not page_indices:
        raise ValueError("No valid pages specified.")

    return sorted(list(page_indices))


def extract_pdf_pages(
    input_path: Path,
    pages_to_extract: Union[str, List[Union[int, str]]],
    mode: str,
    output_dir: Path,
    base_name: str = "Document",
) -> Path:
    """
    Extracts specified pages from a PDF document into a merged single PDF or separate PDFs in a ZIP archive.

    Args:
        input_path: Path to the source PDF file.
        pages_to_extract: 1-indexed page specification (e.g. [1, 3] or "1, 3-5").
        mode: Extraction mode: 'merged' (single PDF) or 'separate' (ZIP containing individual PDFs).
        output_dir: Target directory where output files will be created.
        base_name: Base stem for output files (e.g. 'Document').

    Returns:
        Path to the generated output file (.pdf or .zip).

    Raises:
        ValueError: If pages are invalid or out of bounds.
        RuntimeError: If document processing fails.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    clean_base = base_name.removesuffix(".pdf").removesuffix(".PDF")

    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    try:
        total_pages = len(doc)
        if total_pages == 0:
            raise ValueError("PDF document has 0 pages.")

        zero_indexed_pages = parse_extract_page_numbers(pages_to_extract, max_pages=total_pages)

        normalized_mode = (mode or "merged").strip().lower()

        if normalized_mode == "separate":
            # Generate individual single-page PDFs and bundle into ZIP
            single_page_files: List[Path] = []
            for p in zero_indexed_pages:
                page_number = p + 1
                out_single_name = f"{clean_base}_page_{page_number}.pdf"
                out_single_path = output_dir / out_single_name

                single_doc = fitz.open()
                single_doc.insert_pdf(doc, from_page=p, to_page=p)
                single_doc.save(str(out_single_path), deflate=True, garbage=3)
                single_doc.close()
                single_page_files.append(out_single_path)

            zip_path = output_dir / f"{clean_base}_extracted_pages.zip"
            with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as z:
                for f in single_page_files:
                    z.write(f, arcname=f.name)

            return zip_path
        else:
            # Mode "merged": save selected pages into a single PDF
            out_merged_name = f"{clean_base}_extracted.pdf"
            out_merged_path = output_dir / out_merged_name

            new_doc = fitz.open()
            for p in zero_indexed_pages:
                new_doc.insert_pdf(doc, from_page=p, to_page=p)

            new_doc.save(str(out_merged_path), deflate=True, garbage=3)
            new_doc.close()

            return out_merged_path

    except Exception:
        raise
    finally:
        doc.close()
