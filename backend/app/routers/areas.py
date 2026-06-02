from fastapi import APIRouter, Depends, status
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies.auth import get_current_user, get_optional_user
from app.exceptions import ConflictError, NotFoundError
from app.models.area import Area
from app.models.topic import Topic
from app.models.user import User
from app.models.user_area import UserArea
from app.schemas.area import AreaCreate, AreaOut, AreaUpdate

router = APIRouter()


async def _get_area_out(area: Area, db: AsyncSession, is_subscribed: bool, is_own: bool) -> AreaOut:
    count_result = await db.execute(
        select(func.count()).where(Topic.area_id == area.id)
    )
    topic_count = count_result.scalar_one()
    return AreaOut(
        id=area.id,
        name=area.name,
        topic_count=topic_count,
        is_subscribed=is_subscribed,
        is_own=is_own,
        created_at=area.created_at,
    )


@router.get("", response_model=list[AreaOut])
async def list_areas(
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    global_result = await db.execute(select(Area).where(Area.user_id == None))  # noqa: E711
    global_areas = global_result.scalars().all()

    subscribed_ids: set[str] = set()
    own_areas: list[Area] = []

    if current_user:
        subscribed_ids_result = await db.execute(
            select(UserArea.area_id).where(UserArea.user_id == current_user.id)
        )
        subscribed_ids = set(subscribed_ids_result.scalars().all())

        own_result = await db.execute(select(Area).where(Area.user_id == current_user.id))
        own_areas = list(own_result.scalars().all())

    output = []
    for a in global_areas:
        output.append(await _get_area_out(a, db, is_subscribed=a.id in subscribed_ids, is_own=False))
    for a in own_areas:
        output.append(await _get_area_out(a, db, is_subscribed=True, is_own=True))
    return output


@router.post("", response_model=AreaOut, status_code=status.HTTP_201_CREATED)
async def create_area(
    body: AreaCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    existing = await db.execute(
        select(Area).where(Area.user_id == current_user.id, Area.name == body.name)
    )
    if existing.scalar_one_or_none():
        raise ConflictError("Area name already exists")

    area = Area(name=body.name, user_id=current_user.id)
    db.add(area)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise ConflictError("Area name already exists")
    await db.refresh(area)
    return await _get_area_out(area, db, is_subscribed=True, is_own=True)


@router.patch("/{area_id}", response_model=AreaOut)
async def update_area(
    area_id: str,
    body: AreaUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Area).where(Area.id == area_id, Area.user_id == current_user.id)
    )
    area = result.scalar_one_or_none()
    if not area:
        raise NotFoundError("Area not found")

    if body.name is not None:
        area.name = body.name

    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise ConflictError("Area name already exists")
    await db.refresh(area)
    return await _get_area_out(area, db, is_subscribed=True, is_own=True)


@router.delete("/{area_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_area(
    area_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Area).where(Area.id == area_id, Area.user_id == current_user.id)
    )
    area = result.scalar_one_or_none()
    if not area:
        raise NotFoundError("Area not found")

    await db.delete(area)
    await db.commit()


@router.post("/{area_id}/subscribe", response_model=AreaOut, status_code=status.HTTP_201_CREATED)
async def subscribe_to_area(
    area_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    area_result = await db.execute(select(Area).where(Area.id == area_id))
    area = area_result.scalar_one_or_none()
    if not area:
        raise NotFoundError("Area not found")
    if area.user_id is not None:
        raise ConflictError("Cannot subscribe to a personal area")

    existing = await db.execute(
        select(UserArea).where(UserArea.user_id == current_user.id, UserArea.area_id == area_id)
    )
    if existing.scalar_one_or_none():
        raise ConflictError("Already subscribed to this area")

    user_area = UserArea(user_id=current_user.id, area_id=area_id)
    db.add(user_area)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise ConflictError("Already subscribed to this area")

    return await _get_area_out(area, db, is_subscribed=True, is_own=False)


@router.delete("/{area_id}/subscribe", status_code=status.HTTP_204_NO_CONTENT)
async def unsubscribe_from_area(
    area_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(UserArea).where(UserArea.user_id == current_user.id, UserArea.area_id == area_id)
    )
    user_area = result.scalar_one_or_none()
    if not user_area:
        raise NotFoundError("Subscription not found")

    await db.delete(user_area)
    await db.commit()
