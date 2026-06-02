import uuid
from datetime import datetime

from sqlalchemy import DateTime, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True, nullable=False)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    subscribed_areas: Mapped[list["UserArea"]] = relationship("UserArea", back_populates="user", cascade="all, delete-orphan")
    created_areas: Mapped[list["Area"]] = relationship("Area", back_populates="user", cascade="all, delete-orphan", foreign_keys="Area.user_id")
    sessions: Mapped[list["Session"]] = relationship("Session", back_populates="user", cascade="all, delete-orphan")
    push_subscriptions: Mapped[list["PushSubscription"]] = relationship("PushSubscription", back_populates="user", cascade="all, delete-orphan")
