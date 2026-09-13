import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_get_tools_catalog():
    """
    Test that GET /api/v1/tools returns the full suite of PDF tools
    with expected metadata, categories, routes, and limits.
    """
    response = client.get("/api/v1/tools")
    assert response.status_code == 200
    data = response.json()
    assert "tools" in data
    assert "total" in data
    assert data["total"] >= 16

    tool_ids = [t["id"] for t in data["tools"]]
    expected_tools = [
        "ocr",
        "merge",
        "split",
        "rotate",
        "delete-pages",
        "extract-pages",
        "number-pages",
        "compress",
        "watermark",
        "crop",
        "redact",
        "sign",
        "annotate",
        "edit-text",
        "pdf-to-word",
        "summarize",
    ]
    for expected in expected_tools:
        assert expected in tool_ids, f"Tool '{expected}' missing from catalog"

    # Verify schema of individual tool
    for tool in data["tools"]:
        assert "id" in tool
        assert "name" in tool
        assert "description" in tool
        assert "category" in tool
        assert tool["category"] in ("page_ops", "security", "ai_conversions")
        assert "route" in tool
        assert tool["route"].startswith("/")
        assert tool["max_free_mb"] == 100
        assert tool["max_boosted_mb"] == 1000


def test_get_tool_categories():
    """
    Test that GET /api/v1/tools/categories returns the categorized breakdown.
    """
    response = client.get("/api/v1/tools/categories")
    assert response.status_code == 200
    data = response.json()
    assert "page_ops" in data
    assert "security" in data
    assert "ai_conversions" in data
    assert len(data["page_ops"]["tools"]) >= 6
    assert len(data["security"]["tools"]) >= 5
    assert len(data["ai_conversions"]["tools"]) >= 4


def test_get_single_tool_detail():
    """
    Test retrieving a specific tool's metadata.
    """
    response = client.get("/api/v1/tools/merge")
    assert response.status_code == 200
    tool = response.json()
    assert tool["id"] == "merge"
    assert tool["name"] == "Merge PDF"
    assert tool["route"] == "/merge"


def test_get_nonexistent_tool_returns_404():
    """
    Test that an invalid tool id returns 404.
    """
    response = client.get("/api/v1/tools/unknown-tool-xyz")
    assert response.status_code == 404
    assert response.json()["detail"] == "Tool not found"
