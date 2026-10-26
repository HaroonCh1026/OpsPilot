from fastapi.testclient import TestClient

from app.main import app
from app.settings import Settings

client = TestClient(app)


def test_health_returns_success_and_status() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_settings_are_loaded_from_environment(monkeypatch) -> None:
    monkeypatch.setenv("OPSPILOT_AI_APP_NAME", "Test AI Service")

    assert Settings().app_name == "Test AI Service"
