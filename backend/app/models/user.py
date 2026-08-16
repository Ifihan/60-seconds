import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True, nullable=False)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    preferred_area_id: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("areas.id", ondelete="SET NULL", use_alter=True, name="fk_users_preferred_area_id_areas"),
        nullable=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    subscribed_areas: Mapped[list["UserArea"]] = relationship("UserArea", back_populates="user", cascade="all, delete-orphan")
    created_areas: Mapped[list["Area"]] = relationship("Area", back_populates="user", cascade="all, delete-orphan", foreign_keys="Area.user_id")
    preferred_area: Mapped["Area | None"] = relationship("Area", foreign_keys=[preferred_area_id])
    sessions: Mapped[list["Session"]] = relationship("Session", back_populates="user", cascade="all, delete-orphan")
    push_subscriptions: Mapped[list["PushSubscription"]] = relationship("PushSubscription", back_populates="user", cascade="all, delete-orphan")
    daily_topics: Mapped[list["DailyTopic"]] = relationship("DailyTopic", back_populates="user", cascade="all, delete-orphan")
