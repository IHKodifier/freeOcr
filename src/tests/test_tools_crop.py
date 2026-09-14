import io
from pathlib import Path
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_crop_service import crop_pdf

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


# --- Unit Tests: Crop Service ---


def test_crop_pdf_applies_new_cropbox_dimensions(tmp_path: Path):
    """
    AC: Asserts cropped document has its /CropBox updated according to margins.
    """
    pdf_bytes = create_mock_pdf_bytes(["Page 1 Content", "Page 2 Content"], width=600.0, height=800.0)
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_cropped.pdf"

    result = crop_pdf(
        input_path=input_path,
        output_path=output_path,
        left=50.0,
        top=40.0,
        right=30.0,
        bottom=20.0,
        apply_to_all=True,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    assert doc.page_count == 2

    for page in doc:
        rect = page.cropbox
        assert rect.x0 == pytest.approx(50.0)
        assert rect.y0 == pytest.approx(40.0)
        assert rect.x1 == pytest.approx(570.0)  # 600 - 30
        assert rect.y1 == pytest.approx(780.0)  # 800 - 20
        assert rect.width == pytest.approx(520.0)
        assert rect.height == pytest.approx(740.0)
    doc.close()


def test_crop_pdf_preserves_vector_and_text(tmp_path: Path):
    """
    AC: Verifies underlying text and paths remain intact inside the document.
    """
    orig_text = "Important Financial Report 2026"
    pdf_bytes = create_mock_pdf_bytes([orig_text])
    input_path = tmp_path / "input_text.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_text.pdf"

    result = crop_pdf(
        input_path=input_path,
        output_path=output_path,
        left=20.0,
        top=20.0,
        right=20.0,
        bottom=20.0,
    )

    doc = fitz.open(str(result))
    text = doc[0].get_text()
    assert orig_text in text
    doc.close()


def test_crop_pdf_excessive_margins_raises_value_error(tmp_path: Path):
    """
    AC: Verifies margins equal to or greater than page width/height raise ValueError.
    """
    pdf_bytes = create_mock_pdf_bytes(["Sample"], width=300.0, height=400.0)
    input_path = tmp_path / "input_exceed.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_exceed.pdf"

    # Total width margin 320 >= 300
    with pytest.raises(ValueError, match="exceed page dimensions"):
        crop_pdf(
            input_path=input_path,
            output_path=output_path,
            left=200.0,
            right=120.0,
            top=10.0,
            bottom=10.0,
        )

    # Negative margin
    with pytest.raises(ValueError, match="cannot be negative"):
        crop_pdf(
            input_path=input_path,
            output_path=output_path,
            left=-10.0,
        )


def test_crop_pdf_single_page_vs_all_pages(tmp_path: Path):
    """
    AC: Cropping target_page=0 modifies page 0 while leaving page 1 unchanged when apply_to_all=False.
    """
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2"], width=500.0, height=500.0)
    input_path = tmp_path / "input_multi.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_single.pdf"

    result = crop_pdf(
        input_path=input_path,
        output_path=output_path,
        left=50.0,
        top=50.0,
        right=50.0,
        bottom=50.0,
        apply_to_all=False,
        target_page=0,
    )

    doc = fitz.open(str(result))
    # Page 0 cropped
    assert doc[0].cropbox.width == pytest.approx(400.0)
    assert doc[0].cropbox.height == pytest.approx(400.0)
    # Page 1 unchanged
    assert doc[1].cropbox.width == pytest.approx(500.0)
    assert doc[1].cropbox.height == pytest.approx(500.0)
    doc.close()


# --- Integration Tests: /api/v1/tools/crop Endpoint ---


def test_crop_endpoint_success():
    """
    AC: POST /api/v1/tools/crop returns HTTP 200 and a valid cropped PDF stream.
    """
    pdf_bytes = create_mock_pdf_bytes(["Test Page 1", "Test Page 2"], width=600.0, height=800.0)
    files = {"file": ("test_doc.pdf", pdf_bytes, "application/pdf")}
    data = {
        "left": "36.0",
        "top": "36.0",
        "right": "36.0",
        "bottom": "36.0",
        "apply_to_all": "true",
    }

    response = client.post("/api/v1/tools/crop", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "test_doc_cropped.pdf" in response.headers.get("content-disposition", "")

    # Check output bytes
    out_doc = fitz.open(stream=response.content, filetype="pdf")
    assert out_doc.page_count == 2
    assert out_doc[0].cropbox.width == pytest.approx(528.0)  # 600 - 72
    assert out_doc[0].cropbox.height == pytest.approx(728.0)  # 800 - 72
    out_doc.close()


def test_crop_endpoint_non_pdf_returns_400():
    """
    AC: Uploading non-PDF file returns HTTP 400 Bad Request.
    """
    files = {"file": ("notes.txt", b"plain text", "text/plain")}
    data = {"left": "10.0"}

    response = client.post("/api/v1/tools/crop", files=files, data=data)
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]


def test_crop_endpoint_excessive_margins_returns_422():
    """
    AC: Margins exceeding PDF boundaries return HTTP 422 Unprocessable Entity.
    """
    pdf_bytes = create_mock_pdf_bytes(["Small Page"], width=200.0, height=200.0)
    files = {"file": ("small.pdf", pdf_bytes, "application/pdf")}
    data = {
        "left": "150.0",
        "right": "150.0",  # total width margin 300 > 200
    }

    response = client.post("/api/v1/tools/crop", files=files, data=data)
    assert response.status_code == 422
    assert "exceed page dimensions" in response.json()["detail"]
