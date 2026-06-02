#!/bin/bash
set -e

if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    alembic upgrade head
    echo "Migrations complete."
fi

if [ "$RUN_SEED" = "true" ]; then
    echo "Running seed..."
    python seed.py || echo "Seed failed (non-fatal) — server will still start."
fi

exec uvicorn app.main:app \
    --host 0.0.0.0 \
    --port "${PORT:-8080}" \
    --workers "${WORKERS:-2}" \
    --proxy-headers \
    --forwarded-allow-ips="${FORWARDED_ALLOW_IPS:-127.0.0.1}" \
    --log-level info