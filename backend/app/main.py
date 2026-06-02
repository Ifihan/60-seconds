from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.config import settings
from app.exceptions import AppException, app_exception_handler
from app.limiter import limiter
from app.routers import auth, areas, topics, sessions


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


docs_url = None if settings.environment == "production" else "/docs"
redoc_url = None if settings.environment == "production" else "/redoc"
openapi_url = None if settings.environment == "production" else "/openapi.json"

app = FastAPI(
    title="60 Seconds API",
    lifespan=lifespan,
    docs_url=docs_url,
    redoc_url=redoc_url,
    openapi_url=openapi_url,
)

app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.allowed_hosts_list)
if settings.environment == "production":
    app.add_middleware(HTTPSRedirectMiddleware)
if settings.cors_allowed_origins_list:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_allowed_origins_list,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PATCH", "DELETE"],
        allow_headers=["Authorization", "Content-Type"],
    )

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_exception_handler(AppException, app_exception_handler)

@app.get("/", include_in_schema=False)
async def root():
    return RedirectResponse(url="/docs")


app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(areas.router, prefix="/areas", tags=["areas"])
app.include_router(topics.router, prefix="/areas", tags=["topics"])
app.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
