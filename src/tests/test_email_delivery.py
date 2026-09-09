import os
import json
import tempfile
from unittest.mock import patch, MagicMock
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.redis_client import DEV_JOB_STORE
from app.services.email_service import send_download_links_email, validate_email_address

client = TestClient(app)


def test_validate_email_address_valid_and_invalid():
    assert validate_email_address("user@example.com") is True
    assert validate_email_address("test.user+tag@domain.co.uk") is True
    assert validate_email_address("invalid-email") is False
    assert validate_email_address("user@") is False
    assert validate_email_address("") is False


def test_send_download_links_email_formatting():
    job_id = "test-job-123"
    email = "user@example.com"
    result = send_download_links_email(email, job_id)
    
    assert result["status"] == "SUCCESS"
    assert result["email"] == email
    assert result["job_id"] == job_id
    assert "download_links" in result
    assert result["download_links"]["pdf"].endswith(f"/api/v1/jobs/{job_id}/download/pdf")
    assert result["download_links"]["txt"].endswith(f"/api/v1/jobs/{job_id}/download/txt")
    assert result["download_links"]["md"].endswith(f"/api/v1/jobs/{job_id}/download/md")
    assert result["download_links"]["zip"].endswith(f"/api/v1/jobs/{job_id}/download/zip")
    assert result["expires_in_hours"] == 24


def test_send_email_links_success_and_purges_ram_disk():
    job_id = "job-email-test-001"
    
    # 1. Create ephemeral original input file in RAM disk temp directory
    temp_dir = tempfile.gettempdir()
    ephemeral_path = os.path.join(temp_dir, f"ephemeral_{job_id}_input.pdf")
    with open(ephemeral_path, "wb") as f:
        f.write(b"%PDF-1.4 test input file")

    assert os.path.exists(ephemeral_path) is True

    # 2. Store mock COMPLETED job state in DEV_JOB_STORE
    job_payload = {
        "job_id": job_id,
        "filename": "input.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "pages": [{"page_number": 1, "text": "Sample text"}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(job_payload)

    try:
        # 3. Call POST /api/v1/ocr/email-links
        response = client.post(
            "/api/v1/ocr/email-links",
            json={"job_id": job_id, "email": "recipient@example.com"}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "SUCCESS"
        assert data["email"] == "recipient@example.com"
        assert data["input_purged"] is True
        assert "download_links" in data
        assert data["download_links"]["pdf"].endswith(f"/api/v1/jobs/{job_id}/download/pdf")

        # 4. Privacy Mandate Check (AC-1): Original input file must be purged from RAM disk!
        assert os.path.exists(ephemeral_path) is False

    finally:
        if os.path.exists(ephemeral_path):
            os.remove(ephemeral_path)
        DEV_JOB_STORE.pop(job_id, None)


def test_send_email_links_invalid_email_format():
    response = client.post(
        "/api/v1/ocr/email-links",
        json={"job_id": "any-job", "email": "not-an-email"}
    )
    assert response.status_code == 400
    assert "Invalid email address format" in response.json()["detail"]


def test_send_email_links_job_not_found():
    response = client.post(
        "/api/v1/ocr/email-links",
        json={"job_id": "non-existent-job-xyz", "email": "user@example.com"}
    )
    assert response.status_code == 404
    assert "Job not found or expired" in response.json()["detail"]


def test_send_email_links_job_not_completed():
    job_id = "job-uncompleted-99"
    job_payload = {
        "job_id": job_id,
        "filename": "pending.pdf",
        "status": "PROCESSING",
    }
    DEV_JOB_STORE[job_id] = json.dumps(job_payload)

    try:
        response = client.post(
            "/api/v1/ocr/email-links",
            json={"job_id": job_id, "email": "user@example.com"}
        )
        assert response.status_code == 404
    finally:
        DEV_JOB_STORE.pop(job_id, None)


def test_send_email_links_custom_api_base_url_env_var():
    job_id = "job-prod-domain-test"
    job_payload = {
        "job_id": job_id,
        "filename": "prod_doc.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "pages": [{"page_number": 1, "text": "Prod text"}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(job_payload)
    
    os.environ["API_BASE_URL"] = "https://freeocr.me"

    try:
        response = client.post(
            "/api/v1/ocr/email-links",
            json={"job_id": job_id, "email": "user@example.com"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["download_links"]["pdf"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/pdf"
        assert data["download_links"]["txt"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/txt"
        assert data["download_links"]["md"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/md"
        assert data["download_links"]["zip"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/zip"
    finally:
        os.environ.pop("API_BASE_URL", None)
        DEV_JOB_STORE.pop(job_id, None)


def test_send_download_links_via_resend_api_success():
    job_id = "job-resend-test-01"
    email = "user@example.com"
    api_key = "re_test_dummy_key_12345"

    os.environ["RESEND_API_KEY"] = api_key
    os.environ["RESEND_FROM_EMAIL"] = "delivery@freeocr.me"

    try:
        with patch("httpx.post") as mock_post:
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = {"id": "resend-msg-123"}
            mock_post.return_value = mock_resp

            result = send_download_links_email(email, job_id, base_url="https://freeocr.me")

            assert result["status"] == "SUCCESS"
            assert result["delivery_mode"] == "RESEND_API"
            assert result["email_sent"] is True
            assert result["error_detail"] is None
            assert result["download_links"]["pdf"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/pdf"

            mock_post.assert_called_once()
            called_url = mock_post.call_args[0][0]
            called_kwargs = mock_post.call_args[1]

            assert called_url == "https://api.resend.com/emails"
            assert called_kwargs["headers"]["Authorization"] == f"Bearer {api_key}"
            assert called_kwargs["headers"]["Content-Type"] == "application/json"
            assert called_kwargs["json"]["from"] == "delivery@freeocr.me"
            assert called_kwargs["json"]["to"] == [email]
            assert "Your freeOCR.me Download Links" in called_kwargs["json"]["subject"]
            assert f"https://freeocr.me/api/v1/jobs/{job_id}/download/pdf" in called_kwargs["json"]["html"]
    finally:
        os.environ.pop("RESEND_API_KEY", None)
        os.environ.pop("RESEND_FROM_EMAIL", None)


def test_send_download_links_via_resend_api_failure_response():
    job_id = "job-resend-fail-02"
    email = "user@example.com"

    os.environ["RESEND_API_KEY"] = "re_test_bad_key"

    try:
        with patch("httpx.post") as mock_post:
            mock_resp = MagicMock()
            mock_resp.status_code = 401
            mock_resp.text = '{"statusCode": 401, "message": "API key is invalid"}'
            mock_post.return_value = mock_resp

            result = send_download_links_email(email, job_id)

            assert result["status"] == "ERROR"
            assert result["delivery_mode"] == "RESEND_API"
            assert result["email_sent"] is False
            assert "Resend API returned 401" in result["error_detail"]
    finally:
        os.environ.pop("RESEND_API_KEY", None)


def test_send_download_links_via_resend_api_network_exception():
    job_id = "job-resend-timeout-03"
    email = "user@example.com"

    os.environ["RESEND_API_KEY"] = "re_test_key"

    try:
        with patch("httpx.post", side_effect=Exception("Connection timed out")):
            result = send_download_links_email(email, job_id)

            assert result["status"] == "ERROR"
            assert result["delivery_mode"] == "RESEND_API"
            assert result["email_sent"] is False
            assert "Resend API connection error" in result["error_detail"]
    finally:
        os.environ.pop("RESEND_API_KEY", None)


def test_api_endpoint_resend_delivery_integration():
    job_id = "job-endpoint-resend-04"
    job_payload = {
        "job_id": job_id,
        "filename": "document.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "pages": [{"page_number": 1, "text": "Content"}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(job_payload)
    os.environ["RESEND_API_KEY"] = "re_valid_integration_key"
    os.environ["API_BASE_URL"] = "https://freeocr.me"

    try:
        with patch("httpx.post") as mock_post:
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = {"id": "resend-msg-endpoint"}
            mock_post.return_value = mock_resp

            response = client.post(
                "/api/v1/ocr/email-links",
                json={"job_id": job_id, "email": "customer@example.com"}
            )

            assert response.status_code == 200
            data = response.json()
            assert data["status"] == "SUCCESS"
            assert data["delivery_mode"] == "RESEND_API"
            assert "Download links sent to customer@example.com!" in data["message"]
            assert data["download_links"]["pdf"] == f"https://freeocr.me/api/v1/jobs/{job_id}/download/pdf"
    finally:
        os.environ.pop("RESEND_API_KEY", None)
        os.environ.pop("API_BASE_URL", None)
        DEV_JOB_STORE.pop(job_id, None)

