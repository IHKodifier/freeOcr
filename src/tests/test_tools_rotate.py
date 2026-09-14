import io
import json
from pathlib import Path
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_rotate_service import rotate_pdf_pages

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


# --- Unit Tests: rotate_pdf_pages Service ---


def test_rotate_pdf_pages_service_applies_rotation(tmp_path: Path):
    """Validates that rotate_pdf_pages applies rotation angles accurately."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2", "Page 3"])
    input_path = tmp_path / "input.pdf"
    output_path = tmp_path / "output.pdf"
    input_path.write_bytes(pdf_bytes)

    rotations = {0: 90, 1: 180, 2: 270}
    summary = rotate_pdf_pages(input_path, output_path, rotations)

    assert summary["modified_pages"] == 3
    assert output_path.exists()

    result_doc = fitz.open(str(output_path))
    assert result_doc[0].rotation == 90
    assert result_doc[1].rotation == 180
    assert result_doc[2].rotation == 270
    result_doc.close()


def test_rotate_pdf_pages_service_cumulative_and_negative_rotation(tmp_path: Path):
    """Validates negative rotations (e.g. -90 -> 270) and modulo 360 arithmetic."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2"])
    input_path = tmp_path / "input.pdf"
    output_path = tmp_path / "output.pdf"
    input_path.write_bytes(pdf_bytes)

    # -90 deg rotation on page 0 should yield 270 mod 360
    rotations = {0: -90, 1: 360}
    summary = rotate_pdf_pages(input_path, output_path, rotations)

    result_doc = fitz.open(str(output_path))
    assert result_doc[0].rotation == 270
    assert result_doc[1].rotation == 0
    result_doc.close()


def test_rotate_pdf_pages_service_invalid_angle_raises_value_error(tmp_path: Path):
    """Validates that angles that are not multiples of 90 raise ValueError."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1"])
    input_path = tmp_path / "input.pdf"
    output_path = tmp_path / "output.pdf"
    input_path.write_bytes(pdf_bytes)

    with pytest.raises(ValueError, match="multiple of 90"):
        rotate_pdf_pages(input_path, output_path, {0: 45})


def test_rotate_pdf_pages_service_out_of_bounds_page_raises_value_error(tmp_path: Path):
    """Validates that invalid page index raises ValueError."""
    pdf_bytes = create_mock_pdf_bytes(["Page 1"])
    input_path = tmp_path / "input.pdf"
    output_path = tmp_path / "output.pdf"
    input_path.write_bytes(pdf_bytes)

    with pytest.raises(ValueError, match="out of bounds"):
        rotate_pdf_pages(input_path, output_path, {5: 90})


# --- Integration Tests: POST /api/v1/tools/rotate ---


def test_rotate_endpoint_single_page_90_degrees():
    """AC: When submitting page 0 rotated 90 degrees, returned PDF has page 0 rotated to 90."""
    pdf = create_mock_pdf_bytes(["Page 1", "Page 2"])
    files = {"file": ("test_doc.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"rotations": json.dumps({"0": 90})}

    response = client.post("/api/v1/tools/rotate", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment; filename=" in response.headers.get("content-disposition", "")
    assert "test_doc_rotated.pdf" in response.headers.get("content-disposition", "")

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert result_doc[0].rotation == 90
    assert result_doc[1].rotation == 0
    result_doc.close()


def test_rotate_endpoint_multiple_pages():
    """AC: Submitting multiple page rotations applies all specified angles."""
    pdf = create_mock_pdf_bytes(["Page 1", "Page 2", "Page 3"])
    files = {"file": ("report.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"rotations": json.dumps({"0": 90, "1": 180, "2": 270})}

    response = client.post("/api/v1/tools/rotate", files=files, data=data)
    assert response.status_code == 200

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc[0].rotation == 90
    assert result_doc[1].rotation == 180
    assert result_doc[2].rotation == 270
    result_doc.close()


def test_rotate_endpoint_invalid_angle_returns_422():
    """AC: Submitting an angle of 45° returns HTTP 422 Unprocessable Entity."""
    pdf = create_mock_pdf_bytes(["Page 1"])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"rotations": json.dumps({"0": 45})}

    response = client.post("/api/v1/tools/rotate", files=files, data=data)
    assert response.status_code in (422, 400)
    assert "multiple of 90" in response.json().get("detail", "").lower() or "angle" in response.json().get("detail", "").lower()


def test_rotate_endpoint_out_of_bounds_page_returns_422():
    """AC: Submitting rotation for a page index beyond document length returns 422."""
    pdf = create_mock_pdf_bytes(["Page 1"])
    files = {"file": ("document.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"rotations": json.dumps({"10": 90})}

    response = client.post("/api/v1/tools/rotate", files=files, data=data)
    assert response.status_code in (422, 400)
    assert "out of bounds" in response.json().get("detail", "").lower() or "page" in response.json().get("detail", "").lower()


def test_rotate_endpoint_rejects_non_pdf():
    """AC: Non-PDF upload returns HTTP 400 Bad Request."""
    files = {"file": ("invalid.txt", io.BytesIO(b"Hello world"), "text/plain")}
    data = {"rotations": json.dumps({"0": 90})}

    response = client.post("/api/v1/tools/rotate", files=files, data=data)
    assert response.status_code == 400
    assert "pdf" in response.json().get("detail", "").lower()
