from datetime import datetime, timezone

import pytest
from httpx import AsyncClient


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
