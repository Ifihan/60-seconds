from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.exceptions import ForbiddenError, NotFoundError
from app.models.area import Area
from app.models.session import Session
from app.models.user import User
from app.models.user_area import UserArea
from app.schemas.session import PaginatedSessions, PaginationMeta, SessionCreate, SessionOut

router = APIRouter()


@router.post("", response_model=SessionOut, status_code=status.HTTP_201_CREATED)
async def create_session(
    body: SessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    area_result = await db.execute(select(Area).where(Area.id == body.area_id))
    area = area_result.scalar_one_or_none()
    if not area:
        raise NotFoundError("Area not found")

    if area.user_id != current_user.id:
        if area.user_id is None:
            sub_result = await db.execute(
                select(UserArea).where(UserArea.user_id == current_user.id, UserArea.area_id == body.area_id)
            )
            if not sub_result.scalar_one_or_none():
                raise ForbiddenError("Not subscribed to this area")
        else:
            raise ForbiddenError("Area does not belong to current user")

    session = Session(
        user_id=current_user.id,
        area_id=area.id,
        area_name=area.name,
        topic=body.topic,
        mode=body.mode,
        completed_at=body.completed_at,
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


@router.get("", response_model=PaginatedSessions)
async def list_sessions(
    area_id: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    base_where = [Session.user_id == current_user.id]
    if area_id:
        base_where.append(Session.area_id == area_id)

    total_result = await db.execute(
        select(func.count()).select_from(Session).where(*base_where)
    )
    total = total_result.scalar_one()

    offset = (page - 1) * limit
    result = await db.execute(
        select(Session).where(*base_where).offset(offset).limit(limit)
    )
    sessions = result.scalars().all()

    return PaginatedSessions(
        data=[SessionOut.model_validate(s) for s in sessions],
        pagination=PaginationMeta(page=page, limit=limit, total=total),
    )
