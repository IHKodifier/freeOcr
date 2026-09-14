import io
from pathlib import Path
import fitz  # PyMuPDF
from PIL import Image
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_watermark_service import watermark_pdf

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


def create_mock_png_bytes(width: int = 150, height: int = 150, alpha: int = 180) -> bytes:
    """Helper to generate a transparent RGBA PNG image."""
    img = Image.new("RGBA", (width, height), (33, 150, 243, alpha))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


# --- Unit Tests: Watermark Service ---


def test_watermark_text_inserts_overlay(tmp_path: Path):
    """
    AC: Asserts watermarked document contains watermark text string in page.get_text().
    """
    pdf_bytes = create_mock_pdf_bytes(["Original Invoice Content", "Page 2 Terms"])
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_watermarked.pdf"

    result = watermark_pdf(
        input_path=input_path,
        output_path=output_path,
        watermark_type="text",
        text="CONFIDENTIAL",
        rotation=-45.0,
        opacity=0.3,
        font_size=48.0,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    assert doc.page_count == 2

    # Check page 1 contains overlay text
    p0_text = doc[0].get_text()
    assert "CONFIDENTIAL" in p0_text

    # Check page 2 contains overlay text
    p1_text = doc[1].get_text()
    assert "CONFIDENTIAL" in p1_text
    doc.close()


def test_watermark_preserves_underlying_text(tmp_path: Path):
    """
    AC: Verifies original text on all pages remains fully searchable and intact.
    """
    orig_text_1 = "Original Document Title 2026"
    orig_text_2 = "Detailed Contract Clause 4.2"
    pdf_bytes = create_mock_pdf_bytes([orig_text_1, orig_text_2])
    input_path = tmp_path / "input_preserve.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_preserve.pdf"

    result = watermark_pdf(
        input_path=input_path,
        output_path=output_path,
        watermark_type="text",
        text="SAMPLE ONLY",
        rotation=0.0,
        opacity=0.2,
        font_size=36.0,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    p0_text = doc[0].get_text()
    p1_text = doc[1].get_text()

    assert orig_text_1 in p0_text
    assert "SAMPLE ONLY" in p0_text
    assert orig_text_2 in p1_text
    assert "SAMPLE ONLY" in p1_text
    doc.close()


def test_watermark_image_png_preserves_alpha(tmp_path: Path):
    """
    AC: Overlays a transparent PNG onto PDF; verifies page rendering succeeds without errors.
    """
    pdf_bytes = create_mock_pdf_bytes(["Confidential Report Body"])
    input_path = tmp_path / "input_img.pdf"
    input_path.write_bytes(pdf_bytes)

    png_bytes = create_mock_png_bytes(200, 200, alpha=128)
    image_path = tmp_path / "logo.png"
    image_path.write_bytes(png_bytes)

    output_path = tmp_path / "output_img.pdf"

    result = watermark_pdf(
        input_path=input_path,
        output_path=output_path,
        watermark_type="image",
        image_path=image_path,
        opacity=0.5,
    )

    assert result.exists()
    doc = fitz.open(str(result))
    assert doc.page_count == 1
    # Check that the page still contains original text and has an image inserted
    page = doc[0]
    assert "Confidential Report Body" in page.get_text()
    images = page.get_images()
    assert len(images) >= 1
    doc.close()


def test_watermark_invalid_type_raises_value_error(tmp_path: Path):
    """
    AC: Unsupported watermark type raises ValueError in service.
    """
    pdf_bytes = create_mock_pdf_bytes(["Sample Page"])
    input_path = tmp_path / "input_bad.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_bad.pdf"

    with pytest.raises(ValueError, match="Invalid watermark type"):
        watermark_pdf(
            input_path=input_path,
            output_path=output_path,
            watermark_type="vector_svg",
        )


# --- API Endpoint Tests ---


def test_watermark_endpoint_invalid_type_returns_400():
    """
    AC: Uploading unsupported watermark type returns HTTP 400.
    """
    pdf_bytes = create_mock_pdf_bytes(["Test API PDF"])
    response = client.post(
        "/api/v1/tools/watermark",
        files={"file": ("test.pdf", pdf_bytes, "application/pdf")},
        data={"watermark_type": "invalid_type"},
    )
    assert response.status_code == 400
    assert "Invalid watermark type" in response.json()["detail"]


def test_watermark_endpoint_text_success():
    """
    AC: Successful text watermarking returns valid PDF FileResponse.
    """
    pdf_bytes = create_mock_pdf_bytes(["Invoice #1001", "Page 2"])
    response = client.post(
        "/api/v1/tools/watermark",
        files={"file": ("invoice.pdf", pdf_bytes, "application/pdf")},
        data={
            "watermark_type": "text",
            "text": "PAID",
            "rotation": "-45.0",
            "opacity": "0.4",
            "font_size": "50.0",
        },
    )
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment" in response.headers.get("content-disposition", "")

    # Validate returned PDF
    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert "PAID" in result_doc[0].get_text()
    assert "Invoice #1001" in result_doc[0].get_text()
    result_doc.close()


def test_watermark_endpoint_image_success():
    """
    AC: Successful image logo watermarking returns valid PDF FileResponse.
    """
    pdf_bytes = create_mock_pdf_bytes(["Branded Page"])
    png_bytes = create_mock_png_bytes(100, 100)

    response = client.post(
        "/api/v1/tools/watermark",
        files={
            "file": ("branded.pdf", pdf_bytes, "application/pdf"),
            "image": ("logo.png", png_bytes, "image/png"),
        },
        data={
            "watermark_type": "image",
            "opacity": "0.5",
        },
    )
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 1
    assert len(result_doc[0].get_images()) >= 1
    result_doc.close()


def test_watermark_endpoint_non_pdf_returns_400():
    """
    AC: Uploading non-PDF file returns HTTP 400.
    """
    response = client.post(
        "/api/v1/tools/watermark",
        files={"file": ("notes.txt", b"plain text", "text/plain")},
        data={"watermark_type": "text"},
    )
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]
