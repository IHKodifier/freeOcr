import os
import io
import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
import pymupdf


def test_baidu_gpu_service_health():
    """Verifies that GET /health returns ready status and identifies Baidu_Unlimited_OCR engine."""
    from app.services.baidu_gpu_service import app
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ready"
    assert data["engine"] == "Baidu_Unlimited_OCR"
    assert "gpu_available" in data


def test_baidu_gpu_service_auth_missing_or_invalid():
    """Verifies that POST /ocr/complex-page rejects requests without valid X-Internal-Secret."""
    from app.services.baidu_gpu_service import app
    client = TestClient(app)

    with patch.dict(os.environ, {"INTERNAL_SECRET": "secret123"}):
        # Missing header
        res1 = client.post("/ocr/complex-page", files={"file": ("page.png", b"dummy_content", "image/png")})
        assert res1.status_code == 401

        # Invalid header
        res2 = client.post(
            "/ocr/complex-page",
            headers={"X-Internal-Secret": "wrong_secret"},
            files={"file": ("page.png", b"dummy_content", "image/png")}
        )
        assert res2.status_code == 401


def test_parse_grounding_output():
    """Verifies that grounding tags and coordinates are accurately parsed into line objects."""
    from app.services.baidu_gpu_service import parse_grounding_output

    sample_output = (
        "<|det|><text> [15.0, 25.0, 250.0, 50.0] <|/det|>Quarterly Financial Statement\n"
        "<|det|><table_body> [30.0, 60.0, 480.0, 180.0] <|/det|>Revenue: $1,250,000"
    )

    lines = parse_grounding_output(sample_output)
    assert len(lines) == 2
    assert lines[0]["text"] == "Quarterly Financial Statement"
    assert lines[0]["bbox"] == [15.0, 25.0, 250.0, 50.0]
    assert lines[1]["text"] == "Revenue: $1,250,000"
    assert lines[1]["bbox"] == [30.0, 60.0, 480.0, 180.0]


def test_baidu_gpu_service_complex_page_mock_inference():
    """Verifies that POST /ocr/complex-page returns properly formatted bounding boxes and text."""
    from app.services.baidu_gpu_service import app
    client = TestClient(app)

    # Create dummy 100x100 PNG image bytes
    pix = pymupdf.Pixmap(pymupdf.csRGB, pymupdf.IRect(0, 0, 100, 100), 1)
    img_bytes = pix.tobytes("png")

    mock_lines = [
        {
            "bbox": [10.0, 20.0, 90.0, 40.0],
            "text": "Total Revenue: $500,000",
            "confidence": 0.985
        }
    ]

    with patch.dict(os.environ, {"INTERNAL_SECRET": "test_secret"}):
        with patch("app.services.baidu_gpu_service.run_baidu_ocr_inference", return_value=mock_lines):
            response = client.post(
                "/ocr/complex-page",
                headers={"X-Internal-Secret": "test_secret"},
                files={"file": ("page1.png", io.BytesIO(img_bytes), "image/png")}
            )
            assert response.status_code == 200
            data = response.json()
            assert data["engine"] == "Baidu_Unlimited_OCR"
            assert len(data["lines"]) == 1
            line = data["lines"][0]
            assert line["text"] == "Total Revenue: $500,000"
            assert line["bbox"] == [10.0, 20.0, 90.0, 40.0]
            assert line["confidence"] == 0.985


def test_ocr_worker_dispatches_to_baidu_gpu_service():
    """Verifies that ocr_worker queries BAIDU_GPU_WORKER_URL when configured for complex OCR."""
    from app.services.ocr_worker import process_ocr_job

    # Create 1-page dummy PDF
    doc = pymupdf.open()
    page = doc.new_page(width=595, height=842)
    # Insert visual shapes without text stream to force scanned OCR flow
    page.draw_rect(pymupdf.Rect(50, 50, 200, 200), color=(0, 0, 0), fill=(0.9, 0.9, 0.9))
    pdf_bytes = doc.tobytes()
    doc.close()

    mock_gpu_response = {
        "engine": "Baidu_Unlimited_OCR",
        "lines": [
            {
                "bbox": [50.0, 100.0, 250.0, 120.0],
                "text": "Baidu Unlimited OCR Result",
                "confidence": 0.99
            }
        ]
    }

    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.json.return_value = mock_gpu_response

    with patch.dict(os.environ, {
        "BAIDU_GPU_WORKER_URL": "http://gpu-worker-test:8080",
        "INTERNAL_SECRET": "test_secret"
    }):
        with patch("httpx.post", return_value=mock_resp) as mock_post:
            res = process_ocr_job(
                job_id="test_gpu_dispatch_001",
                file_bytes=pdf_bytes,
                filename="scanned_complex.pdf",
                target_engine="Baidu_Unlimited_OCR"
            )

            assert res["status"] == "COMPLETED"
            assert mock_post.called
            called_url = mock_post.call_args[0][0]
            assert "http://gpu-worker-test:8080/ocr/complex-page" in called_url
            called_headers = mock_post.call_args[1].get("headers", {})
            assert called_headers.get("X-Internal-Secret") == "test_secret"


def test_ocr_worker_resilient_cpu_fallback_on_gpu_timeout_or_error():
    """
    Verifies that when BAIDU_GPU_WORKER_URL times out (>15s) or returns 500/connection error,
    ocr_worker silently falls back to CPU OCRmyPDF/Tesseract without failing the conversion.
    """
    import httpx
    from app.services.ocr_worker import process_ocr_job

    doc = pymupdf.open()
    page = doc.new_page(width=595, height=842)
    page.draw_rect(pymupdf.Rect(50, 50, 100, 100), color=(0, 0, 0))
    pdf_bytes = doc.tobytes()
    doc.close()

    with patch.dict(os.environ, {
        "BAIDU_GPU_WORKER_URL": "http://gpu-worker-test:8080",
        "INTERNAL_SECRET": "test_secret"
    }):
        # Case A: Timeout exception (simulating GPU cold-start delay)
        with patch("httpx.post", side_effect=httpx.TimeoutException("GPU Cold-Start Timeout")):
            res = process_ocr_job(
                job_id="test_gpu_fallback_timeout",
                file_bytes=pdf_bytes,
                filename="timeout_complex.pdf",
                target_engine="Baidu_Unlimited_OCR"
            )
            # Job MUST NOT fail
            assert res["status"] == "COMPLETED"
            assert "output_pdf_token" in res

        # Case B: HTTP 500 Server Error
        mock_500 = MagicMock()
        mock_500.status_code = 500
        mock_500.text = "Internal GPU Out Of Memory"
        with patch("httpx.post", return_value=mock_500):
            res2 = process_ocr_job(
                job_id="test_gpu_fallback_500",
                file_bytes=pdf_bytes,
                filename="error_complex.pdf",
                target_engine="Baidu_Unlimited_OCR"
            )
            assert res2["status"] == "COMPLETED"
            assert "output_pdf_token" in res2
