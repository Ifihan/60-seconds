import uuid
from datetime import UTC, datetime, timedelta

from jose import JWTError, jwt

from app.config import settings
from app.exceptions import UnauthorizedError

ALGORITHM = "HS256"


def create_access_token(subject: str) -> str:
    now = datetime.now(UTC)
    expire = now + timedelta(minutes=settings.jwt_expires_minutes)
    payload = {
        "sub": subject,
        "exp": expire,
        "iat": now,
        "nbf": now,
        "jti": str(uuid.uuid4()),
        "typ": "access",
        "iss": settings.jwt_issuer,
        "aud": settings.jwt_audience,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[ALGORITHM],
            issuer=settings.jwt_issuer,
            audience=settings.jwt_audience,
        )
        if payload.get("typ") != "access" or not payload.get("sub"):
            raise UnauthorizedError("Invalid or expired token")
        return payload
    except JWTError:
        raise UnauthorizedError("Invalid or expired token")
