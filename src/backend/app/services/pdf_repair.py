import os
import shutil
import tempfile
import subprocess
import pymupdf


def repair_pdf(file_bytes: bytes) -> tuple[bool, bytes, str | None]:
    """
    Attempts automated repair on corrupted or damaged PDF file bytes.
    1. Fixes common stream issues (e.g. leading junk bytes before %PDF- header, missing %%EOF).
    2. Reconstructs PDF catalog & xref table using PyMuPDF garbage collection & stream cleaning.
    3. Attempts secondary CLI repair via qpdf if installed.

    Returns:
        tuple[bool, bytes, str | None]:
            - success: True if repaired or valid, False otherwise.
            - result_bytes: Repaired PDF bytes on success, original bytes on failure.
            - error_code: None on success, 'PDF_ENCRYPTED' or 'CORRUPTED_PDF_UNREPAIRABLE' on failure.
    """
    if not file_bytes:
        return False, file_bytes, "CORRUPTED_PDF_UNREPAIRABLE"

    candidate_bytes = file_bytes

    # Pre-repair Step A: Trim prepended non-PDF junk bytes before %PDF- header
    pdf_header_idx = candidate_bytes.find(b"%PDF-")
    if pdf_header_idx > 0:
        candidate_bytes = candidate_bytes[pdf_header_idx:]

    # Pre-repair Step B: Ensure trailer %%EOF is present if truncated
    if b"%PDF-" in candidate_bytes and b"%%EOF" not in candidate_bytes:
        candidate_bytes = candidate_bytes + b"\n%%EOF\n"

    # Step 1: PyMuPDF Stream Reconstruction
    try:
        doc = pymupdf.open(stream=candidate_bytes, filetype="pdf")
        if doc.is_encrypted:
            doc.close()
            return False, file_bytes, "PDF_ENCRYPTED"

        repaired_bytes = doc.tobytes(garbage=4, deflate=True, clean=True)
        doc.close()

        # Validate repaired output
        check_doc = pymupdf.open(stream=repaired_bytes, filetype="pdf")
        if len(check_doc) == 0:
            check_doc.close()
            return False, file_bytes, "CORRUPTED_PDF_UNREPAIRABLE"
        check_doc.close()
        return True, repaired_bytes, None

    except Exception:
        pass

    # Step 2: Fallback via qpdf CLI if available
    qpdf_bin = shutil.which("qpdf")
    if qpdf_bin:
        try:
            with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as in_f:
                in_f.write(candidate_bytes)
                in_path = in_f.name
            out_path = in_path + "_repaired.pdf"

            try:
                cmd = [qpdf_bin, "--repair", in_path, out_path]
                res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
                if res.returncode in (0, 3) and os.path.exists(out_path):
                    with open(out_path, "rb") as out_f:
                        repaired_bytes = out_f.read()
                    check_doc = pymupdf.open(stream=repaired_bytes, filetype="pdf")
                    if len(check_doc) > 0:
                        check_doc.close()
                        return True, repaired_bytes, None
                    check_doc.close()
            finally:
                if os.path.exists(in_path):
                    os.remove(in_path)
                if os.path.exists(out_path):
                    os.remove(out_path)
        except Exception:
            pass

    return False, file_bytes, "CORRUPTED_PDF_UNREPAIRABLE"
