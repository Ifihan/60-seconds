from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.exceptions import ConflictError, ForbiddenError, NotFoundError
from app.models.area import Area
from app.models.topic import Topic
from app.models.user import User
from app.models.user_area import UserArea
from app.schemas.topic import TopicBulkCreate, TopicCreate, TopicOut

router = APIRouter()


async def _get_area_for_user(area_id: str, user_id: str, db: AsyncSession) -> Area:
    area_result = await db.execute(select(Area).where(Area.id == area_id))
    area = area_result.scalar_one_or_none()
    if not area:
        raise NotFoundError("Area not found")

    if area.user_id == user_id:
        return area

    if area.user_id is None:
        sub_result = await db.execute(
            select(UserArea).where(UserArea.user_id == user_id, UserArea.area_id == area_id)
        )
        if sub_result.scalar_one_or_none():
            return area

    raise ForbiddenError("Not subscribed to this area")


@router.get("/{area_id}/topics", response_model=list[TopicOut])
async def list_topics(
    area_id: str,
    db: AsyncSession = Depends(get_db),
):
    area_result = await db.execute(select(Area).where(Area.id == area_id))
    if not area_result.scalar_one_or_none():
        raise NotFoundError("Area not found")
    result = await db.execute(select(Topic).where(Topic.area_id == area_id))
    return result.scalars().all()


@router.post("/{area_id}/topics", response_model=list[TopicOut], status_code=status.HTTP_201_CREATED)
async def create_topics(
    area_id: str,
    body: TopicCreate | TopicBulkCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _get_area_for_user(area_id, current_user.id, db)

    names = body.names if isinstance(body, TopicBulkCreate) else [body.name]
    if len(set(names)) != len(names):
        raise ConflictError("Duplicate topic name in area")

    existing = await db.execute(
        select(Topic).where(Topic.area_id == area_id, Topic.name.in_(names))
    )
    if existing.scalars().first():
        raise ConflictError("Duplicate topic name in area")

    topics = [Topic(name=name, area_id=area_id) for name in names]
    db.add_all(topics)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise ConflictError("Duplicate topic name in area")
    for t in topics:
        await db.refresh(t)
    return topics


@router.delete("/{area_id}/topics/{topic_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_topic(
    area_id: str,
    topic_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _get_area_for_user(area_id, current_user.id, db)

    result = await db.execute(
        select(Topic).where(Topic.id == topic_id, Topic.area_id == area_id)
    )
    topic = result.scalar_one_or_none()
    if not topic:
        raise NotFoundError("Topic not found")

    await db.delete(topic)
    await db.commit()
