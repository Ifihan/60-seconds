from datetime import date

from pydantic import BaseModel, ConfigDict


class DailyTopicOut(BaseModel):
    area_id: str
    area_name: str
    topic_name: str
    date: date
    model_config = ConfigDict(from_attributes=True)
