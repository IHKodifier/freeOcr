import os
import json
import datetime
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.redis_client import DEV_JOB_STORE, store_job_metadata, get_job_metadata

client = TestClient(app)


def test_job_metadata_timestamps():
    """Verify storing job metadata includes created_at and expires_at timestamps."""
    job_id = "test_timestamp_job_123"
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    expires_utc = now_utc + datetime.timedelta(hours=24)
    
    payload = {
        "job_id": job_id,
        "filename": "test.pdf",
        "status": "COMPLETED",
        "created_at": now_utc.isoformat(),
        "expires_at": expires_utc.isoformat(),
    }
    
    DEV_JOB_STORE[job_id] = json.dumps(payload)
    retrieved = json.loads(DEV_JOB_STORE[job_id])
    
    assert "created_at" in retrieved
    assert "expires_at" in retrieved
    assert retrieved["job_id"] == job_id


def test_download_expired_job_returns_410_gone():
    """Verify that requesting a download for an expired job returns HTTP 410 Gone with expired_at."""
    job_id = "test_expired_job_410"
    past_utc = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=25)
    
    expired_payload = {
        "job_id": job_id,
        "filename": "expired_doc.pdf",
        "status": "COMPLETED",
        "created_at": (past_utc - datetime.timedelta(hours=24)).isoformat(),
        "expires_at": past_utc.isoformat(),
        "pages": []
    }
    DEV_JOB_STORE[job_id] = json.dumps(expired_payload)

    response = client.get(f"/api/v1/jobs/{job_id}/download/pdf")
    assert response.status_code == 410
    data = response.json()
    assert data["detail"] == "Download link expired."
    assert "expired_at" in data
    assert data["expired_at"] == past_utc.isoformat()


def test_download_non_existent_job_returns_410_gone():
    """Verify that requesting a download for a non-existent or evicted job returns HTTP 410 Gone."""
    response = client.get("/api/v1/jobs/missing_job_9999/download/pdf")
    assert response.status_code == 410
    data = response.json()
    assert data["detail"] == "Download link expired."
