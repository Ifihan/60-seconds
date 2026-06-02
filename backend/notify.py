"""Daily push notification script. Run via cron or Cloud Scheduler."""
import asyncio
import json

from pywebpush import WebPushException, webpush
from sqlalchemy import select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.config import settings
from app.models.push_subscription import PushSubscription

NOTIFICATION = {
    "title": "60 Seconds",
    "body": "Time to practice. Pick a topic and speak.",
}


async def send_notifications():
    if not settings.vapid_private_key or not settings.vapid_public_key:
        print("VAPID keys not configured — skipping.")
        return

    engine = create_async_engine(settings.database_url, connect_args={"statement_cache_size": 0})
    SessionLocal = async_sessionmaker(engine, expire_on_commit=False)

    async with SessionLocal() as db:
        result = await db.execute(select(PushSubscription))
        subscriptions = result.scalars().all()
        print(f"Sending to {len(subscriptions)} subscribers...")

        stale = []
        for sub in subscriptions:
            try:
                webpush(
                    subscription_info={
                        "endpoint": sub.endpoint,
                        "keys": {"p256dh": sub.p256dh, "auth": sub.auth},
                    },
                    data=json.dumps(NOTIFICATION),
                    vapid_private_key=settings.vapid_private_key,
                    vapid_claims={"sub": f"mailto:{settings.vapid_claims_email}"},
                )
            except WebPushException as e:
                print(f"Failed [{sub.endpoint[:60]}]: {e}")
                if e.response and e.response.status_code in (404, 410):
                    stale.append(sub)

        for sub in stale:
            await db.delete(sub)
        if stale:
            await db.commit()
            print(f"Removed {len(stale)} stale subscriptions.")

    await engine.dispose()
    print("Done.")


if __name__ == "__main__":
    asyncio.run(send_notifications())
