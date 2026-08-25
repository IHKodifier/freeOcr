import pytest
import pymupdf
from fastapi.testclient import TestClient
from app.main import app
from app.services.ocr_worker import process_ocr_job

client = TestClient(app)


def _create_encrypted_pdf_bytes(user_password: str = "secret123") -> bytes:
    doc = pymupdf.open()
    page = doc.new_page()
    page.insert_text((50, 50), "Confidential Document Content for OCR Decryption Test")
    pdf_bytes = doc.tobytes(
        encryption=pymupdf.PDF_ENCRYPT_AES_256,
        user_pw=user_password,
        owner_pw="ownerpass123",
    )
    doc.close()
    return pdf_bytes


def _create_normal_pdf_bytes() -> bytes:
    doc = pymupdf.open()
    page = doc.new_page()
    page.insert_text((50, 50), "Standard Non-Encrypted Document Content")
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


def test_encrypted_pdf_rejected_without_password():
    pdf_bytes = _create_encrypted_pdf_bytes("secret123")
    response = client.post(
        "/api/v1/ocr/convert",
        files={"file": ("protected.pdf", pdf_bytes, "application/pdf")},
    )
    assert response.status_code == 422
    json_data = response.json()
    assert json_data.get("error") == "PASSWORD_REQUIRED"
    assert "Password Protected PDF" in json_data.get("message", "")


def test_encrypted_pdf_rejected_with_invalid_password():
    pdf_bytes = _create_encrypted_pdf_bytes("secret123")
    response = client.post(
        "/api/v1/ocr/convert",
        files={"file": ("protected.pdf", pdf_bytes, "application/pdf")},
        data={"password": "wrongpassword"},
    )
    assert response.status_code == 422
    json_data = response.json()
    assert json_data.get("error") == "PASSWORD_REQUIRED"
    assert "Password Protected PDF" in json_data.get("message", "")


def test_encrypted_pdf_accepted_with_correct_password():
    pdf_bytes = _create_encrypted_pdf_bytes("secret123")
    response = client.post(
        "/api/v1/ocr/convert",
        files={"file": ("protected.pdf", pdf_bytes, "application/pdf")},
        data={"password": "secret123"},
    )
    assert response.status_code == 202
    json_data = response.json()
    assert "job_id" in json_data
    assert json_data.get("status") == "QUEUED"


def test_ocr_worker_decryption_process():
    pdf_bytes = _create_encrypted_pdf_bytes("secret123")
    result = process_ocr_job(
        job_id="test_decryption_job_1",
        file_bytes=pdf_bytes,
        filename="protected.pdf",
        target_engine="OCRmyPDF",
        queue_name="ocr:queue:cpu",
        password="secret123",
    )
    assert result.get("status") == "COMPLETED"
    assert len(result.get("pages", [])) > 0
    assert "Confidential Document Content" in result["pages"][0]["text"]


def test_non_encrypted_pdf_unaffected():
    pdf_bytes = _create_normal_pdf_bytes()
    response = client.post(
        "/api/v1/ocr/convert",
        files={"file": ("normal.pdf", pdf_bytes, "application/pdf")},
    )
    assert response.status_code == 202
    json_data = response.json()
    assert "job_id" in json_data
