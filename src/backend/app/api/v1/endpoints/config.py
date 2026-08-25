from fastapi import APIRouter
from app.config import load_canonical_config

router = APIRouter()


@router.get("")
@router.get("/limits")
def get_runtime_config():
    """Returns the single canonical global runtime configuration (limits, quotas, engines, stackable ad parameters)."""
    return load_canonical_config()
