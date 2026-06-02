from datetime import datetime, timedelta, timezone

import pytest
from httpx import AsyncClient
from jose import jwt

from app.config import settings
from app.utils.jwt import ALGORITHM


async def _signup(client: AsyncClient, email: str, password: str = "password123") -> dict:
    response = await client.post("/auth/signup", json={"email": email, "password": password})
    assert response.status_code == 201
    return response.json()


@pytest.mark.asyncio
async def test_access_token_contains_hardened_claims(client: AsyncClient):
    body = await _signup(client, "claims@test.com")

    payload = jwt.decode(
        body["token"],
        settings.jwt_secret,
        algorithms=[ALGORITHM],
        issuer=settings.jwt_issuer,
        audience=settings.jwt_audience,
    )

    assert payload["typ"] == "access"
    assert payload["jti"]
    assert payload["sub"] == body["user"]["id"]


@pytest.mark.asyncio
async def test_rejects_unbounded_text_inputs(client: AsyncClient):
    body = await _signup(client, "bounds@test.com")
    headers = {"Authorization": f"Bearer {body['token']}"}

    area = await client.post("/areas", json={"name": "A" * 101}, headers=headers)
    assert area.status_code == 422

    valid_area = await client.post("/areas", json={"name": "Valid"}, headers=headers)
    area_id = valid_area.json()["id"]

    session = await client.post(
        "/sessions",
        json={
            "area_id": area_id,
            "topic": "T" * 201,
            "mode": "AUDIO",
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
        headers=headers,
    )
    assert session.status_code == 422


@pytest.mark.asyncio
async def test_rejects_future_session_completion(client: AsyncClient):
    body = await _signup(client, "future@test.com")
    headers = {"Authorization": f"Bearer {body['token']}"}
    valid_area = await client.post("/areas", json={"name": "Future"}, headers=headers)

    response = await client.post(
        "/sessions",
        json={
            "area_id": valid_area.json()["id"],
            "topic": "Time travel",
            "mode": "AUDIO",
            "completed_at": (datetime.now(timezone.utc) + timedelta(hours=1)).isoformat(),
        },
        headers=headers,
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_rejects_duplicate_names_in_bulk_topic_payload(client: AsyncClient):
    body = await _signup(client, "bulk@test.com")
    headers = {"Authorization": f"Bearer {body['token']}"}
    valid_area = await client.post("/areas", json={"name": "Bulk"}, headers=headers)

    response = await client.post(
        f"/areas/{valid_area.json()['id']}/topics",
        json={"names": ["Duplicate", "Duplicate"]},
        headers=headers,
    )
    assert response.status_code == 409
