import json

from fastapi import APIRouter, Depends, Header, HTTPException
from pywebpush import WebPushException, webpush
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.push_subscription import PushSubscription
from app.models.user import User
from app.schemas.push import PushSubscribeRequest

router = APIRouter()


@router.post("/subscribe", status_code=204)
async def subscribe(
    body: PushSubscribeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(delete(PushSubscription).where(PushSubscription.endpoint == body.endpoint))
    db.add(PushSubscription(user_id=current_user.id, endpoint=body.endpoint, p256dh=body.p256dh, auth=body.auth))
    await db.commit()


@router.delete("/subscribe", status_code=204)
async def unsubscribe(
    body: PushSubscribeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(
        delete(PushSubscription).where(
            PushSubscription.endpoint == body.endpoint,
            PushSubscription.user_id == current_user.id,
        )
    )
    await db.commit()


@router.post("/notify", status_code=204, include_in_schema=False)
async def trigger_notifications(
    x_notify_secret: str | None = Header(default=None),
    db: AsyncSession = Depends(get_db),
):
    if not settings.notify_secret or x_notify_secret != settings.notify_secret:
        raise HTTPException(status_code=401)
    if not settings.vapid_private_key or not settings.vapid_public_key:
        return

    result = await db.execute(select(PushSubscription))
    subscriptions = result.scalars().all()

    stale = []
    for sub in subscriptions:
        try:
            webpush(
                subscription_info={"endpoint": sub.endpoint, "keys": {"p256dh": sub.p256dh, "auth": sub.auth}},
                data=json.dumps({"title": "60 Seconds", "body": "Time to practice. Pick a topic and speak."}),
                vapid_private_key=settings.vapid_private_key,
                vapid_claims={"sub": f"mailto:{settings.vapid_claims_email}"},
            )
        except WebPushException as e:
            if e.response and e.response.status_code in (404, 410):
                stale.append(sub)

    for sub in stale:
        await db.delete(sub)
    if stale:
        await db.commit()
