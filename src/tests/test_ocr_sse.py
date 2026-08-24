import json
import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_sse_endpoint_returns_event_stream_headers():
    fake_redis = MagicMock()
    fake_pubsub = MagicMock()
    fake_redis.pubsub.return_value = fake_pubsub
    fake_redis.get.return_value = json.dumps({"job_id": "job-sse-123", "status": "QUEUED"}).encode("utf-8")

    mock_msg = {
        "type": "message",
        "data": json.dumps({
            "job_id": "job-sse-123",
            "status": "PROCESSING",
            "current_page": 1,
            "total_pages": 5
        })
    }
    fake_pubsub.listen.return_value = [mock_msg]

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/job-sse-123/events")
        assert response.status_code == 200
        assert "text/event-stream" in response.headers.get("content-type", "")


def test_sse_stream_emits_page_progress_and_completed_events():
    fake_redis = MagicMock()
    fake_pubsub = MagicMock()
    fake_redis.pubsub.return_value = fake_pubsub
    fake_redis.get.return_value = json.dumps({"job_id": "job-sse-456", "status": "QUEUED"}).encode("utf-8")

    event_page_1 = {
        "type": "message",
        "data": json.dumps({
            "job_id": "job-sse-456",
            "status": "PROCESSING",
            "current_page": 1,
            "total_pages": 2
        })
    }
    event_completed = {
        "type": "message",
        "data": json.dumps({
            "job_id": "job-sse-456",
            "status": "COMPLETED",
            "current_page": 2,
            "total_pages": 2,
            "output_pdf_token": "pdf_token_abc123"
        })
    }
    fake_pubsub.listen.return_value = [event_page_1, event_completed]

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/job-sse-456/events")
        assert response.status_code == 200
        content = response.text
        assert "data: " in content
        assert "PROCESSING" in content
        assert "COMPLETED" in content
        assert "pdf_token_abc123" in content


def test_sse_stream_emits_failed_event():
    fake_redis = MagicMock()
    fake_pubsub = MagicMock()
    fake_redis.pubsub.return_value = fake_pubsub
    fake_redis.get.return_value = json.dumps({"job_id": "job-sse-789", "status": "QUEUED"}).encode("utf-8")

    event_failed = {
        "type": "message",
        "data": json.dumps({
            "job_id": "job-sse-789",
            "status": "FAILED",
            "error_message": "OCR engine execution error."
        })
    }
    fake_pubsub.listen.return_value = [event_failed]

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/job-sse-789/events")
        assert response.status_code == 200
        content = response.text
        assert "FAILED" in content
        assert "OCR engine execution error." in content


def test_sse_endpoint_non_existent_job_returns_404():
    fake_redis = MagicMock()
    fake_redis.get.return_value = None

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/nonexistent-job-999/events")
        assert response.status_code == 404
        assert response.json() == {"detail": "Job not found or expired."}
