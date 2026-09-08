from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_contact_submit_valid():
    response = client.post(
        "/api/v1/contact",
        json={
            "name": "Jane Doe",
            "email": "jane@example.com",
            "category": "General Inquiry",
            "subject": "Question about API limits",
            "message": "Hi, I would like to ask about the rewarded video ad extensions.",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "received"
    assert "Thank you!" in data["message"]
    assert data["data"]["name"] == "Jane Doe"
    assert data["data"]["email"] == "jane@example.com"


def test_contact_submit_invalid_email():
    response = client.post(
        "/api/v1/contact",
        json={
            "name": "Jane Doe",
            "email": "invalid-email-address",
            "category": "Bug Report",
            "subject": "Scan failed",
            "message": "The scan didn't process.",
        },
    )
    assert response.status_code == 422
    assert "Invalid email address" in response.json()["detail"]


def test_contact_submit_empty_fields():
    response = client.post(
        "/api/v1/contact",
        json={
            "name": "   ",
            "email": "jane@example.com",
            "category": "General Inquiry",
            "subject": "Test",
            "message": "Test message",
        },
    )
    assert response.status_code == 422
    assert "Name cannot be empty" in response.json()["detail"]
