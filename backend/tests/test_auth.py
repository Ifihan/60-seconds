import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_signup_success(client: AsyncClient):
    resp = await client.post("/auth/signup", json={"email": "user@test.com", "password": "password123"})
    assert resp.status_code == 201
    data = resp.json()
    assert "token" in data
    assert data["user"]["email"] == "user@test.com"


@pytest.mark.asyncio
async def test_signup_duplicate_email(client: AsyncClient):
    payload = {"email": "dup@test.com", "password": "password123"}
    await client.post("/auth/signup", json=payload)
    resp = await client.post("/auth/signup", json=payload)
    assert resp.status_code == 409
    assert resp.json()["error"]["code"] == "CONFLICT"


@pytest.mark.asyncio
async def test_login_success(client: AsyncClient):
    await client.post("/auth/signup", json={"email": "login@test.com", "password": "password123"})
    resp = await client.post("/auth/login", json={"email": "login@test.com", "password": "password123"})
    assert resp.status_code == 200
    assert "token" in resp.json()


@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient):
    await client.post("/auth/signup", json={"email": "wrong@test.com", "password": "password123"})
    resp = await client.post("/auth/login", json={"email": "wrong@test.com", "password": "badpassword"})
    assert resp.status_code == 401
    assert resp.json()["error"]["code"] == "UNAUTHORIZED"
