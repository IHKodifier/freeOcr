import os
import json
import tempfile
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.redis_client import DEV_JOB_STORE
from app.services.pdf_composer import DEV_PDF_STORE

client = TestClient(app)


def test_download_invalid_format_returns_400():
    """Verify that requesting an unsupported format returns HTTP 400 Bad Request."""
    response = client.get("/api/v1/jobs/test_job_123/download/docx")
    assert response.status_code == 400
    data = response.json()
    assert "Unsupported format" in data["detail"]


def test_download_non_existent_job_returns_410_gone():
    """Verify that requesting a download for a non-existent/expired job returns HTTP 410 Gone."""
    response = client.get("/api/v1/jobs/non_existent_job_999/download/pdf")
    assert response.status_code == 410
    data = response.json()
    assert data["detail"] == "Download link expired."


def test_download_pdf_success_and_purges_ram_disk():
    """Verify downloading searchable PDF streams file bytes and immediately unlinks RAM disk input file."""
    job_id = "test_download_job_pdf"
    output_token = "pdf_token_test_123"
    pdf_bytes = b"%PDF-1.4 test searchable pdf content"
    DEV_PDF_STORE[output_token] = pdf_bytes

    completed_job = {
        "job_id": job_id,
        "filename": "document_scan.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "output_pdf_token": output_token,
        "pages": [{"page_number": 1, "text": "Page 1 Text", "lines": []}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_job)

    # Create dummy ephemeral input file on RAM disk
    ram_disk_dir = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    temp_input_path = os.path.join(ram_disk_dir, f"ephemeral_{job_id}_document_scan.pdf")
    with open(temp_input_path, "wb") as f:
        f.write(b"dummy original input pdf")

    assert os.path.exists(temp_input_path)

    response = client.get(f"/api/v1/jobs/{job_id}/download/pdf")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert 'attachment; filename="document_scan_searchable.pdf"' in response.headers["content-disposition"]
    assert response.content == pdf_bytes

    # Assert ephemeral input file was immediately unlinked / purged from RAM disk
    assert not os.path.exists(temp_input_path)


def test_download_txt_success():
    """Verify downloading plain text streams compiled pages text."""
    job_id = "test_download_job_txt"
    completed_job = {
        "job_id": job_id,
        "filename": "receipt_ocr.pdf",
        "status": "COMPLETED",
        "total_pages": 2,
        "pages": [
            {"page_number": 1, "text": "Store #101\nTotal: $42.50", "lines": []},
            {"page_number": 2, "text": "Thank you!", "lines": []}
        ]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_job)

    response = client.get(f"/api/v1/jobs/{job_id}/download/txt")
    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert 'attachment; filename="receipt_ocr_extracted.txt"' in response.headers["content-disposition"]
    
    content_text = response.content.decode("utf-8")
    assert "Store #101" in content_text
    assert "Total: $42.50" in content_text
    assert "Thank you!" in content_text


def test_download_md_success():
    """Verify downloading markdown format streams formatted markdown text with page headers."""
    job_id = "test_download_job_md"
    completed_job = {
        "job_id": job_id,
        "filename": "article.pdf",
        "status": "COMPLETED",
        "total_pages": 2,
        "pages": [
            {"page_number": 1, "text": "Heading: Deep Learning\nContent line 1", "lines": []},
            {"page_number": 2, "text": "Conclusion paragraph", "lines": []}
        ]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_job)

    response = client.get(f"/api/v1/jobs/{job_id}/download/md")
    assert response.status_code == 200
    assert "text/markdown" in response.headers["content-type"]
    assert 'attachment; filename="article_extracted.md"' in response.headers["content-disposition"]

    content_text = response.content.decode("utf-8")
    assert "# Page 1" in content_text
    assert "Heading: Deep Learning" in content_text
    assert "# Page 2" in content_text
    assert "Conclusion paragraph" in content_text
