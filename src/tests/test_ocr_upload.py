import io
import json
import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_upload_valid_pdf_success():
    fake_redis = MagicMock()
    with patch("app.api.v1.endpoints.ocr.get_redis_client", return_value=fake_redis):
        pdf_content = b"%PDF-1.4 dummy content for testing pdf upload"
        files = {"file": ("test_doc.pdf", pdf_content, "application/pdf")}
        response = client.post("/api/v1/ocr/convert", files=files)

        assert response.status_code == 202
        data = response.json()
        assert "job_id" in data
        assert data["status"] == "QUEUED"

        # Verify Redis key job:{job_id} was set
        job_id = data["job_id"]
        fake_redis.set.assert_called()
        call_args = fake_redis.set.call_args[0]
        assert call_args[0] == f"job:{job_id}"
        payload = json.loads(call_args[1])
        assert payload["status"] == "QUEUED"
        assert payload["filename"] == "test_doc.pdf"


def test_upload_valid_image_success():
    fake_redis = MagicMock()
    with patch("app.api.v1.endpoints.ocr.get_redis_client", return_value=fake_redis):
        img_content = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR dummy png content"
        files = {"file": ("scan.png", img_content, "image/png")}
        response = client.post("/api/v1/ocr/convert", files=files)

        assert response.status_code == 202
        data = response.json()
        assert "job_id" in data
        assert data["status"] == "QUEUED"


def test_upload_unsupported_file_extension():
    files = {"file": ("malicious.exe", b"binary content", "application/octet-stream")}
    response = client.post("/api/v1/ocr/convert", files=files)

    assert response.status_code == 400
    assert response.json() == {"detail": "Unsupported file format."}


def test_upload_empty_0byte_file():
    files = {"file": ("empty.pdf", b"", "application/pdf")}
    response = client.post("/api/v1/ocr/convert", files=files)

    assert response.status_code == 400
    assert response.json() == {"detail": "File is empty. Please select a valid document."}


from app.redis_client import DEV_AD_PASS_STORE

def test_upload_oversized_file():
    DEV_AD_PASS_STORE.clear()
    from unittest.mock import patch
    # 101MB file content simulation (exceeds 100MB base limit)
    oversized_content = b"X" * (101 * 1024 * 1024)
    files = {"file": ("large.pdf", oversized_content, "application/pdf")}
    with patch("app.api.v1.endpoints.ocr.get_ad_pass_metadata", return_value=None):
        response = client.post("/api/v1/ocr/convert", files=files)

    assert response.status_code == 400
    assert "File size exceeds allowed limit" in response.json()["detail"]

