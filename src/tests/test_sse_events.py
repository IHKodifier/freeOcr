import json
import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_sse_endpoint_non_existent_job_returns_404():
    fake_redis = MagicMock()
    fake_redis.get.return_value = None  # Key does not exist in Redis

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/invalid-job-id/events")
        assert response.status_code == 404
        assert response.json() == {"detail": "Job not found or expired."}


def test_sse_endpoint_streams_redis_events():
    fake_redis = MagicMock()
    # Job exists in Redis
    fake_redis.get.return_value = json.dumps({"job_id": "valid-job-123", "status": "QUEUED"}).encode("utf-8")

    pubsub_mock = MagicMock()
    # Simulate Redis pubsub messages
    pubsub_mock.listen.return_value = [
        {
            "type": "message",
            "data": json.dumps({"current_page": 1, "total_pages": 4, "status": "PROCESSING"}),
        },
        {
            "type": "message",
            "data": json.dumps({
                "current_page": 4,
                "total_pages": 4,
                "status": "COMPLETED",
                "output_pdf_token": "pdf_token_abc123"
            }),
        },
    ]
    fake_redis.pubsub.return_value = pubsub_mock

    with patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=fake_redis):
        response = client.get("/api/v1/jobs/valid-job-123/events")
        assert response.status_code == 200
        assert "text/event-stream" in response.headers.get("content-type", "")
        content = response.text
        assert "PROCESSING" in content
        assert "COMPLETED" in content
        assert "pdf_token_abc123" in content
