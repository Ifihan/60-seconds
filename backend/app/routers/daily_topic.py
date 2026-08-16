import random
from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.area import Area
from app.models.daily_topic import DailyTopic
from app.models.topic import Topic
from app.models.user import User
from app.schemas.daily_topic import DailyTopicOut

router = APIRouter()


@router.get("", response_model=DailyTopicOut | None)
async def get_daily_topic(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not current_user.preferred_area_id:
        return None

    today = datetime.utcnow().date()

    existing_result = await db.execute(
        select(DailyTopic).where(DailyTopic.user_id == current_user.id, DailyTopic.date == today)
    )
    existing = existing_result.scalar_one_or_none()
    if existing:
        return existing

    area_result = await db.execute(select(Area).where(Area.id == current_user.preferred_area_id))
    area = area_result.scalar_one_or_none()
    if not area:
        return None

    topics_result = await db.execute(select(Topic).where(Topic.area_id == area.id))
    topics = topics_result.scalars().all()
    if not topics:
        return None

    picked = random.choice(topics)
    daily_topic = DailyTopic(
        user_id=current_user.id,
        date=today,
        area_id=area.id,
        area_name=area.name,
        topic_name=picked.name,
    )
    db.add(daily_topic)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        existing_result = await db.execute(
            select(DailyTopic).where(DailyTopic.user_id == current_user.id, DailyTopic.date == today)
        )
        return existing_result.scalar_one_or_none()

    await db.refresh(daily_topic)
    return daily_topic
