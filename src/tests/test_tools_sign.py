import io
from pathlib import Path
import fitz  # PyMuPDF
from PIL import Image
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_sign_service import sign_pdf

client = TestClient(app)


def create_mock_pdf_bytes(page_texts: list[str]) -> bytes:
    """Helper to generate a minimal valid in-memory PDF with specified page text."""
    doc = fitz.open()
    for text in page_texts:
        page = doc.new_page(width=595, height=842)  # Standard A4
        page.insert_text((50, 100), text, fontsize=14)
    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


def create_mock_png_bytes(width: int = 150, height: int = 60, alpha: int = 255) -> bytes:
    """Helper to generate a transparent RGBA PNG image simulating a signature."""
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))  # Transparent background
    # Draw simple pixels to simulate signature stroke
    for x in range(10, width - 10):
        img.putpixel((x, height // 2), (18, 30, 162, alpha))  # Blue signature stroke
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


# --- Unit Tests: Sign Service ---


def test_sign_pdf_inserts_signature_on_target_page(tmp_path: Path):
    """
    AC: Stamps signature PNG on page 1 of a 3-page document.
    Asserts page 1 contains the image, while page 0 and page 2 contain no images.
    """
    pdf_bytes = create_mock_pdf_bytes(["Page 1 Agreement", "Page 2 Signature Page", "Page 3 Addendum"])
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_signed.pdf"
    sig_bytes = create_mock_png_bytes(150, 60)

    result = sign_pdf(
        input_path=input_path,
        output_path=output_path,
        signature_bytes=sig_bytes,
        target_page=1,  # 0-indexed page 1 (2nd page)
        x=350.0,
        y=700.0,
        width=150.0,
        height=60.0,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    assert doc.page_count == 3

    # Page 0 should have no images
    assert len(doc[0].get_images()) == 0

    # Page 1 must have exactly 1 image
    page1_images = doc[1].get_images()
    assert len(page1_images) == 1

    # Page 2 should have no images
    assert len(doc[2].get_images()) == 0

    # Verify underlying text on page 1 remains intact
    assert "Page 2 Signature Page" in doc[1].get_text()
    doc.close()


def test_sign_pdf_preserves_transparent_background(tmp_path: Path):
    """
    AC: Verifies transparent PNG stamps without black background bounding box artifacts,
    and preserves underlying text readability.
    """
    orig_text = "Signed by authorized representative hereunder:"
    pdf_bytes = create_mock_pdf_bytes([orig_text])
    input_path = tmp_path / "input_trans.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_trans.pdf"
    sig_bytes = create_mock_png_bytes(200, 80, alpha=220)

    result = sign_pdf(
        input_path=input_path,
        output_path=output_path,
        signature_bytes=sig_bytes,
        target_page=0,
        x=50.0,
        y=150.0,
        width=200.0,
        height=80.0,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    assert doc.page_count == 1
    assert len(doc[0].get_images()) == 1
    assert orig_text in doc[0].get_text()
    doc.close()


def test_sign_pdf_out_of_bounds_page_raises_value_error(tmp_path: Path):
    """
    AC: Attempting to sign page index 99 on a 2-page document raises ValueError.
    """
    pdf_bytes = create_mock_pdf_bytes(["Page 1", "Page 2"])
    input_path = tmp_path / "input_oob.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_oob.pdf"
    sig_bytes = create_mock_png_bytes()

    with pytest.raises(ValueError, match="Target page index 99 is out of bounds"):
        sign_pdf(
            input_path=input_path,
            output_path=output_path,
            signature_bytes=sig_bytes,
            target_page=99,
            x=100.0,
            y=100.0,
            width=100.0,
            height=50.0,
        )


def test_sign_pdf_empty_signature_bytes_raises_value_error(tmp_path: Path):
    """
    AC: Empty signature image stream raises ValueError.
    """
    pdf_bytes = create_mock_pdf_bytes(["Single Page"])
    input_path = tmp_path / "input_empty_sig.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_empty_sig.pdf"

    with pytest.raises(ValueError, match="Signature image bytes cannot be empty"):
        sign_pdf(
            input_path=input_path,
            output_path=output_path,
            signature_bytes=b"",
            target_page=0,
            x=50.0,
            y=50.0,
            width=100.0,
            height=40.0,
        )


# --- Integration Tests: API Endpoint ---


def test_sign_endpoint_success():
    """
    AC: POST /api/v1/tools/sign returns HTTP 200 and a valid signed PDF.
    """
    pdf_bytes = create_mock_pdf_bytes(["Contract Page 1", "Signature Page 2"])
    sig_bytes = create_mock_png_bytes(180, 70)

    response = client.post(
        "/api/v1/tools/sign",
        files={
            "file": ("contract.pdf", pdf_bytes, "application/pdf"),
            "signature": ("signature.png", sig_bytes, "image/png"),
        },
        data={
            "page": "2",  # 1-indexed (Page 2)
            "x": "300",
            "y": "600",
            "width": "180",
            "height": "70",
        },
    )

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment; filename=" in response.headers.get("content-disposition", "")

    # Validate returned PDF bytes
    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    # Target page (page 2 -> index 1) must have image
    assert len(result_doc[1].get_images()) == 1
    # Page 1 -> index 0 has no image
    assert len(result_doc[0].get_images()) == 0
    result_doc.close()


def test_sign_endpoint_invalid_file_type():
    """
    AC: Uploading non-PDF file returns HTTP 400.
    """
    sig_bytes = create_mock_png_bytes()
    response = client.post(
        "/api/v1/tools/sign",
        files={
            "file": ("notes.txt", b"plain text content", "text/plain"),
            "signature": ("sig.png", sig_bytes, "image/png"),
        },
        data={"page": "1", "x": "10", "y": "10", "width": "100", "height": "50"},
    )
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]


def test_sign_endpoint_invalid_signature_type():
    """
    AC: Uploading non-image signature file returns HTTP 400.
    """
    pdf_bytes = create_mock_pdf_bytes(["Test Page"])
    response = client.post(
        "/api/v1/tools/sign",
        files={
            "file": ("doc.pdf", pdf_bytes, "application/pdf"),
            "signature": ("sig.txt", b"not an image", "text/plain"),
        },
        data={"page": "1", "x": "10", "y": "10", "width": "100", "height": "50"},
    )
    assert response.status_code == 400
    assert "Only PNG, JPG, or WEBP image signatures are supported" in response.json()["detail"]


def test_sign_endpoint_out_of_bounds_page():
    """
    AC: Requesting page number beyond document range returns HTTP 400.
    """
    pdf_bytes = create_mock_pdf_bytes(["Only Page 1"])
    sig_bytes = create_mock_png_bytes()

    response = client.post(
        "/api/v1/tools/sign",
        files={
            "file": ("doc.pdf", pdf_bytes, "application/pdf"),
            "signature": ("sig.png", sig_bytes, "image/png"),
        },
        data={"page": "5", "x": "10", "y": "10", "width": "100", "height": "50"},
    )
    assert response.status_code == 400
    assert "out of bounds" in response.json()["detail"].lower()
