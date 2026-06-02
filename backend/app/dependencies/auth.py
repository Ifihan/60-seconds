from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.exceptions import UnauthorizedError
from app.models.user import User
from app.utils.jwt import decode_token

bearer = HTTPBearer()
optional_bearer = HTTPBearer(auto_error=False)


async def get_current_token_payload(
    credentials: HTTPAuthorizationCredentials = Depends(bearer),
    db: AsyncSession = Depends(get_db),
) -> dict:
    token = credentials.credentials
    payload = decode_token(token)
    jti = payload.get("jti")
    if not isinstance(jti, str):
        raise UnauthorizedError("Invalid or expired token")
    return payload


async def get_current_user(
    payload: dict = Depends(get_current_token_payload),
    db: AsyncSession = Depends(get_db),
) -> User:
    subject = payload.get("sub")
    if not isinstance(subject, str):
        raise UnauthorizedError("Invalid or expired token")
    user = await db.get(User, subject)
    if not user:
        raise UnauthorizedError("User not found")
    return user


async def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(optional_bearer),
    db: AsyncSession = Depends(get_db),
) -> User | None:
    if not credentials:
        return None
    payload = decode_token(credentials.credentials)
    subject = payload.get("sub")
    if not isinstance(subject, str):
        return None
    return await db.get(User, subject)
