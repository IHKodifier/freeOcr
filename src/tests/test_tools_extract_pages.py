import io
import json
from pathlib import Path
import zipfile
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_extract_pages_service import (
    extract_pdf_pages,
    parse_extract_page_numbers,
)

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


# --- Unit Tests: Service & Parsing ---


def test_parse_extract_page_numbers_valid_cases():
    """Verifies parsing of comma-separated numbers, ranges, and json arrays into 0-indexed ints."""
    assert parse_extract_page_numbers("1, 3, 5", max_pages=5) == [0, 2, 4]
    assert parse_extract_page_numbers("2-4", max_pages=5) == [1, 2, 3]
    assert parse_extract_page_numbers("1, 3-4", max_pages=5) == [0, 2, 3]
    assert parse_extract_page_numbers([1, 3], max_pages=5) == [0, 2]
    assert parse_extract_page_numbers(json.dumps([2, 4]), max_pages=5) == [1, 3]


def test_parse_extract_page_numbers_deduplicates_and_sorts():
    """Verifies duplicates are eliminated while keeping ascending order."""
    assert parse_extract_page_numbers("3, 1, 3, 2-3", max_pages=5) == [0, 1, 2]


def test_parse_extract_page_numbers_out_of_bounds_raises_value_error():
    """Out of bounds page raises ValueError."""
    with pytest.raises(ValueError, match="out of bounds"):
        parse_extract_page_numbers("99", max_pages=3)
    with pytest.raises(ValueError, match="at least 1"):
        parse_extract_page_numbers("0", max_pages=3)


def test_parse_extract_page_numbers_empty_raises_value_error():
    """Empty or whitespace input raises ValueError."""
    with pytest.raises(ValueError, match="cannot be empty"):
        parse_extract_page_numbers("", max_pages=3)
    with pytest.raises(ValueError, match="cannot be empty"):
        parse_extract_page_numbers("   ", max_pages=3)


def test_extract_pages_merged_produces_correct_page_count(tmp_path: Path):
    """AC: Extracts pages [1, 3] from 5-page PDF into single PDF; asserts output has exactly 2 pages."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2", "Page 3", "Page 4", "Page 5"])
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_dir = tmp_path / "output_merged"

    result_path = extract_pdf_pages(
        input_path=input_path,
        pages_to_extract=[1, 3],  # 1-indexed: Page 1 and Page 3
        mode="merged",
        output_dir=output_dir,
        base_name="Doc",
    )

    assert result_path.exists()
    assert result_path.suffix.lower() == ".pdf"

    result_doc = fitz.open(str(result_path))
    assert result_doc.page_count == 2
    assert "Page 1" in result_doc[0].get_text()
    assert "Page 3" in result_doc[1].get_text()
    result_doc.close()


def test_extract_pages_separate_produces_zip(tmp_path: Path):
    """AC: Extracts pages [1, 3] with mode 'separate'; asserts ZIP contains 2 PDF files."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2", "Page 3", "Page 4", "Page 5"])
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_dir = tmp_path / "output_separate"

    result_path = extract_pdf_pages(
        input_path=input_path,
        pages_to_extract=[1, 3],
        mode="separate",
        output_dir=output_dir,
        base_name="Document",
    )

    assert result_path.exists()
    assert result_path.suffix.lower() == ".zip"

    with zipfile.ZipFile(result_path, "r") as z:
        namelist = [n for n in z.namelist() if n.endswith(".pdf")]
        assert len(namelist) == 2

        # Check content of first extracted page
        page1_data = z.read(namelist[0])
        doc1 = fitz.open(stream=page1_data, filetype="pdf")
        assert doc1.page_count == 1
        assert "Page 1" in doc1[0].get_text()
        doc1.close()

        # Check content of second extracted page
        page3_data = z.read(namelist[1])
        doc2 = fitz.open(stream=page3_data, filetype="pdf")
        assert doc2.page_count == 1
        assert "Page 3" in doc2[0].get_text()
        doc2.close()


# --- Integration Tests: POST /api/v1/tools/extract-pages ---


def test_extract_invalid_pages_returns_422():
    """AC: Requesting page 99 on a 3-page document returns HTTP 422."""
    pdf = create_mock_pdf_bytes(["P1", "P2", "P3"])
    files = {"file": ("test.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"pages": "99", "output_mode": "merged"}

    response = client.post("/api/v1/tools/extract-pages", files=files, data=data)
    assert response.status_code == 422
    assert "out of bounds" in response.json().get("detail", "").lower()


def test_extract_endpoint_merged_produces_pdf():
    """Verifies endpoint returns merged PDF with correct content and headers."""
    pdf = create_mock_pdf_bytes(["One", "Two", "Three", "Four"])
    files = {"file": ("sample.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"pages": "2, 4", "output_mode": "merged"}

    response = client.post("/api/v1/tools/extract-pages", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "sample_extracted.pdf" in response.headers.get("content-disposition", "")

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert "Two" in result_doc[0].get_text()
    assert "Four" in result_doc[1].get_text()
    result_doc.close()


def test_extract_endpoint_separate_produces_zip():
    """Verifies endpoint returns ZIP archive containing separate extracted pages."""
    pdf = create_mock_pdf_bytes(["Alpha", "Beta", "Gamma"])
    files = {"file": ("notes.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"pages": "1, 3", "output_mode": "separate"}

    response = client.post("/api/v1/tools/extract-pages", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] in ["application/zip", "application/x-zip-compressed"]
    assert "notes_extracted_pages.zip" in response.headers.get("content-disposition", "")

    with zipfile.ZipFile(io.BytesIO(response.content), "r") as z:
        pdf_names = [n for n in z.namelist() if n.endswith(".pdf")]
        assert len(pdf_names) == 2


def test_extract_no_pages_returns_400():
    """Sending empty page specification returns HTTP 400 Bad Request."""
    pdf = create_mock_pdf_bytes(["A", "B"])
    files = {"file": ("test.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"pages": ""}

    response = client.post("/api/v1/tools/extract-pages", files=files, data=data)
    assert response.status_code == 400
    assert "no pages specified" in response.json().get("detail", "").lower()


def test_extract_non_pdf_returns_400():
    """Uploading non-PDF file returns HTTP 400 Bad Request."""
    files = {"file": ("data.txt", io.BytesIO(b"Hello world"), "text/plain")}
    data = {"pages": "1"}

    response = client.post("/api/v1/tools/extract-pages", files=files, data=data)
    assert response.status_code == 400
    assert "pdf" in response.json().get("detail", "").lower()
