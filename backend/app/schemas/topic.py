from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.common import TopicName


class TopicCreate(BaseModel):
    name: TopicName


class TopicBulkCreate(BaseModel):
    names: list[TopicName] = Field(min_length=1, max_length=50)


class TopicOut(BaseModel):
    id: str
    name: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
