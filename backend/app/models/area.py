import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Area(Base):
    __tablename__ = "areas"
    __table_args__ = (UniqueConstraint("name", "user_id"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    user_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User | None"] = relationship(
        "User", back_populates="created_areas", foreign_keys=[user_id]
    )
    topics: Mapped[list["Topic"]] = relationship("Topic", back_populates="area", cascade="all, delete-orphan")
    subscribers: Mapped[list["UserArea"]] = relationship("UserArea", back_populates="area", cascade="all, delete-orphan")
    sessions: Mapped[list["Session"]] = relationship(
        "Session",
        back_populates="area",
        primaryjoin="Area.id == foreign(Session.area_id)",
    )
