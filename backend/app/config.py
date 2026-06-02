from typing import Literal

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str
    jwt_secret: str = Field(min_length=32)
    jwt_expires_minutes: int = Field(default=10080, ge=1, le=10080)
    jwt_issuer: str = "60-seconds-api"
    jwt_audience: str = "60-seconds-client"
    environment: Literal["development", "test", "production"] = "development"
    allowed_hosts: str = "localhost,127.0.0.1"
    cors_allowed_origins: str = ""
    rate_limit_storage_uri: str | None = None
    vapid_private_key: str | None = None
    vapid_public_key: str | None = None
    vapid_claims_email: str = "admin@60seconds.dev"
    notify_secret: str | None = None

    model_config = SettingsConfigDict(env_file=".env")

    @property
    def allowed_hosts_list(self) -> list[str]:
        return _split_csv(self.allowed_hosts)

    @property
    def cors_allowed_origins_list(self) -> list[str]:
        return _split_csv(self.cors_allowed_origins)

    @field_validator("jwt_secret")
    @classmethod
    def validate_jwt_secret(cls, value: str) -> str:
        weak_values = {
            "your-secret-key-minimum-32-characters",
            "change-me-change-me-change-me-change-me",
        }
        if value in weak_values:
            raise ValueError("JWT_SECRET must not use an example or placeholder value")
        if len(set(value)) < 8:
            raise ValueError("JWT_SECRET must contain enough character variety")
        return value

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        if self.environment != "production":
            return self
        if "*" in self.allowed_hosts_list:
            raise ValueError("Wildcard ALLOWED_HOSTS is not allowed in production")
        return self


def _split_csv(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


settings = Settings()
