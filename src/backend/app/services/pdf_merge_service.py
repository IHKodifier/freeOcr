from pathlib import Path
import fitz  # PyMuPDF


def merge_pdfs(input_paths: list[Path], output_path: Path) -> dict:
    """
    Merges multiple PDF files in the specified sequential order using PyMuPDF.
    Applies stream deflation and level-3 garbage collection for clean compression.

    Args:
        input_paths: Ordered list of input PDF file paths.
        output_path: Target destination path for the merged PDF.

    Returns:
        Dictionary containing metadata: total_pages, output_bytes, page_counts_per_file.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)
    merged_doc = fitz.open()
    page_counts: list[int] = []

    for path in input_paths:
        src_doc = fitz.open(str(path))
        page_counts.append(len(src_doc))
        merged_doc.insert_pdf(src_doc)
        src_doc.close()

    total_pages = len(merged_doc)
    merged_doc.save(str(output_path), deflate=True, garbage=3)
    merged_doc.close()

    output_bytes = output_path.stat().st_size if output_path.exists() else 0

    return {
        "total_pages": total_pages,
        "output_bytes": output_bytes,
        "page_counts_per_file": page_counts,
    }
