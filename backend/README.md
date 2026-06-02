# 60 Seconds — Backend

REST API for the 60 Seconds speaking fluency app. Handles authentication, a global catalog of knowledge areas and topics, user subscriptions to areas, and session logging.

## Stack

- **Python 3.12+** with **FastAPI**
- **PostgreSQL** via **SQLAlchemy 2.0** (async) + **Alembic** migrations
- **JWT** auth (`python-jose`) · password hashing (`passlib[bcrypt]`)
- **slowapi** for rate limiting
- **uv** for dependency management

## Getting started

```bash
# Install dependencies
uv sync

# Copy and fill in environment variables
cp .env.example .env

# Run migrations
alembic upgrade head

# Seed global areas + topics (and a dev test user)
python seed.py

# Start dev server
uvicorn app.main:app --reload
```

Docs available at `http://localhost:8000/docs` in development.

## Environment variables

| Variable                 | Required | Description                                          |
|--------------------------|----------|------------------------------------------------------|
| `DATABASE_URL`           | Yes      | PostgreSQL async URL (`postgresql+asyncpg://...`)    |
| `JWT_SECRET`             | Yes      | Secret key, min 32 characters, no placeholders       |
| `JWT_EXPIRES_MINUTES`    | No       | Token TTL in minutes (default: `10080` / 7 days)     |
| `ENVIRONMENT`            | No       | `development`, `test`, or `production` (default: `development`) |
| `ALLOWED_HOSTS`          | No       | Comma-separated allowed hosts (default: `localhost,127.0.0.1`) |
| `CORS_ALLOWED_ORIGINS`   | No       | Comma-separated CORS origins (default: none)         |
| `RATE_LIMIT_STORAGE_URI` | Prod only| Redis URI for distributed rate limiting              |

## Project structure

```
app/
  main.py              # App init, middleware, router registration
  config.py            # Settings via pydantic-settings
  database.py          # Async SQLAlchemy engine + session dependency
  exceptions.py        # AppException base + handler
  limiter.py           # slowapi rate limiter
  models/
    user.py            # User
    area.py            # Area (global catalog entry)
    user_area.py       # UserArea (subscription join table)
    topic.py           # Topic (belongs to an Area)
    session.py         # Session (practice session log)
  schemas/
    auth.py            # Signup/login request + token response
    area.py            # AreaOut
    topic.py           # TopicCreate, TopicBulkCreate, TopicOut
    session.py         # SessionCreate, SessionOut, PaginatedSessions
  routers/
    auth.py            # POST /auth/signup, POST /auth/login
    areas.py           # GET /areas, POST/DELETE /areas/{id}/subscribe
    topics.py          # GET/POST /areas/{id}/topics, DELETE /areas/{id}/topics/{id}
    sessions.py        # POST /sessions, GET /sessions
  dependencies/
    auth.py            # get_current_user dependency
  utils/
    jwt.py             # create_access_token, decode_token
    hashing.py         # hash_password, verify_password
alembic/               # Database migrations
tests/                 # Pytest test suite
seed.py                # Global area/topic seeding + dev user
entrypoint.sh          # Docker entrypoint (migrations + seed + server)
```

## API overview

### Auth — `/auth`

| Method | Path           | Description                        |
|--------|----------------|------------------------------------|
| POST   | `/auth/signup` | Register, returns JWT + user       |
| POST   | `/auth/login`  | Login, returns JWT + user          |

Rate limited to 10 requests/min per IP.

### Areas — `/areas` _(auth required)_

Areas are a global catalog — seeded by the system, not created by users.

| Method | Path                        | Description                              |
|--------|-----------------------------|------------------------------------------|
| GET    | `/areas`                    | All areas with `is_subscribed` flag      |
| POST   | `/areas/{id}/subscribe`     | Subscribe to an area                     |
| DELETE | `/areas/{id}/subscribe`     | Unsubscribe from an area                 |

### Topics — `/areas/{area_id}/topics` _(auth required, subscription required)_

| Method | Path                              | Description              |
|--------|-----------------------------------|--------------------------|
| GET    | `/areas/{id}/topics`              | List topics for an area  |
| POST   | `/areas/{id}/topics`              | Add a topic (single or bulk) |
| DELETE | `/areas/{id}/topics/{topic_id}`   | Delete a topic           |

### Sessions — `/sessions` _(auth required, subscription required)_

Sessions log completed practice runs. Recordings stay on device — only metadata is stored.

| Method | Path        | Description                              |
|--------|-------------|------------------------------------------|
| POST   | `/sessions` | Log a completed session                  |
| GET    | `/sessions` | List sessions (paginated, filterable by `area_id`) |

## Deployment

The `entrypoint.sh` script handles startup:

```bash
RUN_MIGRATIONS=true RUN_SEED=true ./entrypoint.sh
```

- `RUN_MIGRATIONS=true` — runs `alembic upgrade head` before starting
- `RUN_SEED=true` — seeds global areas and topics (idempotent, safe to run repeatedly). Dev user is skipped in production.

Set `PORT` and `WORKERS` env vars to override the defaults (`8080` and `2`).

## Running tests

```bash
pytest
```

## Migrations

```bash
# Apply all migrations
alembic upgrade head

# Generate a new migration from model changes
alembic revision --autogenerate -m "description"

# Roll back one step
alembic downgrade -1
```