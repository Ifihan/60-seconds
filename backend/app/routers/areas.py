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


async def _get_area_out(
    area: Area, db: AsyncSession, is_subscribed: bool, is_own: bool, is_preferred: bool
) -> AreaOut:
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
        is_preferred=is_preferred,
        created_at=area.created_at,
    )


async def _topic_counts(db: AsyncSession, area_ids: list[str]) -> dict[str, int]:
    if not area_ids:
        return {}
    result = await db.execute(
        select(Topic.area_id, func.count())
        .where(Topic.area_id.in_(area_ids))
        .group_by(Topic.area_id)
    )
    return dict(result.all())


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

    counts = await _topic_counts(db, [a.id for a in [*global_areas, *own_areas]])
    preferred_id = current_user.preferred_area_id if current_user else None

    output = []
    for a in global_areas:
        output.append(AreaOut(
            id=a.id,
            name=a.name,
            topic_count=counts.get(a.id, 0),
            is_subscribed=a.id in subscribed_ids,
            is_own=False,
            is_preferred=a.id == preferred_id,
            created_at=a.created_at,
        ))
    for a in own_areas:
        output.append(AreaOut(
            id=a.id,
            name=a.name,
            topic_count=counts.get(a.id, 0),
            is_subscribed=True,
            is_own=True,
            is_preferred=a.id == preferred_id,
            created_at=a.created_at,
        ))
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
    return await _get_area_out(
        area, db, is_subscribed=True, is_own=True, is_preferred=area.id == current_user.preferred_area_id
    )


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
    return await _get_area_out(
        area, db, is_subscribed=True, is_own=True, is_preferred=area.id == current_user.preferred_area_id
    )


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

    return await _get_area_out(
        area, db, is_subscribed=True, is_own=False, is_preferred=area.id == current_user.preferred_area_id
    )


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


@router.post("/{area_id}/preferred", response_model=AreaOut)
async def set_preferred_area(
    area_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    area_result = await db.execute(select(Area).where(Area.id == area_id))
    area = area_result.scalar_one_or_none()
    if not area or (area.user_id is not None and area.user_id != current_user.id):
        raise NotFoundError("Area not found")

    current_user.preferred_area_id = area_id
    await db.commit()
    await db.refresh(area)

    is_own = area.user_id == current_user.id
    is_subscribed = True
    if not is_own:
        sub_result = await db.execute(
            select(UserArea).where(UserArea.user_id == current_user.id, UserArea.area_id == area_id)
        )
        is_subscribed = sub_result.scalar_one_or_none() is not None

    return await _get_area_out(area, db, is_subscribed=is_subscribed, is_own=is_own, is_preferred=True)
