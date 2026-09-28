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
    """Validates CI/CD deploy workflow explicitly enforces scale-to-zero Cloud Run flags for freeOCR."""
    workflow_path = ROOT_DIR / ".github" / "workflows" / "deploy.yml"
    assert workflow_path.exists(), "deploy.yml workflow file must exist"

    content = workflow_path.read_text(encoding="utf-8")
    
    # Assert deploy-freeocr job exists
    assert "deploy-freeocr:" in content

    # Assert scale-to-zero flags are enforced
    assert "--min-instances 0" in content, "Cloud Run deploy must enforce --min-instances 0 for zero idle costs"
    assert "--max-instances 5" in content, "Cloud Run deploy must enforce --max-instances 5 to prevent bill spikes"


def test_firebase_hosting_rewrites_config():
    """Validates firebase.json properly defines hosting rewrites and public directory for freeocr-staging-app."""
    firebase_json_path = ROOT_DIR / "firebase.json"
    assert firebase_json_path.exists(), "firebase.json must exist"

    with open(firebase_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    hosting_configs = data.get("hosting")
    assert isinstance(hosting_configs, list), "firebase.json hosting must be a configuration list"

    freeocr_config = None
    for item in hosting_configs:
        if item.get("site") == "freeocr-staging-app" or item.get("target") == "freeocr-staging-app":
            freeocr_config = item
            break

    assert freeocr_config is not None, "Hosting configuration for site 'freeocr-staging-app' must be present"
    assert freeocr_config.get("public") == "src/frontend/build/web", (
        "Site 'freeocr-staging-app' must point to Flutter build folder 'src/frontend/build/web'"
    )

    rewrites = freeocr_config.get("rewrites", [])
    api_rewrite = next((r for r in rewrites if r.get("source") == "/api/**"), None)
    assert api_rewrite is not None, "API rewrite for /api/** must exist"
    assert api_rewrite.get("run", {}).get("serviceId") == "freeocr-api", "API rewrite must route to freeocr-api Cloud Run service"

    spa_rewrite = next((r for r in rewrites if r.get("source") == "**"), None)
    assert spa_rewrite is not None, "SPA rewrite for ** must exist"
    assert spa_rewrite.get("destination") == "/index.html", "SPA rewrite must point to /index.html"


def test_freeocr_pages_and_ad_compliance():
    """Validates canonical freeOCR.me static web pages and legal compliance links exist."""
    source_dir = ROOT_DIR / "src" / "frontend" / "web"
    assert source_dir.exists(), "src/frontend/web directory must exist"

    required_files = [
        "index.html",
        "about/index.html",
        "contact/index.html",
        "privacy/index.html",
        "terms/index.html",
        "sitemap.xml",
        "robots.txt",
    ]
    for rel_path in required_files:
        p = source_dir / rel_path
        assert p.exists(), f"Required file {rel_path} must exist in web directory"
        content = p.read_text(encoding="utf-8")
        if rel_path == "robots.txt":
            assert len(content) > 20, f"File {rel_path} must not be empty"
        else:
            assert len(content) > 300, f"File {rel_path} must have substantial content"

    # Verify AdSense cookie policy requirements in privacy policy
    privacy_html = (source_dir / "privacy" / "index.html").read_text(encoding="utf-8")
    assert "aboutads.info" in privacy_html or "google.com" in privacy_html, "Privacy policy must link to advertising disclosure links"
    assert "Google AdSense" in privacy_html or "DoubleClick" in privacy_html or "cookies" in privacy_html, "Privacy policy must mention Google/AdSense cookies"

    # Verify homepage references freeOCR.me
    index_html = (source_dir / "index.html").read_text(encoding="utf-8")
    assert "freeOCR.me" in index_html, "Homepage must reference freeOCR.me"


def test_freeocr_build_pipeline_in_deploy_workflow():
    """Validates deploy.yml invokes flutter build web for the freeocr deploy job."""
    workflow_path = ROOT_DIR / ".github" / "workflows" / "deploy.yml"
    content = workflow_path.read_text(encoding="utf-8")
    assert "flutter build web --release" in content, "deploy.yml must compile flutter web release bundle"


def test_health_probe_live_endpoint():
    """Smoke tests health endpoint asserting GET /api/v1/health returns HTTP 200 and healthy status."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data.get("status") in ("ok", "healthy")


def test_cors_headers_match_freeocr_domain():
    """Verifies backend CORS middleware correctly responds to requests from https://freeocr.me."""
    response = client.options(
        "/api/v1/health",
        headers={
            "Origin": "https://freeocr.me",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.status_code == 200
    allow_origin = response.headers.get("access-control-allow-origin")
    assert allow_origin in ("*", "https://freeocr.me")

