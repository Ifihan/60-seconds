import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class RecordMode(str, enum.Enum):
    AUDIO = "AUDIO"
    VIDEO = "VIDEO"


class Session(Base):
    __tablename__ = "sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    area_id: Mapped[str] = mapped_column(String(36), nullable=False)
    area_name: Mapped[str] = mapped_column(String(100), nullable=False)
    topic: Mapped[str] = mapped_column(String(200), nullable=False)
    mode: Mapped[RecordMode] = mapped_column(Enum(RecordMode))
    completed_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    transcript: Mapped[str | None] = mapped_column(Text, nullable=True)
    filler_word_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    words_per_minute: Mapped[int | None] = mapped_column(Integer, nullable=True)
    coherence_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    grammar_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    content_accuracy_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    feedback_summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    analyzed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    user: Mapped["User"] = relationship("User", back_populates="sessions")
    area: Mapped["Area"] = relationship(
        "Area",
        back_populates="sessions",
        primaryjoin="Session.area_id == Area.id",
        foreign_keys="Session.area_id",
    )
