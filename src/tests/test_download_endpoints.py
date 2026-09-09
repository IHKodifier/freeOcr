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


def test_batch_download_zip_success():
    """Verify downloading batch zip produces a valid ZIP file containing all completed files."""
    import io
    import zipfile

    job1_id = "test_batch_job_1"
    token1 = "token_pdf_1"
    DEV_PDF_STORE[token1] = b"%PDF-1.4 file 1 content"
    DEV_JOB_STORE[job1_id] = json.dumps({
        "job_id": job1_id,
        "filename": "doc_first.pdf",
        "status": "COMPLETED",
        "output_pdf_token": token1,
        "pages": [{"page_number": 1, "text": "Page 1"}]
    })

    job2_id = "test_batch_job_2"
    token2 = "token_pdf_2"
    DEV_PDF_STORE[token2] = b"%PDF-1.4 file 2 content"
    DEV_JOB_STORE[job2_id] = json.dumps({
        "job_id": job2_id,
        "filename": "doc_second.pdf",
        "status": "COMPLETED",
        "output_pdf_token": token2,
        "pages": [{"page_number": 1, "text": "Page 2"}]
    })

    response = client.get(f"/api/v1/jobs/batch-download/zip?job_ids={job1_id},{job2_id}&format=pdf")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"
    assert 'attachment; filename="freeOCR_searchable_batch.zip"' in response.headers["content-disposition"]

    with zipfile.ZipFile(io.BytesIO(response.content), "r") as zf:
        namelist = zf.namelist()
        assert "doc_first_searchable.pdf" in namelist
        assert "doc_second_searchable.pdf" in namelist
        assert zf.read("doc_first_searchable.pdf") == b"%PDF-1.4 file 1 content"
        assert zf.read("doc_second_searchable.pdf") == b"%PDF-1.4 file 2 content"


def test_batch_download_zip_invalid_format():
    """Verify batch zip with invalid format returns HTTP 400 Bad Request."""
    response = client.get("/api/v1/jobs/batch-download/zip?job_ids=job1&format=exe")
    assert response.status_code == 400
    assert "Unsupported format" in response.json()["detail"]


def test_download_all_formats_from_redis_on_cold_boot():
    """
    Verify that ALL supported download formats (pdf, txt, md, and zip)
    can be downloaded successfully when the local container RAM disk is 100% empty
    (simulating scale-to-zero cold boot from powered off instance).
    """
    from unittest.mock import patch, MagicMock
    import zipfile
    import io

    job_id = "cold_boot_job_all_formats"
    output_token = "cold_boot_token_789"
    pdf_bytes = b"%PDF-1.4 cold boot test pdf content"

    job_metadata = {
        "job_id": job_id,
        "filename": "test_document.pdf",
        "status": "COMPLETED",
        "total_pages": 2,
        "output_pdf_token": output_token,
        "pages": [
            {"page_number": 1, "text": "First page text content"},
            {"page_number": 2, "text": "Second page text content"}
        ]
    }
    job_json = json.dumps(job_metadata)

    # 1. Ensure local RAM stores are completely empty (container powered off / fresh instance)
    DEV_JOB_STORE.pop(job_id, None)
    DEV_PDF_STORE.pop(output_token, None)

    # 2. Mock Redis holding the persistent data
    mock_redis = MagicMock()
    def mock_get(key):
        if key == f"job:{job_id}":
            return job_json
        if key == f"pdf:{output_token}":
            return pdf_bytes
        return None

    mock_redis.get.side_effect = mock_get

    with patch("app.redis_client.get_redis_client", return_value=mock_redis), \
         patch("app.api.v1.endpoints.jobs.get_redis_client", return_value=mock_redis):

        # A) Test Searchable PDF download on cold boot
        resp_pdf = client.get(f"/api/v1/jobs/{job_id}/download/pdf")
        assert resp_pdf.status_code == 200
        assert resp_pdf.headers["content-type"] == "application/pdf"
        assert resp_pdf.content == pdf_bytes
        assert "test_document_searchable.pdf" in resp_pdf.headers["content-disposition"]

        # Ensure local store is cleared again for txt test
        DEV_JOB_STORE.pop(job_id, None)

        # B) Test Plain Text (.txt) download on cold boot
        resp_txt = client.get(f"/api/v1/jobs/{job_id}/download/txt")
        assert resp_txt.status_code == 200
        assert "text/plain" in resp_txt.headers["content-type"]
        assert "First page text content\n\nSecond page text content" in resp_txt.text
        assert "test_document_extracted.txt" in resp_txt.headers["content-disposition"]

        DEV_JOB_STORE.pop(job_id, None)

        # C) Test Markdown (.md) download on cold boot
        resp_md = client.get(f"/api/v1/jobs/{job_id}/download/md")
        assert resp_md.status_code == 200
        assert "text/markdown" in resp_md.headers["content-type"]
        assert "# Page 1\n\nFirst page text content" in resp_md.text
        assert "# Page 2\n\nSecond page text content" in resp_md.text
        assert "test_document_extracted.md" in resp_md.headers["content-disposition"]

        DEV_JOB_STORE.pop(job_id, None)

        # D) Test Batch ZIP download (txt format) on cold boot
        resp_zip = client.get(f"/api/v1/jobs/batch-download/zip?job_ids={job_id}&format=txt")
        assert resp_zip.status_code == 200
        assert resp_zip.headers["content-type"] == "application/zip"
        with zipfile.ZipFile(io.BytesIO(resp_zip.content), "r") as zf:
            assert "test_document_extracted.txt" in zf.namelist()
            content = zf.read("test_document_extracted.txt").decode("utf-8")
            assert "First page text content" in content

        DEV_JOB_STORE.pop(job_id, None)

        # E) Test Single-Job All-Formats ZIP download on cold boot
        resp_job_zip = client.get(f"/api/v1/jobs/{job_id}/download/zip")
        assert resp_job_zip.status_code == 200
        assert resp_job_zip.headers["content-type"] == "application/zip"
        assert "test_document_all_formats.zip" in resp_job_zip.headers["content-disposition"]
        with zipfile.ZipFile(io.BytesIO(resp_job_zip.content), "r") as zf:
            namelist = zf.namelist()
            assert "test_document_searchable.pdf" in namelist
            assert "test_document_extracted.txt" in namelist
            assert "test_document_extracted.md" in namelist
            assert zf.read("test_document_searchable.pdf") == pdf_bytes
            assert "First page text content" in zf.read("test_document_extracted.txt").decode("utf-8")
            assert "# Page 1" in zf.read("test_document_extracted.md").decode("utf-8")

    # Clean up
    DEV_JOB_STORE.pop(job_id, None)
    DEV_PDF_STORE.pop(output_token, None)


def test_download_zip_single_job_success():
    """Verify downloading zip format for a single job packages PDF, TXT, and MD into an archive."""
    import io
    import zipfile

    job_id = "test_download_job_single_zip"
    output_token = "token_pdf_single_zip"
    pdf_bytes = b"%PDF-1.4 single job pdf content"
    DEV_PDF_STORE[output_token] = pdf_bytes

    completed_job = {
        "job_id": job_id,
        "filename": "my_notes.pdf",
        "status": "COMPLETED",
        "total_pages": 1,
        "output_pdf_token": output_token,
        "pages": [{"page_number": 1, "text": "Notes page text"}]
    }
    DEV_JOB_STORE[job_id] = json.dumps(completed_job)

    response = client.get(f"/api/v1/jobs/{job_id}/download/zip")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"
    assert 'attachment; filename="my_notes_all_formats.zip"' in response.headers["content-disposition"]

    with zipfile.ZipFile(io.BytesIO(response.content), "r") as zf:
        namelist = zf.namelist()
        assert "my_notes_searchable.pdf" in namelist
        assert "my_notes_extracted.txt" in namelist
        assert "my_notes_extracted.md" in namelist
        assert zf.read("my_notes_searchable.pdf") == pdf_bytes
        assert "Notes page text" in zf.read("my_notes_extracted.txt").decode("utf-8")
        assert "# Page 1" in zf.read("my_notes_extracted.md").decode("utf-8")


