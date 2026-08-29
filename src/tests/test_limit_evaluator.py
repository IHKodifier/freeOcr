import json
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.config import load_canonical_config, CONFIG_JSON_PATH

client = TestClient(app)


def test_limit_config_values():
    """Verify that canonical limits config contains base_max_file_mb, boost_per_ad_mb, and max_stack_file_mb."""
    cfg = load_canonical_config()
    assert "limits" in cfg
    limits = cfg["limits"]
    assert "base_max_file_mb" in limits
    assert "boost_per_ad_mb" in limits
    assert "max_stack_file_mb" in limits
    assert limits["base_max_file_mb"] > 0
    assert limits["boost_per_ad_mb"] > 0
    assert limits["max_stack_file_mb"] >= limits["base_max_file_mb"]


def test_get_config_limits_endpoint():
    """Verify GET /api/v1/config returns canonical limit configuration."""
    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert "limits" in data
    limits = data["limits"]
    assert limits["base_max_file_mb"] == 10
    assert limits["boost_per_ad_mb"] == 20
    assert limits["max_stack_file_mb"] == 500


def test_dynamic_limit_config_reload(tmp_path, monkeypatch):
    """Verify that modifying limits in configuration file updates runtime config dynamically."""
    custom_cfg = {
        "limits": {
            "base_max_file_mb": 15,
            "simple_quota_jobs_5h": 20,
            "complex_quota_jobs_5h": 5,
            "boost_per_ad_mb": 25,
            "ad_boost_ttl_seconds": 3600,
            "max_stack_file_mb": 600,
        },
        "monetization": {
            "rewarded_ad_duration_seconds": 15,
            "display_ads_enabled": True,
            "rewarded_ads_enabled": True,
        },
    }
    dummy_file = tmp_path / "app_limits_config.json"
    dummy_file.write_text(json.dumps(custom_cfg), encoding="utf-8")

    monkeypatch.setattr("app.config.CONFIG_JSON_PATH", dummy_file)

    response = client.get("/api/v1/config")
    assert response.status_code == 200
    data = response.json()
    assert data["limits"]["base_max_file_mb"] == 15
    assert data["limits"]["boost_per_ad_mb"] == 25
    assert data["limits"]["max_stack_file_mb"] == 600
