import os
import tempfile
import pymupdf
import pytest
from app.services.pdf_composer import compose_searchable_pdf, get_searchable_pdf
from app.services.ocr_worker import process_ocr_job


def _create_sample_pdf_bytes(text_content: str = "Sample Scanned Document") -> bytes:
    doc = pymupdf.open()
    page = doc.new_page(width=595, height=842)
    # Insert visual text simulating a scanned page
    page.insert_text(pymupdf.Point(50, 100), text_content, fontsize=12)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


def _create_sample_image_bytes() -> bytes:
    # Create a 200x200 RGB image using PyMuPDF pixmap
    pix = pymupdf.Pixmap(pymupdf.csRGB, pymupdf.Rect(0, 0, 200, 200), 0)
    pix.clear_with(255)
    img_bytes = pix.tobytes("png")
    pix = None
    return img_bytes


def test_compose_searchable_pdf_from_pdf():
    job_id = "test_job_pdf_001"
    original_pdf = _create_sample_pdf_bytes("Invoice #12345")
    pages_data = [
        {
            "page_number": 1,
            "text": "Invoice #12345",
            "lines": [
                {
                    "bbox": [50.0, 85.0, 250.0, 105.0],
                    "text": "Invoice #12345"
                }
            ]
        }
    ]

    result_bytes, token = compose_searchable_pdf(job_id, pages_data, original_pdf)
    assert isinstance(result_bytes, bytes)
    assert len(result_bytes) > 0
    assert token.startswith("pdf_token_")

    # Verify searchability with PyMuPDF
    doc = pymupdf.open("pdf", result_bytes)
    assert len(doc) == 1
    page = doc[0]
    hits = page.search_for("Invoice #12345")
    assert len(hits) > 0
    extracted_text = page.get_text()
    assert "Invoice #12345" in extracted_text
    doc.close()


def test_compose_searchable_pdf_from_image():
    job_id = "test_job_img_002"
    img_bytes = _create_sample_image_bytes()
    pages_data = [
        {
            "page_number": 1,
            "text": "Scanned Image Text Line",
            "lines": [
                {
                    "bbox": [20.0, 30.0, 180.0, 50.0],
                    "text": "Scanned Image Text Line"
                }
            ]
        }
    ]

    result_bytes, token = compose_searchable_pdf(job_id, pages_data, img_bytes, is_image=True)
    assert isinstance(result_bytes, bytes)
    assert len(result_bytes) > 0

    doc = pymupdf.open("pdf", result_bytes)
    assert len(doc) == 1
    page = doc[0]
    hits = page.search_for("Scanned Image Text Line")
    assert len(hits) > 0
    doc.close()


def test_get_searchable_pdf_retrieval():
    job_id = "test_job_token_003"
    pdf_bytes = _create_sample_pdf_bytes("Token Storage Test")
    pages_data = [
        {
            "page_number": 1,
            "text": "Token Storage Test",
            "lines": [{"bbox": [10.0, 10.0, 100.0, 30.0], "text": "Token Storage Test"}]
        }
    ]

    _, token = compose_searchable_pdf(job_id, pages_data, pdf_bytes)
    retrieved_bytes = get_searchable_pdf(token)
    assert retrieved_bytes is not None
    assert len(retrieved_bytes) > 0


def test_ephemeral_file_cleanup_pdf_composer():
    job_id = "test_job_cleanup_004"
    pdf_bytes = _create_sample_pdf_bytes("Cleanup Test")
    pages_data = [
        {
            "page_number": 1,
            "text": "Cleanup Test",
            "lines": [{"bbox": [10.0, 10.0, 100.0, 30.0], "text": "Cleanup Test"}]
        }
    ]

    ram_disk_base = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    expected_temp_file = os.path.join(ram_disk_base, f"ephemeral_out_{job_id}.pdf")

    compose_searchable_pdf(job_id, pages_data, pdf_bytes)
    assert not os.path.exists(expected_temp_file)


def test_ocr_worker_integrates_pdf_composer():
    job_id = "test_worker_pdf_composer_005"
    pdf_bytes = _create_sample_pdf_bytes("Worker Integration OCR Content")

    payload = process_ocr_job(job_id, pdf_bytes, "sample_document.pdf")
    assert payload["status"] == "COMPLETED"
    assert "output_pdf_token" in payload
    token = payload["output_pdf_token"]

    searchable_pdf_bytes = get_searchable_pdf(token)
    assert searchable_pdf_bytes is not None

    doc = pymupdf.open("pdf", searchable_pdf_bytes)
    assert len(doc) > 0
    text = doc[0].get_text()
    doc.close()


def test_get_searchable_pdf_from_redis_when_local_cache_misses():
    from unittest.mock import patch, MagicMock
    from app.services.pdf_composer import DEV_PDF_STORE

    token = "pdf_token_redis_cold_boot_test"
    dummy_pdf_bytes = b"%PDF-1.4 simulated pdf content"

    # Ensure token is NOT in local RAM cache or on disk (simulating fresh cold boot container instance)
    DEV_PDF_STORE.pop(token, None)
    file_path = DEV_PDF_STORE._file_path(token)
    if os.path.exists(file_path):
        os.remove(file_path)

    mock_redis = MagicMock()
    mock_redis.get.return_value = dummy_pdf_bytes

    with patch("app.services.pdf_composer.get_redis_client", return_value=mock_redis):
        retrieved = get_searchable_pdf(token)

        assert retrieved == dummy_pdf_bytes
        mock_redis.get.assert_called_once_with(f"pdf:{token}")
        # Verify it was repopulated in local RAM cache
        assert DEV_PDF_STORE.get(token) == dummy_pdf_bytes
        DEV_PDF_STORE.pop(token, None)
        if os.path.exists(file_path):
            os.remove(file_path)


def test_compose_searchable_pdf_with_rotation_and_morph_scaling():
    job_id = "test_job_rot_morph_007"
    pdf_bytes = _create_sample_pdf_bytes("Original Page")
    pages_data = [
        {
            "page_number": 1,
            "text": "Rotated Precision Text",
            "rotation": 90,
            "lines": [
                {
                    "bbox": [50.0, 100.0, 350.0, 125.0],
                    "text": "Rotated Precision Text"
                }
            ]
        }
    ]

    out_bytes, token = compose_searchable_pdf(job_id, pages_data, pdf_bytes)
    assert out_bytes is not None
    assert len(out_bytes) > 0

    doc = pymupdf.open("pdf", out_bytes)
    assert len(doc) == 1
    # Verify page rotation was applied
    assert doc[0].rotation == 90
    extracted_text = doc[0].get_text()
    assert "Rotated Precision Text" in extracted_text
    doc.close()
