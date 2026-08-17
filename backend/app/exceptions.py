from fastapi import Request
from fastapi.responses import JSONResponse


class AppException(Exception):
    def __init__(self, status_code: int, code: str, message: str):
        self.status_code = status_code
        self.code = code
        self.message = message


class NotFoundError(AppException):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(404, "NOT_FOUND", message)


class ConflictError(AppException):
    def __init__(self, message: str = "Resource already exists"):
        super().__init__(409, "CONFLICT", message)


class UnauthorizedError(AppException):
    def __init__(self, message: str = "Unauthorized"):
        super().__init__(401, "UNAUTHORIZED", message)


class ForbiddenError(AppException):
    def __init__(self, message: str = "Forbidden"):
        super().__init__(403, "FORBIDDEN", message)


class ValidationError(AppException):
    def __init__(self, message: str = "Invalid request"):
        super().__init__(422, "VALIDATION_ERROR", message)


class UpstreamError(AppException):
    def __init__(self, message: str = "Upstream service unavailable"):
        super().__init__(502, "UPSTREAM_ERROR", message)


async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": {"code": exc.code, "message": exc.message}},
    )