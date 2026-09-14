import io
from pathlib import Path
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_compress_service import (
    compress_pdf,
    VALID_COMPRESSION_LEVELS,
)

client = TestClient(app)


def create_test_pdf_with_image(num_pages: int = 2) -> bytes:
    """Helper to generate a PDF containing raster image content and text."""
    doc = fitz.open()
    for i in range(num_pages):
        page = doc.new_page(width=595, height=842)
        page.insert_text((50, 50), f"Compression Test Page {i + 1}", fontsize=16)

        # Create an uncompressed sample pixmap with solid and gradient patterns
        pix = fitz.Pixmap(fitz.csRGB, fitz.IRect(0, 0, 300, 300), 0)
        for y in range(300):
            for x in range(300):
                pix.set_pixel(x, y, (x % 256, y % 256, (x + y) % 256))
        
        img_bytes = pix.tobytes("png")
        page.insert_image(fitz.Rect(50, 100, 350, 400), stream=img_bytes)

    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


# --- Unit Tests: Compression Service ---


def test_compress_pdf_recommended_reduces_or_maintains_size(tmp_path: Path):
    """
    AC: Compresses PDF with 'recommended' preset.
    Asserts returned metrics structure and output file exists and is valid.
    """
    pdf_bytes = create_test_pdf_with_image(2)
    input_path = tmp_path / "test_input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "test_compressed_recommended.pdf"

    metrics = compress_pdf(
        input_path=input_path,
        output_path=output_path,
        level="recommended",
    )

    assert output_path.exists()
    assert metrics["original_size"] == len(pdf_bytes)
    assert metrics["compressed_size"] <= metrics["original_size"]
    assert metrics["level"] == "recommended"
    assert "percent_saved" in metrics
    assert "saved_bytes" in metrics

    # Verify valid readable PDF output
    doc = fitz.open(str(output_path))
    assert doc.page_count == 2
    assert "Compression Test Page 1" in doc[0].get_text()
    doc.close()


def test_compress_pdf_extreme_preset(tmp_path: Path):
    """
    AC: Compresses PDF with 'extreme' preset.
    Asserts valid document output and successful metrics.
    """
    pdf_bytes = create_test_pdf_with_image(2)
    input_path = tmp_path / "test_input_extreme.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "test_compressed_extreme.pdf"

    metrics = compress_pdf(
        input_path=input_path,
        output_path=output_path,
        level="extreme",
    )

    assert output_path.exists()
    assert metrics["compressed_size"] <= metrics["original_size"]
    assert metrics["level"] == "extreme"

    doc = fitz.open(str(output_path))
    assert doc.page_count == 2
    doc.close()


def test_compress_pdf_lossless_preset(tmp_path: Path):
    """
    AC: Compresses PDF with 'low' (lossless) preset.
    Asserts stream optimization without raster downsampling corruption.
    """
    pdf_bytes = create_test_pdf_with_image(1)
    input_path = tmp_path / "test_input_low.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "test_compressed_low.pdf"

    metrics = compress_pdf(
        input_path=input_path,
        output_path=output_path,
        level="low",
    )

    assert output_path.exists()
    assert metrics["compressed_size"] <= metrics["original_size"]
    assert metrics["level"] == "low"

    doc = fitz.open(str(output_path))
    assert doc.page_count == 1
    assert "Compression Test Page 1" in doc[0].get_text()
    doc.close()


def test_compress_pdf_byte_size_guard(tmp_path: Path):
    """
    AC: For a minimal PDF that cannot be further compressed, the output
    must NEVER be larger than the original input (byte size guard).
    """
    doc = fitz.open()
    p = doc.new_page(width=200, height=200)
    p.insert_text((20, 50), "Minimal text")
    minimal_bytes = doc.write(garbage=4, deflate=True)
    doc.close()

    input_path = tmp_path / "minimal.pdf"
    input_path.write_bytes(minimal_bytes)
    output_path = tmp_path / "minimal_compressed.pdf"

    metrics = compress_pdf(
        input_path=input_path,
        output_path=output_path,
        level="recommended",
    )

    assert output_path.exists()
    assert metrics["compressed_size"] <= len(minimal_bytes)
    assert metrics["percent_saved"] >= 0.0


def test_compress_invalid_level_raises_error(tmp_path: Path):
    """
    AC: Providing an unapproved compression preset raises ValueError.
    """
    input_path = tmp_path / "test_invalid.pdf"
    input_path.write_bytes(b"%PDF-1.4 mock")
    output_path = tmp_path / "out_invalid.pdf"

    with pytest.raises(ValueError, match="Invalid compression level"):
        compress_pdf(
            input_path=input_path,
            output_path=output_path,
            level="super_ultra_fake",
        )


# --- API Endpoint Integration Tests ---


def test_compress_endpoint_success():
    """
    AC: POST /api/v1/tools/compress with valid PDF and level returns
    HTTP 200, application/pdf, and custom metrics headers.
    """
    pdf_bytes = create_test_pdf_with_image(1)
    files = {"file": ("document_to_compress.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    data = {"level": "recommended"}

    response = client.post("/api/v1/tools/compress", files=files, data=data)

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "attachment; filename=" in response.headers["content-disposition"]
    assert "X-Original-Size" in response.headers
    assert "X-Compressed-Size" in response.headers
    assert "X-Percent-Saved" in response.headers

    original_size = int(response.headers["X-Original-Size"])
    compressed_size = int(response.headers["X-Compressed-Size"])
    assert original_size == len(pdf_bytes)
    assert compressed_size <= original_size

    # Verify output PDF integrity
    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 1
    result_doc.close()


def test_compress_endpoint_invalid_file_type():
    """
    AC: Uploading a non-PDF file returns HTTP 400.
    """
    files = {"file": ("malicious.exe", io.BytesIO(b"MZ123"), "application/octet-stream")}
    response = client.post("/api/v1/tools/compress", files=files, data={"level": "recommended"})
    assert response.status_code == 400
    assert "Only PDF files are supported" in response.json()["detail"]


def test_compress_endpoint_invalid_level():
    """
    AC: Specifying an invalid compression level returns HTTP 422.
    """
    pdf_bytes = create_test_pdf_with_image(1)
    files = {"file": ("doc.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    response = client.post("/api/v1/tools/compress", files=files, data={"level": "invalid_preset"})
    assert response.status_code == 422
    assert "Invalid compression level" in response.json()["detail"]
