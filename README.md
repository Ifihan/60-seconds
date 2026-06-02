# 60 Seconds

A speaking fluency app that helps users practice explaining topics out loud — in 60 seconds.

## Monorepo Structure

```
60_seconds/
├── backend/      # FastAPI REST API (Python 3.12+, PostgreSQL)
├── app/          # Flutter mobile app (iOS & Android)
└── frontend/     # Web app (stack TBD)
```

## Backend

FastAPI REST API handling authentication, knowledge areas, topics, and session logging. Recordings stay on device — the backend only stores metadata.

**Stack:** Python · FastAPI · PostgreSQL · SQLAlchemy 2.0 (async) · Alembic · JWT

### Getting started

```bash
cd backend

# Install dependencies (requires uv)
uv sync

# Copy and fill in environment variables
cp .env.example .env

# Run database migrations
alembic upgrade head

# Start dev server
uvicorn app.main:app --reload

# Run tests
pytest
```

See [backend/CLAUDE.md](backend/CLAUDE.md) for full API documentation, data models, and endpoint specs.

## App

Flutter mobile app (iOS & Android) — coming soon.

## Frontend

Web app — coming soon. Stack TBD.

## Environment Variables

Backend requires a `.env` file at `backend/.env`. See [backend/.env.example](backend/.env.example) for the required variables:

| Variable              | Description                           |
| --------------------- | ------------------------------------- |
| `DATABASE_URL`        | PostgreSQL async connection string    |
| `JWT_SECRET`          | Secret key (min 32 characters)        |
| `JWT_EXPIRES_MINUTES` | Token TTL in minutes (default: 10080) |
| `ENVIRONMENT`         | `development` or `production`         |
