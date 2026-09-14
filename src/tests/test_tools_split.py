import io
import zipfile
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_split_service import parse_page_ranges

client = TestClient(app)


def create_mock_pdf_bytes(page_texts: list[str]) -> bytes:
    """Helper to generate a minimal valid in-memory PDF with specified page text."""
    doc = fitz.open()
    for text in page_texts:
        page = doc.new_page(width=595, height=842)  # A4
        page.insert_text((50, 100), text, fontsize=14)
    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


# --- Unit Tests: parse_page_ranges helper ---


def test_parse_page_ranges_valid_syntax():
    """Validates that valid expressions produce correct 0-indexed page groupings."""
    # 1-3, 5 on a 10-page document -> [[0, 1, 2], [4]]
    result = parse_page_ranges("1-3, 5", max_pages=10)
    assert result == [[0, 1, 2], [4]]

    # Single page
    result = parse_page_ranges("4", max_pages=10)
    assert result == [[3]]

    # Multiple disjoint ranges and single pages
    result = parse_page_ranges("1, 3-4, 7-8", max_pages=10)
    assert result == [[0], [2, 3], [6, 7]]


def test_parse_page_ranges_out_of_bounds_raises_error():
    """Validates that out-of-bounds page numbers raise ValueError."""
    with pytest.raises(ValueError, match="out of bounds"):
        parse_page_ranges("1-15", max_pages=10)

    with pytest.raises(ValueError, match="out of bounds"):
        parse_page_ranges("12", max_pages=10)

    with pytest.raises(ValueError, match="at least 1"):
        parse_page_ranges("0-3", max_pages=10)


def test_parse_page_ranges_invalid_syntax_raises_error():
    """Validates that malformed range strings raise ValueError."""
    with pytest.raises(ValueError):
        parse_page_ranges("abc", max_pages=10)

    with pytest.raises(ValueError):
        parse_page_ranges("5-2", max_pages=10)

    with pytest.raises(ValueError):
        parse_page_ranges("1-2-3", max_pages=10)

    with pytest.raises(ValueError):
        parse_page_ranges("", max_pages=10)


# --- Integration Tests: POST /api/v1/tools/split ---


def test_split_single_range_returns_pdf():
    """AC: When splitting with a single range, system returns a standalone PDF."""
    pdf = create_mock_pdf_bytes([f"Page {i+1}" for i in range(5)])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "ranges", "ranges": "2-3"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment; filename=" in response.headers.get("content-disposition", "")

    # Open returned PDF and verify exactly 2 pages
    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert "Page 2" in result_doc[0].get_text()
    assert "Page 3" in result_doc[1].get_text()
    result_doc.close()


def test_split_multi_range_returns_zip_with_expected_files():
    """AC: Splitting with multiple ranges returns a clean ZIP archive of split PDFs."""
    pdf = create_mock_pdf_bytes([f"Page {i+1}" for i in range(10)])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "ranges", "ranges": "1-2, 5"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"
    assert "attachment; filename=" in response.headers.get("content-disposition", "")

    # Inspect ZIP contents
    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        namelist = sorted(z.namelist())
        assert len(namelist) == 2
        # Check first range (pages 1-2)
        pdf1_bytes = z.read(namelist[0])
        doc1 = fitz.open(stream=pdf1_bytes, filetype="pdf")
        assert doc1.page_count == 2
        assert "Page 1" in doc1[0].get_text()
        assert "Page 2" in doc1[1].get_text()
        doc1.close()

        # Check second range (page 5)
        pdf2_bytes = z.read(namelist[1])
        doc2 = fitz.open(stream=pdf2_bytes, filetype="pdf")
        assert doc2.page_count == 1
        assert "Page 5" in doc2[0].get_text()
        doc2.close()


def test_split_fixed_mode_returns_zip():
    """AC: Splitting every N pages produces a ZIP archive of chunked PDFs."""
    pdf = create_mock_pdf_bytes([f"Page {i+1}" for i in range(5)])
    files = {"file": ("report.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "fixed", "split_every": 2}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"

    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        assert len(z.namelist()) == 3  # (1-2), (3-4), (5)


def test_split_all_mode_returns_zip():
    """AC: Extracting all pages produces a ZIP with each individual page as a separate PDF."""
    pdf = create_mock_pdf_bytes(["Page 1", "Page 2", "Page 3"])
    files = {"file": ("manual.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "all"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"

    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        assert len(z.namelist()) == 3


def test_split_invalid_syntax_returns_422():
    """AC: Malformed range expressions return HTTP 422 with descriptive detail."""
    pdf = create_mock_pdf_bytes([f"Page {i+1}" for i in range(5)])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "ranges", "ranges": "not-a-range"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 422
    assert "detail" in response.json()


def test_split_out_of_bounds_returns_422():
    """AC: Requesting pages beyond the document length returns HTTP 422."""
    pdf = create_mock_pdf_bytes([f"Page {i+1}" for i in range(5)])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"mode": "ranges", "ranges": "1-10"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 422
    assert "out of bounds" in response.json()["detail"].lower()


def test_split_rejects_non_pdf_file():
    """AC: Non-PDF uploads are rejected with HTTP 400."""
    files = {"file": ("doc.txt", io.BytesIO(b"Not a PDF"), "text/plain")}
    data = {"mode": "all"}

    response = client.post("/api/v1/tools/split", files=files, data=data)
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]
