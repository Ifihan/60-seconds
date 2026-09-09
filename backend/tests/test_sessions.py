from datetime import datetime, timezone

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import UpstreamError
from app.models.area import Area
from app.services.gemini import SpeechAnalysis


async def _auth_headers(client: AsyncClient, email: str, password: str = "password123") -> dict:
    resp = await client.post("/auth/signup", json={"email": email, "password": password})
    token = resp.json()["token"]
    return {"Authorization": f"Bearer {token}"}


async def _create_area(client: AsyncClient, headers: dict, name: str = "TestArea") -> str:
    resp = await client.post("/areas", json={"name": name, "type": "KNOWN"}, headers=headers)
    return resp.json()["id"]


@pytest.mark.asyncio
async def test_create_session_success(client: AsyncClient):
    headers = await _auth_headers(client, "sess_ok@test.com")
    area_id = await _create_area(client, headers)

    resp = await client.post(
        "/sessions",
        json={
            "area_id": area_id,
            "topic": "How indexing works",
            "mode": "AUDIO",
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
        headers=headers,
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["area_id"] == area_id
    assert data["topic"] == "How indexing works"


@pytest.mark.asyncio
async def test_create_session_global_area_without_subscription(client: AsyncClient, db: AsyncSession):
    headers = await _auth_headers(client, "sess_unsubscribed@test.com")

    global_area = Area(name="Global Area", user_id=None)
    db.add(global_area)
    await db.commit()
    await db.refresh(global_area)

    resp = await client.post(
        "/sessions",
        json={
            "area_id": global_area.id,
            "topic": "Practiced without subscribing",
            "mode": "AUDIO",
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
        headers=headers,
    )
    assert resp.status_code == 201
    assert resp.json()["area_id"] == global_area.id


@pytest.mark.asyncio
async def test_create_session_area_not_owned(client: AsyncClient):
    headers1 = await _auth_headers(client, "sess_owner@test.com")
    headers2 = await _auth_headers(client, "sess_thief@test.com")
    area_id = await _create_area(client, headers1, "Owner Area")

    resp = await client.post(
        "/sessions",
        json={
            "area_id": area_id,
            "topic": "Steal topic",
            "mode": "VIDEO",
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
        headers=headers2,
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_get_sessions_pagination(client: AsyncClient):
    headers = await _auth_headers(client, "sess_page@test.com")
    area_id = await _create_area(client, headers, "PageArea")

    for i in range(5):
        await client.post(
            "/sessions",
            json={
                "area_id": area_id,
                "topic": f"Topic {i}",
                "mode": "AUDIO",
                "completed_at": datetime.now(timezone.utc).isoformat(),
            },
            headers=headers,
        )

    resp = await client.get("/sessions?page=1&limit=3", headers=headers)
    assert resp.status_code == 200
    body = resp.json()
    assert len(body["data"]) == 3
    assert body["pagination"]["total"] == 5
    assert body["pagination"]["limit"] == 3


@pytest.mark.asyncio
async def test_get_sessions_area_filter(client: AsyncClient):
    headers = await _auth_headers(client, "sess_filter@test.com")
    area_a = await _create_area(client, headers, "Area A")
    area_b = await _create_area(client, headers, "Area B")

    for area_id in [area_a, area_b]:
        await client.post(
            "/sessions",
            json={
                "area_id": area_id,
                "topic": "Some topic",
                "mode": "AUDIO",
                "completed_at": datetime.now(timezone.utc).isoformat(),
            },
            headers=headers,
        )

    resp = await client.get(f"/sessions?area_id={area_a}", headers=headers)
    assert resp.status_code == 200
    body = resp.json()
    assert body["pagination"]["total"] == 1
    assert body["data"][0]["area_id"] == area_a


async def _create_session(client: AsyncClient, headers: dict, area_id: str, topic: str = "Test topic") -> str:
    resp = await client.post(
        "/sessions",
        json={
            "area_id": area_id,
            "topic": topic,
            "mode": "AUDIO",
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
        headers=headers,
    )
    return resp.json()["id"]


_FAKE_ANALYSIS = SpeechAnalysis(
    transcript="This is a test transcript.",
    filler_word_count=3,
    words_per_minute=140,
    coherence_score=8,
    grammar_score=9,
    content_accuracy_score=7,
    feedback_summary="Solid delivery, watch the filler words.",
)


@pytest.mark.asyncio
async def test_analyze_session_success(client: AsyncClient, monkeypatch):
    async def fake_analyze_speech(audio_bytes, topic):
        return _FAKE_ANALYSIS

    monkeypatch.setattr("app.routers.sessions.analyze_speech", fake_analyze_speech)

    headers = await _auth_headers(client, "analyze_ok@test.com")
    area_id = await _create_area(client, headers, "Analyze Area")
    session_id = await _create_session(client, headers, area_id)

    resp = await client.post(
        f"/sessions/{session_id}/analyze",
        files={"audio": ("clip.webm", b"fake-audio-bytes", "audio/webm")},
        headers=headers,
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["transcript"] == _FAKE_ANALYSIS.transcript
    assert data["filler_word_count"] == 3
    assert data["feedback_summary"] == _FAKE_ANALYSIS.feedback_summary
    assert data["analyzed_at"] is not None

    listed = await client.get("/sessions", headers=headers)
    saved = next(s for s in listed.json()["data"] if s["id"] == session_id)
    assert saved["transcript"] == _FAKE_ANALYSIS.transcript


@pytest.mark.asyncio
async def test_analyze_session_not_owned(client: AsyncClient, monkeypatch):
    async def fake_analyze_speech(audio_bytes, topic):
        return _FAKE_ANALYSIS

    monkeypatch.setattr("app.routers.sessions.analyze_speech", fake_analyze_speech)

    headers1 = await _auth_headers(client, "analyze_owner@test.com")
    headers2 = await _auth_headers(client, "analyze_thief@test.com")
    area_id = await _create_area(client, headers1, "Owner Analyze Area")
    session_id = await _create_session(client, headers1, area_id)

    resp = await client.post(
        f"/sessions/{session_id}/analyze",
        files={"audio": ("clip.webm", b"fake-audio-bytes", "audio/webm")},
        headers=headers2,
    )
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_analyze_session_oversized_upload_rejected(client: AsyncClient, monkeypatch):
    called = False

    async def fake_analyze_speech(audio_bytes, topic):
        nonlocal called
        called = True
        return _FAKE_ANALYSIS

    monkeypatch.setattr("app.routers.sessions.analyze_speech", fake_analyze_speech)
    monkeypatch.setattr("app.routers.sessions.MAX_ANALYZE_UPLOAD_BYTES", 10)

    headers = await _auth_headers(client, "analyze_oversized@test.com")
    area_id = await _create_area(client, headers, "Oversized Area")
    session_id = await _create_session(client, headers, area_id)

    resp = await client.post(
        f"/sessions/{session_id}/analyze",
        files={"audio": ("clip.webm", b"this-is-more-than-ten-bytes", "audio/webm")},
        headers=headers,
    )
    assert resp.status_code == 422
    assert called is False


@pytest.mark.asyncio
async def test_analyze_session_upstream_failure(client: AsyncClient, monkeypatch):
    async def failing_analyze_speech(audio_bytes, topic):
        raise UpstreamError("Speech analysis failed")

    monkeypatch.setattr("app.routers.sessions.analyze_speech", failing_analyze_speech)

    headers = await _auth_headers(client, "analyze_fail@test.com")
    area_id = await _create_area(client, headers, "Failing Area")
    session_id = await _create_session(client, headers, area_id)

    resp = await client.post(
        f"/sessions/{session_id}/analyze",
        files={"audio": ("clip.webm", b"fake-audio-bytes", "audio/webm")},
        headers=headers,
    )
    assert resp.status_code == 502

    listed = await client.get("/sessions", headers=headers)
    saved = next(s for s in listed.json()["data"] if s["id"] == session_id)
    assert saved["transcript"] is None
