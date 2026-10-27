from fastapi.testclient import TestClient

from app import rate_limit
from app.auth import get_current_uid
from app.config import settings
from app.main import app

client = TestClient(app)


class _Doc:
    def to_dict(self):
        return {"valueMgDl": 110}


class _Query:
    def order_by(self, *args, **kwargs):
        return self

    def limit(self, *args, **kwargs):
        return self

    def stream(self):
        return [_Doc(), _Doc()]


def setup_function():
    app.dependency_overrides.clear()
    rate_limit._buckets.clear()
    settings.openai_api_key = ""


def teardown_function():
    app.dependency_overrides.clear()
    rate_limit._buckets.clear()
    settings.openai_api_key = ""
    settings.rate_limit_per_minute = 20


def test_health():
    resp = client.get("/health")
    assert resp.status_code == 200


def test_assistant_missing_token():
    resp = client.post(
        "/assistant",
        json={"question": "Resume mis registros", "disclaimerAccepted": True},
    )
    assert resp.status_code == 401


def test_assistant_invalid_token(monkeypatch):
    def boom(token):
        raise ValueError("bad")

    monkeypatch.setattr("app.auth.verify_id_token", boom)
    resp = client.post(
        "/assistant",
        json={"question": "Resume mis registros", "disclaimerAccepted": True},
        headers={"Authorization": "Bearer invalid"},
    )
    assert resp.status_code == 401


def test_assistant_validation():
    app.dependency_overrides[get_current_uid] = lambda: "uid-1"
    resp = client.post(
        "/assistant",
        json={"question": "ab", "disclaimerAccepted": True},
    )
    assert resp.status_code == 422


def test_assistant_uses_token_uid_and_local_summary(monkeypatch):
    seen = {}

    def col(uid):
        seen["uid"] = uid
        return _Query()

    monkeypatch.setattr("app.main.user_readings_collection", col)
    app.dependency_overrides[get_current_uid] = lambda: "owner"
    resp = client.post(
        "/assistant",
        json={
            "question": "Resume mis registros recientes",
            "disclaimerAccepted": True,
            "userId": "otro-usuario",
        },
    )
    assert resp.status_code == 200
    assert "Resumen automático" in resp.json()["answer"]
    assert seen["uid"] == "owner"


def test_assistant_ai_provider_unavailable(monkeypatch):
    monkeypatch.setattr("app.main.user_readings_collection", lambda uid: _Query())
    settings.openai_api_key = "placeholder-not-a-secret"

    async def fail(*args, **kwargs):
        return None

    monkeypatch.setattr("app.main.maybe_openai_answer", fail)
    app.dependency_overrides[get_current_uid] = lambda: "owner"
    resp = client.post(
        "/assistant",
        json={"question": "Resume mis registros", "disclaimerAccepted": True},
    )
    assert resp.status_code == 503


def test_assistant_rate_limit(monkeypatch):
    monkeypatch.setattr("app.main.user_readings_collection", lambda uid: _Query())
    settings.rate_limit_per_minute = 1
    app.dependency_overrides[get_current_uid] = lambda: "limited"
    payload = {"question": "Resume mis registros", "disclaimerAccepted": True}
    assert client.post("/assistant", json=payload).status_code == 200
    assert client.post("/assistant", json=payload).status_code == 429
    settings.rate_limit_per_minute = 20
