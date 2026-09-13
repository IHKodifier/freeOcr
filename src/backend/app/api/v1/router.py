from fastapi import APIRouter
from app.api.v1.endpoints import ocr, jobs, config, contact, tools_info, tools_merge

api_router = APIRouter()
api_router.include_router(ocr.router, prefix="/ocr", tags=["ocr"])
api_router.include_router(jobs.router, prefix="/jobs", tags=["jobs"])
api_router.include_router(config.router, prefix="/config", tags=["config"])
api_router.include_router(contact.router, prefix="/contact", tags=["contact"])
api_router.include_router(tools_info.router, prefix="/tools", tags=["tools"])
api_router.include_router(tools_merge.router, prefix="/tools", tags=["PDF Tools - Merge"])

