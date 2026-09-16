import json
import re
import sys
from pathlib import Path
import pytest
from fastapi.testclient import TestClient

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.main import app

client = TestClient(app)
ROOT_DIR = Path(__file__).resolve().parent.parent.parent


def test_cloud_run_configuration_scale_to_zero():
    """Validates CI/CD deploy workflow explicitly enforces scale-to-zero Cloud Run flags for FreePDFToolz."""
    workflow_path = ROOT_DIR / ".github" / "workflows" / "deploy.yml"
    assert workflow_path.exists(), "deploy.yml workflow file must exist"

    content = workflow_path.read_text(encoding="utf-8")
    
    # Assert deploy-freepdftoolz job exists
    assert "deploy-freepdftoolz:" in content

    # Assert scale-to-zero flags are enforced
    assert "--min-instances 0" in content, "Cloud Run deploy must enforce --min-instances 0 for zero idle costs"
    assert "--max-instances 5" in content, "Cloud Run deploy must enforce --max-instances 5 to prevent bill spikes"


def test_firebase_hosting_rewrites_config():
    """Validates firebase.json properly defines multi-site rewrites for freepdftoolz to freepdftoolz-api and SPA routes."""
    firebase_json_path = ROOT_DIR / "firebase.json"
    assert firebase_json_path.exists(), "firebase.json must exist"

    with open(firebase_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    hosting_configs = data.get("hosting")
    assert isinstance(hosting_configs, list), "firebase.json hosting must be a multi-site configuration list"

    freepdftoolz_config = None
    for item in hosting_configs:
        if item.get("site") == "freepdftoolz" or item.get("target") == "freepdftoolz":
            freepdftoolz_config = item
            break

    assert freepdftoolz_config is not None, "Hosting configuration for site 'freepdftoolz' must be present"

    rewrites = freepdftoolz_config.get("rewrites", [])
    api_rewrite = next((r for r in rewrites if r.get("source") == "/api/**"), None)
    assert api_rewrite is not None, "API rewrite for /api/** must exist"
    assert api_rewrite.get("run", {}).get("serviceId") == "freepdftoolz-api", "API rewrite must route to freepdftoolz-api Cloud Run service"

    spa_rewrite = next((r for r in rewrites if r.get("source") == "**"), None)
    assert spa_rewrite is not None, "SPA rewrite for ** must exist"
    assert spa_rewrite.get("destination") == "/index.html", "SPA rewrite must point to /index.html"


def test_health_probe_live_endpoint():
    """Smoke tests health endpoint asserting GET /api/v1/health returns HTTP 200 and healthy status."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data.get("status") in ("ok", "healthy")


def test_cors_headers_match_freepdftoolz_domain():
    """Verifies backend CORS middleware correctly responds to requests from https://freepdftoolz.me."""
    response = client.options(
        "/api/v1/health",
        headers={
            "Origin": "https://freepdftoolz.me",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.status_code == 200
    allow_origin = response.headers.get("access-control-allow-origin")
    assert allow_origin in ("*", "https://freepdftoolz.me")
