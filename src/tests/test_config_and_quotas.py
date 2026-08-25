import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.config import load_canonical_config

client = TestClient(app)


def test_canonical_config_loader():
    cfg = load_canonical_config()
    assert "limits" in cfg
    assert "engines" in cfg
    assert cfg["engines"]["simple_engine"] == "OCRmyPDF"
    assert cfg["engines"]["complex_engine"] == "Baidu_Unlimited_OCR"


def test_get_config_endpoint():
    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert "limits" in data
    assert "monetization" in data


def test_rewarded_ad_callback_stacking():
    response = client.post("/api/v1/ocr/rewarded-ad-callback")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "SUCCESS"
    assert data["ads_watched_count"] >= 1
    assert data["ttl_seconds"] == 3600
