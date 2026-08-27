import json
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.config import load_canonical_config, CONFIG_JSON_PATH

client = TestClient(app)


def test_adsense_config_interval_loaded():
    """Verify that ad_rotation_interval_seconds is present in backend configuration."""
    cfg = load_canonical_config()
    assert "monetization" in cfg
    monetization = cfg["monetization"]
    assert "ad_rotation_interval_seconds" in monetization
    assert isinstance(monetization["ad_rotation_interval_seconds"], int)
    assert monetization["ad_rotation_interval_seconds"] > 0


def test_adsense_config_api_endpoint():
    """Verify that GET /api/v1/config endpoint returns monetization.ad_rotation_interval_seconds."""
    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert "monetization" in data
    monetization = data["monetization"]
    assert "ad_rotation_interval_seconds" in monetization
    assert monetization["ad_rotation_interval_seconds"] == 35


def test_dynamic_config_file_reload(tmp_path, monkeypatch):
    """Verify that modifying ad_rotation_interval_seconds in config file is reflected without app restart."""
    test_config = {
        "limits": {"base_max_file_mb": 10},
        "monetization": {
            "ad_rotation_interval_seconds": 45,
            "rewarded_ad_duration_seconds": 15,
            "display_ads_enabled": True,
            "rewarded_ads_enabled": True,
        },
        "engines": {"simple_engine": "OCRmyPDF"},
    }
    dummy_file = tmp_path / "app_limits_config.json"
    dummy_file.write_text(json.dumps(test_config), encoding="utf-8")

    monkeypatch.setattr("app.config.CONFIG_JSON_PATH", dummy_file)

    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert data["monetization"]["ad_rotation_interval_seconds"] == 45
