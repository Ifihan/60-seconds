import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class UserArea(Base):
    __tablename__ = "user_areas"
    __table_args__ = (UniqueConstraint("user_id", "area_id"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    area_id: Mapped[str] = mapped_column(String(36), ForeignKey("areas.id", ondelete="CASCADE"))
    subscribed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship("User", back_populates="subscribed_areas")
    area: Mapped["Area"] = relationship("Area", back_populates="subscribers")
