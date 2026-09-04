import json
import io
import pymupdf
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.redis_client import DEV_JOB_STORE
from app.services.pdf_composer import DEV_PDF_STORE

client = TestClient(app)


def _create_sample_pdf_bytes(page_count: int = 2) -> bytes:
    doc = pymupdf.open()
    for i in range(page_count):
        page = doc.new_page(width=595, height=842)
        page.insert_text((50, 100), f"Test Document Page {i + 1}", fontsize=24)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


def test_page_image_non_existent_job_returns_404_or_410():
    """Verify that requesting a page preview for a non-existent job returns 404 or 410."""
    response = client.get("/api/v1/jobs/non_existent_page_job_999/pages/1/image")
    assert response.status_code in (404, 410)


def test_page_image_valid_completed_job_returns_png():
    """Verify that requesting page 1 and page 2 image for a completed job returns 200 image/png."""
    job_id = "test_page_img_job_101"
    token = f"pdf_token_{job_id}"
    pdf_bytes = _create_sample_pdf_bytes(page_count=2)
    DEV_PDF_STORE[token] = pdf_bytes

    completed_payload = {
        "job_id": job_id,
        "filename": "multi_page_sample.pdf",
        "status": "COMPLETED",
        "total_pages": 2,
        "output_pdf_token": token,
        "pages": [
            {"page_number": 1, "text": "Test Document Page 1", "lines": []},
            {"page_number": 2, "text": "Test Document Page 2", "lines": []}
        ]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_payload)

    # Test Page 1
    resp1 = client.get(f"/api/v1/jobs/{job_id}/pages/1/image")
    assert resp1.status_code == 200
    assert resp1.headers["content-type"] == "image/png"
    assert len(resp1.content) > 1000

    # Test Page 2
    resp2 = client.get(f"/api/v1/jobs/{job_id}/pages/2/image")
    assert resp2.status_code == 200
    assert resp2.headers["content-type"] == "image/png"
    assert len(resp2.content) > 1000


def test_page_image_out_of_range_page_returns_404():
    """Verify that requesting a page number higher than total pages returns 404."""
    job_id = "test_page_img_job_102"
    token = f"pdf_token_{job_id}"
    pdf_bytes = _create_sample_pdf_bytes(page_count=1)
    DEV_PDF_STORE[token] = pdf_bytes

    completed_payload = {
        "job_id": job_id,
        "filename": "single_page.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "output_pdf_token": token,
        "pages": [{"page_number": 1, "text": "Single Page Doc", "lines": []}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_payload)

    resp = client.get(f"/api/v1/jobs/{job_id}/pages/99/image")
    assert resp.status_code == 404
    assert "Page not found" in resp.json()["detail"]


def test_page_image_zero_or_negative_page_returns_422_or_400():
    """Verify that invalid page numbers (0 or negative) are rejected."""
    resp = client.get("/api/v1/jobs/test_job/pages/0/image")
    assert resp.status_code in (400, 404, 422)
