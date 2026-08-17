from datetime import UTC, datetime, timedelta

from pydantic import BaseModel, ConfigDict, field_validator

from app.models.session import RecordMode
from app.schemas.common import AreaId, TopicName


class SessionCreate(BaseModel):
    area_id: AreaId
    topic: TopicName
    mode: RecordMode
    completed_at: datetime

    @field_validator("completed_at")
    @classmethod
    def validate_completed_at(cls, value: datetime) -> datetime:
        completed_at = value if value.tzinfo else value.replace(tzinfo=UTC)
        now = datetime.now(UTC)
        if completed_at > now + timedelta(minutes=5):
            raise ValueError("completed_at cannot be in the future")
        if completed_at < now - timedelta(days=3650):
            raise ValueError("completed_at is too far in the past")
        return completed_at.replace(tzinfo=None)


class SessionOut(BaseModel):
    id: str
    topic: str
    area_id: str
    area_name: str
    mode: RecordMode
    completed_at: datetime
    transcript: str | None = None
    filler_word_count: int | None = None
    words_per_minute: int | None = None
    coherence_score: int | None = None
    grammar_score: int | None = None
    content_accuracy_score: int | None = None
    feedback_summary: str | None = None
    analyzed_at: datetime | None = None
    model_config = ConfigDict(from_attributes=True)


class PaginationMeta(BaseModel):
    page: int
    limit: int
    total: int


class PaginatedSessions(BaseModel):
    data: list[SessionOut]
    pagination: PaginationMeta
