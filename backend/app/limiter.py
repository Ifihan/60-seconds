from slowapi import Limiter
from slowapi.util import get_remote_address

from app.config import settings

limiter = Limiter(
    key_func=get_remote_address,
    headers_enabled=False,
    storage_uri=settings.rate_limit_storage_uri,
    in_memory_fallback_enabled=settings.environment != "production",
)
