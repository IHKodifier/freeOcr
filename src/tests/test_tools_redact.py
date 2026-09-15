import io
import json
from pathlib import Path
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_redact_service import redact_pdf

client = TestClient(app)


def create_mock_pdf_bytes(page_texts: list[str], width: float = 595.0, height: float = 842.0) -> bytes:
    """Helper to generate a minimal valid in-memory PDF with specified page text."""
    doc = fitz.open()
    for text in page_texts:
        page = doc.new_page(width=width, height=height)
        page.insert_text((50, 100), text, fontsize=14)
    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


# --- Unit Tests: Redact Service ---


def test_redact_text_phrase_purges_glyphs(tmp_path: Path):
    """
    AC: Asserts redacted text is cryptographically purged from the document stream.
    Extracted text search ('get_text()') must return 0 matches for redacted phrase.
    """
    target_phrase = "CONFIDENTIAL_KEY"
    pdf_bytes = create_mock_pdf_bytes([f"Header line\n{target_phrase}\nFooter line", f"Page 2 without target"])
    input_path = tmp_path / "input_secret.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_secret.pdf"

    meta = redact_pdf(
        input_path=input_path,
        output_path=output_path,
        search_phrase=target_phrase,
    )

    assert output_path.exists()
    assert meta["redaction_count"] >= 1
    assert meta["pages_modified"] >= 1

    doc = fitz.open(str(output_path))
    assert doc.page_count == 2
    first_page_text = doc[0].get_text()
    assert target_phrase not in first_page_text
    assert "Header line" in first_page_text
    assert "Footer line" in first_page_text

    # Search explicitly on page object
    search_hits = doc[0].search_for(target_phrase)
    assert len(search_hits) == 0
    doc.close()


def test_redact_preserves_unrelated_text(tmp_path: Path):
    """
    AC: Verifies un-redacted text on the same and other pages remains intact.
    """
    safe_text = "Safe Public Information 2026"
    secret_text = "TOP_SECRET_REPORT"
    pdf_bytes = create_mock_pdf_bytes([f"{safe_text}\n{secret_text}"])
    input_path = tmp_path / "input_preserve.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_preserve.pdf"

    redact_pdf(
        input_path=input_path,
        output_path=output_path,
        search_phrase=secret_text,
    )

    doc = fitz.open(str(output_path))
    text = doc[0].get_text()
    assert secret_text not in text
    assert safe_text in text
    doc.close()


def test_redact_case_sensitivity(tmp_path: Path):
    """
    AC: Verifies case_sensitive flag distinguishes uppercase vs lowercase strings.
    """
    pdf_bytes = create_mock_pdf_bytes(["Password: MySecretPassword and mysecretpassword"])
    input_path = tmp_path / "input_case.pdf"
    input_path.write_bytes(pdf_bytes)
    output_case_sensitive = tmp_path / "output_case_sensitive.pdf"
    output_case_insensitive = tmp_path / "output_case_insensitive.pdf"

    # Case-sensitive redaction of 'MySecretPassword' only
    redact_pdf(
        input_path=input_path,
        output_path=output_case_sensitive,
        search_phrase="MySecretPassword",
        case_sensitive=True,
    )

    doc1 = fitz.open(str(output_case_sensitive))
    text1 = doc1[0].get_text()
    assert "MySecretPassword" not in text1
    assert "mysecretpassword" in text1
    doc1.close()

    # Case-insensitive redaction: both should be purged
    redact_pdf(
        input_path=input_path,
        output_path=output_case_insensitive,
        search_phrase="MySecretPassword",
        case_sensitive=False,
    )

    doc2 = fitz.open(str(output_case_insensitive))
    text2 = doc2[0].get_text()
    assert "MySecretPassword" not in text2
    assert "mysecretpassword" not in text2
    doc2.close()


def test_redact_rect_coordinates(tmp_path: Path):
    """
    AC: Verifies coordinate-based redaction removes glyphs under specified bounding rect.
    """
    pdf_bytes = create_mock_pdf_bytes(["RedactThisBox\nKeepThisBox"])
    input_path = tmp_path / "input_rect.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_rect.pdf"

    # Find approximate rect of RedactThisBox
    doc = fitz.open(str(input_path))
    hits = doc[0].search_for("RedactThisBox")
    assert len(hits) > 0
    hit = hits[0]
    doc.close()

    rects = [{
        "page_index": 0,
        "x0": hit.x0,
        "y0": hit.y0,
        "x1": hit.x1,
        "y1": hit.y1,
    }]

    meta = redact_pdf(
        input_path=input_path,
        output_path=output_path,
        rects=rects,
    )

    assert meta["redaction_count"] == 1
    doc_out = fitz.open(str(output_path))
    out_text = doc_out[0].get_text()
    assert "RedactThisBox" not in out_text
    assert "KeepThisBox" in out_text
    doc_out.close()


def test_redact_missing_parameters_raises_value_error(tmp_path: Path):
    """
    AC: Verifies ValueError when neither search_phrase nor rects are specified.
    """
    pdf_bytes = create_mock_pdf_bytes(["Test Content"])
    input_path = tmp_path / "input_empty.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_empty.pdf"

    with pytest.raises(ValueError, match="At least one redaction target"):
        redact_pdf(
            input_path=input_path,
            output_path=output_path,
            search_phrase=None,
            rects=None,
        )


# --- Integration Tests: REST Endpoint ---


def test_redact_endpoint_success():
    """
    AC: POST /api/v1/tools/redact returns HTTP 200 with sanitized PDF stream.
    """
    pdf_bytes = create_mock_pdf_bytes(["Confidential Medical Record: John Doe"])
    files = {
        "file": ("medical_records.pdf", io.BytesIO(pdf_bytes), "application/pdf"),
    }
    data = {
        "search_phrase": "John Doe",
        "case_sensitive": "false",
    }

    response = client.post("/api/v1/tools/redact", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment" in response.headers.get("content-disposition", "") or "inline" in response.headers.get("content-disposition", "") or "filename=" in response.headers.get("content-disposition", "")

    # Inspect downloaded bytes
    doc = fitz.open(stream=response.content, filetype="pdf")
    text = doc[0].get_text()
    assert "John Doe" not in text
    assert "Confidential Medical Record:" in text
    doc.close()


def test_redact_endpoint_rects_success():
    """
    AC: POST /api/v1/tools/redact accepts rects_json and applies redactions.
    """
    pdf_bytes = create_mock_pdf_bytes(["SSN: 000-11-2222"])
    rects = [{
        "page_index": 0,
        "x0": 50.0,
        "y0": 90.0,
        "x1": 200.0,
        "y1": 110.0,
    }]
    files = {
        "file": ("ssn_doc.pdf", io.BytesIO(pdf_bytes), "application/pdf"),
    }
    data = {
        "rects_json": json.dumps(rects),
    }

    response = client.post("/api/v1/tools/redact", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"


def test_redact_endpoint_no_targets_returns_400():
    """
    AC: POST /api/v1/tools/redact returns HTTP 400 Bad Request when no targets provided.
    """
    pdf_bytes = create_mock_pdf_bytes(["Sample"])
    files = {
        "file": ("doc.pdf", io.BytesIO(pdf_bytes), "application/pdf"),
    }
    # Neither search_phrase nor rects_json
    response = client.post("/api/v1/tools/redact", files=files, data={})
    assert response.status_code == 400
    assert "redaction target" in response.json()["detail"].lower()


def test_redact_endpoint_non_pdf_returns_400():
    """
    AC: POST /api/v1/tools/redact returns HTTP 400 when non-pdf is uploaded.
    """
    files = {
        "file": ("notes.txt", io.BytesIO(b"Just plain text"), "text/plain"),
    }
    data = {
        "search_phrase": "text",
    }
    response = client.post("/api/v1/tools/redact", files=files, data=data)
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]
