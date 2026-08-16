from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.schemas.common import AreaName


class AreaCreate(BaseModel):
    name: AreaName


class AreaUpdate(BaseModel):
    name: AreaName | None = None


class AreaOut(BaseModel):
    id: str
    name: str
    topic_count: int
    is_subscribed: bool
    is_own: bool
    is_preferred: bool
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
