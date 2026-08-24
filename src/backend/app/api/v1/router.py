from fastapi import APIRouter
from app.api.v1.endpoints import ocr, jobs

api_router = APIRouter()
api_router.include_router(ocr.router, prefix="/ocr", tags=["ocr"])
api_router.include_router(jobs.router, prefix="/jobs", tags=["jobs"])

