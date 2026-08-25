import json
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.redis_client import DEV_JOB_STORE

client = TestClient(app)


def test_preview_non_existent_job_returns_404():
    """Verify that requesting a preview for a non-existent job returns HTTP 404."""
    response = client.get("/api/v1/jobs/non_existent_job_123/preview")
    assert response.status_code == 404
    data = response.json()
    assert data["detail"] == "Job not found or expired."


def test_preview_completed_job_returns_pages_data():
    """Verify that requesting a preview for a completed job returns extracted pages & layout metadata."""
    job_id = "test_preview_job_999"
    completed_job_payload = {
        "job_id": job_id,
        "filename": "sample_invoice.pdf",
        "status": "COMPLETED",
        "total_pages": 2,
        "output_pdf_token": "pdf_token_abc123",
        "pages": [
            {
                "page_number": 1,
                "text": "Invoice #1001\nTotal: $250.00",
                "lines": [
                    {"bbox": [10.0, 20.0, 100.0, 30.0], "text": "Invoice #1001"},
                    {"bbox": [10.0, 40.0, 90.0, 50.0], "text": "Total: $250.00"}
                ]
            },
            {
                "page_number": 2,
                "text": "Thank you for your business!",
                "lines": [
                    {"bbox": [10.0, 20.0, 150.0, 30.0], "text": "Thank you for your business!"}
                ]
            }
        ]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_job_payload)

    response = client.get(f"/api/v1/jobs/{job_id}/preview")
    assert response.status_code == 200
    data = response.json()

    assert data["job_id"] == job_id
    assert data["filename"] == "sample_invoice.pdf"
    assert data["status"] == "COMPLETED"
    assert data["total_pages"] == 2
    assert data["output_pdf_token"] == "pdf_token_abc123"
    assert len(data["pages"]) == 2
    assert data["pages"][0]["text"] == "Invoice #1001\nTotal: $250.00"
    assert len(data["pages"][0]["lines"]) == 2
