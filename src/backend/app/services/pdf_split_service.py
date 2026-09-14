from pathlib import Path
from typing import List, Optional
import zipfile
import fitz  # PyMuPDF


def parse_page_ranges(range_str: str, max_pages: int) -> List[List[int]]:
    """
    Parses a page range string (e.g. '1-3, 5, 8-10') into a list of 0-indexed page number lists.

    Args:
        range_str: Comma-separated range expression such as '1-3, 5'.
        max_pages: Total number of pages in the document for bounds checking.

    Returns:
        List of lists of 0-indexed page numbers (e.g. [[0, 1, 2], [4]]).

    Raises:
        ValueError: If range expression is invalid, non-numeric, or out of bounds.
    """
    if not range_str or not range_str.strip():
        raise ValueError("Page range expression cannot be empty.")

    chunks = [c.strip() for c in range_str.split(",") if c.strip()]
    if not chunks:
        raise ValueError("No valid page ranges found in expression.")

    result: List[List[int]] = []

    for chunk in chunks:
        if "-" in chunk:
            parts = chunk.split("-")
            if len(parts) != 2:
                raise ValueError(f"Invalid range syntax: '{chunk}'. Expected format 'start-end'.")
            try:
                start = int(parts[0].strip())
                end = int(parts[1].strip())
            except ValueError:
                raise ValueError(f"Invalid non-integer values in range: '{chunk}'.")

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

            result.append(list(range(start - 1, end)))
        else:
            try:
                page_num = int(chunk)
            except ValueError:
                raise ValueError(f"Invalid non-integer page number: '{chunk}'.")

            if page_num < 1:
                raise ValueError(f"Page numbers must be at least 1, got {page_num}.")
            if page_num > max_pages:
                raise ValueError(f"Page {page_num} is out of bounds (document has {max_pages} pages).")

            result.append([page_num - 1])

    return result


def create_zip_archive(files: List[Path], zip_path: Path) -> Path:
    """Creates a clean zip archive containing the provided files."""
    zip_path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as z:
        for f in files:
            z.write(f, arcname=f.name)
    return zip_path


def split_pdf(
    input_path: Path,
    ranges: List[List[int]],
    output_dir: Path,
    base_name: str = "Document",
) -> List[Path]:
    """
    Splits a PDF into separate files according to the provided 0-indexed page ranges.
    Applies stream deflation and garbage collection compression.
    If multiple files are produced, bundles them into a .zip archive.

    Args:
        input_path: Path to the source PDF.
        ranges: List of 0-indexed page index groupings.
        output_dir: Target directory where output files will be created.
        base_name: Base stem for output files (defaults to 'Document').

    Returns:
        List of generated Path objects. If multiple parts were generated,
        the list includes the individual PDFs as well as the final .zip archive path.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    src_doc = fitz.open(str(input_path))

    clean_base = base_name.removesuffix(".pdf").removesuffix(".PDF")
    output_files: List[Path] = []

    for group in ranges:
        if not group:
            continue
        if len(group) == 1:
            label = f"{group[0] + 1}"
        else:
            label = f"{group[0] + 1}-{group[-1] + 1}"

        out_name = f"{clean_base}_{label}.pdf"
        out_path = output_dir / out_name

        new_doc = fitz.open()
        for page_idx in group:
            new_doc.insert_pdf(src_doc, from_page=page_idx, to_page=page_idx)

        new_doc.save(str(out_path), deflate=True, garbage=3)
        new_doc.close()
        output_files.append(out_path)

    src_doc.close()

    if len(output_files) > 1:
        zip_path = output_dir / f"{clean_base}_split.zip"
        create_zip_archive(output_files, zip_path)
        return output_files + [zip_path]

    return output_files
