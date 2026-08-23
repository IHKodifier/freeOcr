import sys
from pathlib import Path
from unittest.mock import patch
import pytest
from fastapi.testclient import TestClient

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data
    assert data["version"] == "0.1.0"


def test_healthz_endpoint_healthy():
    """Verify /healthz endpoint returns HTTP 200 when DB and Redis are connected."""
    with patch("app.main.check_database_connection", return_value=True), \
         patch("app.main.check_redis_connection", return_value=True):
        response = client.get("/healthz")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["database"] == "connected"
        assert data["redis"] == "connected"


def test_healthz_endpoint_unhealthy_redis():
    """Verify /healthz endpoint returns HTTP 503 when Redis ping fails."""
    with patch("app.main.check_database_connection", return_value=True), \
         patch("app.main.check_redis_connection", return_value=False):
        response = client.get("/healthz")
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "unhealthy"
        assert data["database"] == "connected"
        assert data["redis"] == "unreachable"


def test_healthz_endpoint_unhealthy_database():
    """Verify /healthz endpoint returns HTTP 503 when Database ping fails."""
    with patch("app.main.check_database_connection", return_value=False), \
         patch("app.main.check_redis_connection", return_value=True):
        response = client.get("/healthz")
        assert response.status_code == 503
        data = response.json()
        assert data["status"] == "unhealthy"
        assert data["database"] == "unreachable"
        assert data["redis"] == "connected"
