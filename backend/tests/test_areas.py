import pytest
from httpx import AsyncClient


async def _auth_headers(client: AsyncClient, email: str, password: str = "password123") -> dict:
    resp = await client.post("/auth/signup", json={"email": email, "password": password})
    token = resp.json()["token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_list_areas_only_own(client: AsyncClient):
    headers1 = await _auth_headers(client, "areas_user1@test.com")
    headers2 = await _auth_headers(client, "areas_user2@test.com")

    await client.post("/areas", json={"name": "CS", "type": "KNOWN"}, headers=headers1)
    await client.post("/areas", json={"name": "Math", "type": "KNOWN"}, headers=headers2)

    resp = await client.get("/areas", headers=headers1)
    assert resp.status_code == 200
    names = [a["name"] for a in resp.json()]
    assert "CS" in names
    assert "Math" not in names


@pytest.mark.asyncio
async def test_create_area_success(client: AsyncClient):
    headers = await _auth_headers(client, "create_area@test.com")
    resp = await client.post("/areas", json={"name": "Physics", "type": "NEW"}, headers=headers)
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Physics"
    assert data["type"] == "NEW"
    assert data["topic_count"] == 0


@pytest.mark.asyncio
async def test_create_area_duplicate_name(client: AsyncClient):
    headers = await _auth_headers(client, "dup_area@test.com")
    await client.post("/areas", json={"name": "Dup"}, headers=headers)
    resp = await client.post("/areas", json={"name": "Dup"}, headers=headers)
    assert resp.status_code == 409
    assert resp.json()["error"]["code"] == "CONFLICT"


@pytest.mark.asyncio
async def test_patch_area(client: AsyncClient):
    headers = await _auth_headers(client, "patch_area@test.com")
    create = await client.post("/areas", json={"name": "Old Name"}, headers=headers)
    area_id = create.json()["id"]
    resp = await client.patch(f"/areas/{area_id}", json={"name": "New Name"}, headers=headers)
    assert resp.status_code == 200
    assert resp.json()["name"] == "New Name"


@pytest.mark.asyncio
async def test_delete_area(client: AsyncClient):
    headers = await _auth_headers(client, "delete_area@test.com")
    create = await client.post("/areas", json={"name": "To Delete"}, headers=headers)
    area_id = create.json()["id"]
    resp = await client.delete(f"/areas/{area_id}", headers=headers)
    assert resp.status_code == 204
