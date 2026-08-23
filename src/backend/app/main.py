from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware

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
