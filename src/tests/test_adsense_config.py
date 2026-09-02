import json
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.config import load_canonical_config, CONFIG_JSON_PATH

client = TestClient(app)


def test_adsense_config_interval_loaded():
    """Verify that monetization parameters are present in backend configuration."""
    cfg = load_canonical_config()
    assert "monetization" in cfg
    monetization = cfg["monetization"]
    assert "display_ads_enabled" in monetization
    assert "rewarded_ads_enabled" in monetization
    assert isinstance(monetization["display_ads_enabled"], bool)


def test_adsense_config_api_endpoint():
    """Verify that GET /api/v1/config endpoint returns monetization configuration."""
    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert "monetization" in data
    monetization = data["monetization"]
    assert "display_ads_enabled" in monetization
    assert monetization["display_ads_enabled"] is True


def test_dynamic_config_file_reload(tmp_path, monkeypatch):
    """Verify that modifying monetization parameters in config file is reflected dynamically."""
    test_config = {
        "limits": {"base_max_file_mb": 50},
        "monetization": {
            "rewarded_ad_duration_seconds": 20,
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
    assert data["monetization"]["rewarded_ad_duration_seconds"] == 20

