import os
import time
import json
import tempfile
from unittest.mock import MagicMock, patch
import pymupdf
import pytest
from app.services.pdf_repair import repair_pdf
from app.services.watchdog import purge_ephemeral_ram_disk
from app.services.ocr_worker import process_ocr_job
from app.redis_client import DEV_JOB_STORE


def create_minimal_pdf_bytes() -> bytes:
    """Helper to generate minimal valid single-page PDF bytes."""
    doc = pymupdf.open()
    page = doc.new_page()
    page.insert_text((50, 50), "Hello World PDF Repair Test")
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


def create_reparable_corrupted_pdf_bytes() -> bytes:
    """Helper to generate a PDF stream with broken startxref offset."""
    valid_bytes = create_minimal_pdf_bytes()
    # Replace startxref value with an out-of-bounds offset
    damaged = valid_bytes.replace(b"startxref\n", b"startxref\n99999999\n% ")
    return damaged


def test_valid_pdf_repair_noop():
    """Valid PDF bytes should return success without error."""
    pdf_bytes = create_minimal_pdf_bytes()
    success, repaired_bytes, error_code = repair_pdf(pdf_bytes)
    assert success is True
    assert error_code is None
    assert isinstance(repaired_bytes, bytes)
    assert len(repaired_bytes) > 0


def test_corrupted_pdf_repair_success():
    """Corrupted PDF stream with fixable xref should be repaired successfully."""
    damaged_bytes = create_reparable_corrupted_pdf_bytes()
    success, repaired_bytes, error_code = repair_pdf(damaged_bytes)
    assert success is True
    assert error_code is None
    # Reopened repaired bytes should be readable
    reopened_doc = pymupdf.open(stream=repaired_bytes, filetype="pdf")
    assert len(reopened_doc) >= 1
    reopened_doc.close()


def test_unrepairable_garbage_pdf_failure():
    """Random unrepairable garbage bytes should return failure status."""
    garbage_bytes = b"THIS_IS_NOT_A_PDF_STREAM_RANDOM_GARBAGE_1234567890_XYZ"
    success, result_bytes, error_code = repair_pdf(garbage_bytes)
    assert success is False
    assert error_code == "CORRUPTED_PDF_UNREPAIRABLE"
    assert result_bytes == garbage_bytes


def test_watchdog_purges_old_ephemeral_files():
    """Watchdog should purge ephemeral_* files older than max_age_seconds."""
    temp_dir = tempfile.gettempdir()
    old_file = os.path.join(temp_dir, "ephemeral_test_old_123.tmp")
    new_file = os.path.join(temp_dir, "ephemeral_test_new_456.tmp")

    try:
        with open(old_file, "w") as f:
            f.write("old file content")
        with open(new_file, "w") as f:
            f.write("new file content")

        # Age old file by setting mtime to 75 seconds ago
        past_time = time.time() - 75
        os.utime(old_file, (past_time, past_time))

        purged_count = purge_ephemeral_ram_disk(max_age_seconds=60, ram_disk_path=temp_dir)
        assert purged_count >= 1
        assert not os.path.exists(old_file)
        assert os.path.exists(new_file)

    finally:
        if os.path.exists(old_file):
            os.remove(old_file)
        if os.path.exists(new_file):
            os.remove(new_file)


def test_watchdog_ignores_non_ephemeral_files():
    """Watchdog should not touch files that do not start with ephemeral_."""
    temp_dir = tempfile.gettempdir()
    normal_file = os.path.join(temp_dir, "normal_system_file_789.tmp")

    try:
        with open(normal_file, "w") as f:
            f.write("normal file content")

        # Age normal file to 75 seconds ago
        past_time = time.time() - 75
        os.utime(normal_file, (past_time, past_time))

        purged_count = purge_ephemeral_ram_disk(max_age_seconds=60, ram_disk_path=temp_dir)
        assert os.path.exists(normal_file)

    finally:
        if os.path.exists(normal_file):
            os.remove(normal_file)


def test_ocr_worker_corrupted_pdf_repair_integration():
    """ocr_worker process_ocr_job should attempt repair on corrupted PDF and complete OCR."""
    job_id = "test_job_repair_001"
    valid_pdf_bytes = create_minimal_pdf_bytes()
    filename = "damaged_sample.pdf"

    # Simulate pymupdf.open failing on initial corrupt open, then succeeding after repair
    real_open = pymupdf.open
    open_count = 0

    def mock_open_side_effect(*args, **kwargs):
        nonlocal open_count
        open_count += 1
        if open_count == 1:
            raise pymupdf.FileDataError("Corrupted PDF stream header")
        return real_open(*args, **kwargs)


    fake_redis = MagicMock()
    with patch("app.services.ocr_worker.get_redis_client", return_value=fake_redis), \
         patch("app.services.ocr_worker.pymupdf.open", side_effect=mock_open_side_effect):
        result = process_ocr_job(job_id, valid_pdf_bytes, filename)


    assert result["status"] == "COMPLETED"

    assert result["job_id"] == job_id
    assert len(result["pages"]) >= 1

    # Verify REPAIRING status payload was published
    published_events = [json.loads(call.args[1]) for call in fake_redis.publish.call_args_list]
    repair_events = [e for e in published_events if e.get("status") == "REPAIRING"]
    assert len(repair_events) >= 1
    assert repair_events[0]["message"] == "Attempting PDF repair..."



def test_ocr_worker_unrepairable_pdf_integration():
    """ocr_worker process_ocr_job should emit FAILED status on unrepairable PDF."""
    job_id = "test_job_unrepairable_002"
    garbage_bytes = b"NOT_A_PDF_FILE_STREAM_GARBAGE"
    filename = "garbage_sample.pdf"

    fake_redis = MagicMock()
    with patch("app.services.ocr_worker.get_redis_client", return_value=fake_redis):
        result = process_ocr_job(job_id, garbage_bytes, filename)

    assert result["status"] == "FAILED"
    assert "CORRUPTED_PDF_UNREPAIRABLE" in result["error_message"]

