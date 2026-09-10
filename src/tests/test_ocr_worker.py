import os
import json
import tempfile
import pytest
from unittest.mock import MagicMock, patch
import pymupdf
from fastapi.testclient import TestClient
from app.main import app
from app.services.ocr_worker import process_ocr_job
from app.redis_client import DEV_JOB_STORE

client = TestClient(app)


def create_sample_pdf_bytes(page_count: int = 2) -> bytes:
    doc = pymupdf.open()
    for i in range(page_count):
        page = doc.new_page()
        page.insert_text((50, 50), f"Sample page {i + 1} text content for OCR testing.")
    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


def test_process_ocr_job_success():
    job_id = "test-job-ocr-success-123"
    pdf_bytes = create_sample_pdf_bytes(page_count=2)
    filename = "sample_test.pdf"

    fake_redis = MagicMock()
    with patch("app.services.ocr_worker.get_redis_client", return_value=fake_redis):
        result = process_ocr_job(job_id=job_id, file_bytes=pdf_bytes, filename=filename)

    assert result["status"] == "COMPLETED"
    assert result["job_id"] == job_id
    assert result["total_pages"] == 2
    assert "output_pdf_token" in result
    assert len(result["pages"]) == 2

    # Verify Redis publish was called for progress and completion
    assert fake_redis.publish.called
    publish_calls = fake_redis.publish.call_args_list

    # Should publish event for channel job_events:test-job-ocr-success-123
    channel_name = f"job_events:{job_id}"
    channels_published = [call.args[0] for call in publish_calls]
    assert channel_name in channels_published

    # Verify job store holds completed payload
    assert job_id in DEV_JOB_STORE
    stored_payload = json.loads(DEV_JOB_STORE[job_id])
    assert stored_payload["status"] == "COMPLETED"
    assert stored_payload["output_pdf_token"] == result["output_pdf_token"]


def test_process_ocr_job_ephemeral_file_cleanup_on_exception():
    job_id = "test-job-ocr-exception-456"
    pdf_bytes = create_sample_pdf_bytes(page_count=1)
    filename = "corrupt.pdf"

    fake_redis = MagicMock()

    # Patch pymupdf.open to raise Exception after temp file is written to verify finally block execution
    with patch("pymupdf.open", side_effect=RuntimeError("Simulated OCR processing error")), \
         patch("app.services.ocr_worker.get_redis_client", return_value=fake_redis):
        
        result = process_ocr_job(job_id=job_id, file_bytes=pdf_bytes, filename=filename)

    assert result["status"] == "FAILED"
    assert result["job_id"] == job_id
    assert ("Simulated OCR processing error" in result["error_message"] or "CORRUPTED_PDF_UNREPAIRABLE" in result["error_message"])

    # Verify file was cleaned up and does not exist in temp dir
    temp_dir = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    expected_temp_file = os.path.join(temp_dir, f"ephemeral_{job_id}_{filename}")
    assert not os.path.exists(expected_temp_file)

    # Verify Redis failed event was published
    assert fake_redis.publish.called
    published_payloads = [json.loads(call.args[1]) for call in fake_redis.publish.call_args_list]
    failed_events = [p for p in published_payloads if p.get("status") == "FAILED"]
    assert len(failed_events) == 1
    assert failed_events[0]["error_message"] in ("Simulated OCR processing error", "CORRUPTED_PDF_UNREPAIRABLE")



def test_process_ocr_job_image_file():
    job_id = "test-job-ocr-image-789"
    # Create single page PDF or PNG pixmap with legible OCR resolution
    doc = pymupdf.open()
    page = doc.new_page(width=400, height=150)
    page.insert_text((30, 70), "Image text OCR test", fontsize=18)
    pix = page.get_pixmap(dpi=150)
    png_bytes = pix.tobytes("png")
    doc.close()

    filename = "sample_image.png"

    fake_redis = MagicMock()
    with patch("app.services.ocr_worker.get_redis_client", return_value=fake_redis):
        result = process_ocr_job(job_id=job_id, file_bytes=png_bytes, filename=filename)

    assert result["status"] == "COMPLETED"
    assert result["job_id"] == job_id
    assert result["total_pages"] == 1
    assert len(result["pages"]) == 1
    assert "Image" in result["pages"][0]["text"]
    assert len(result["pages"][0]["lines"]) > 0


def test_convert_endpoint_triggers_background_ocr_worker():
    pdf_bytes = create_sample_pdf_bytes(page_count=1)
    fake_redis = MagicMock()

    with patch("app.redis_client.get_redis_client", return_value=fake_redis), \
         patch("app.api.v1.endpoints.ocr.get_redis_client", return_value=fake_redis), \
         patch("app.api.v1.endpoints.ocr.process_ocr_job") as mock_worker:
        
        response = client.post(
            "/api/v1/ocr/convert",
            files={"file": ("test_doc.pdf", pdf_bytes, "application/pdf")}
        )

        assert response.status_code == 202
        data = response.json()
        assert "job_id" in data
        assert data["status"] == "QUEUED"

        # Verify background worker function was scheduled
        mock_worker.assert_called_once()
        call_kwargs = mock_worker.call_args.kwargs if mock_worker.call_args.kwargs else {}
        call_args = mock_worker.call_args.args if mock_worker.call_args.args else ()
        
        # Check job_id was passed to process_ocr_job
        passed_job_id = call_kwargs.get("job_id") if "job_id" in call_kwargs else call_args[0]
        assert passed_job_id == data["job_id"]


def test_parse_html_table_to_lines():
    from app.services.ocr_worker import parse_html_table_to_lines

    sample_html = "<table><tr><td>Office equipment</td><td>Computers</td></tr><tr><td>1,594,836</td><td>4,737,344</td></tr></table>"
    bbox = [50.0, 100.0, 500.0, 200.0]
    lines = parse_html_table_to_lines(sample_html, bbox)

    assert len(lines) == 2
    assert "Office equipment" in lines[0]["text"]
    assert "Computers" in lines[0]["text"]
    assert "1,594,836" in lines[1]["text"]
    assert lines[0]["bbox"][1] == 100.0
    assert lines[0]["bbox"][3] == 150.0
    assert lines[1]["bbox"][1] == 150.0
    assert lines[1]["bbox"][3] == 200.0


def test_detect_page_orientation():
    from app.services.ocr_worker import detect_page_orientation, _get_tessdata_dir

    tess_dir = _get_tessdata_dir()
    doc = pymupdf.open()
    page = doc.new_page(width=600, height=800)
    # Insert common words
    page.insert_text((50, 100), "The financial statements for the year ended December 31 report total assets and balance.", fontsize=14)

    # Test upright page
    assert detect_page_orientation(page, tess_dir=tess_dir) == 0

    doc.close()

