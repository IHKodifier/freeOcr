from fastapi import FastAPI, Response, status
from fastapi.middleware.cors import CORSMiddleware
from .database import check_database_connection
from .redis_client import check_redis_connection

app = FastAPI(
    title="freeOCR.me Backend API",
    description="Privacy-focused Scanned PDF to Searchable PDF/Text OCR Service",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/v1/health", status_code=status.HTTP_200_OK)
async def health_check():
    """
    Health check endpoint returning service health status and API version.
    """
    return {
        "status": "ok",
        "service": "freeOCR.me API",
        "version": "0.1.0",
    }


@app.get("/healthz")
async def healthz(response: Response):
    """
    Detailed healthz check endpoint for container orchestrators and monitoring tools.
    Verifies SQLite database and Redis server connectivity.
    """
    db_healthy = check_database_connection()
    redis_healthy = check_redis_connection()

    db_status = "connected" if db_healthy else "unreachable"
    redis_status = "connected" if redis_healthy else "unreachable"

    overall_healthy = db_healthy and redis_healthy
    status_str = "healthy" if overall_healthy else "unhealthy"

    if not overall_healthy:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    else:
        response.status_code = status.HTTP_200_OK

    return {
        "status": status_str,
        "database": db_status,
        "redis": redis_status,
    }

