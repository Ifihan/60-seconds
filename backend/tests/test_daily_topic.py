import pytest
from httpx import AsyncClient


async def _auth_headers(client: AsyncClient, email: str, password: str = "password123") -> dict:
    resp = await client.post("/auth/signup", json={"email": email, "password": password})
    token = resp.json()["token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_daily_topic_no_preferred_area(client: AsyncClient):
    headers = await _auth_headers(client, "daily_no_pref@test.com")
    resp = await client.get("/daily-topic", headers=headers)
    assert resp.status_code == 200
    assert resp.json() is None


@pytest.mark.asyncio
async def test_daily_topic_empty_area(client: AsyncClient):
    headers = await _auth_headers(client, "daily_empty@test.com")
    create = await client.post("/areas", json={"name": "Empty Area"}, headers=headers)
    area_id = create.json()["id"]
    await client.post(f"/areas/{area_id}/preferred", headers=headers)

    resp = await client.get("/daily-topic", headers=headers)
    assert resp.status_code == 200
    assert resp.json() is None


@pytest.mark.asyncio
async def test_daily_topic_is_stable_across_calls(client: AsyncClient):
    headers = await _auth_headers(client, "daily_stable@test.com")
    create = await client.post("/areas", json={"name": "Daily Area"}, headers=headers)
    area_id = create.json()["id"]
    await client.post(
        f"/areas/{area_id}/topics",
        json={"names": ["Topic A", "Topic B", "Topic C"]},
        headers=headers,
    )
    await client.post(f"/areas/{area_id}/preferred", headers=headers)

    first = await client.get("/daily-topic", headers=headers)
    assert first.status_code == 200
    first_data = first.json()
    assert first_data is not None
    assert first_data["area_name"] == "Daily Area"
    assert first_data["topic_name"] in ["Topic A", "Topic B", "Topic C"]

    second = await client.get("/daily-topic", headers=headers)
    assert second.status_code == 200
    assert second.json()["topic_name"] == first_data["topic_name"]
