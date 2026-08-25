import json
import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


CONFIG_JSON_PATH = Path(__file__).parent / "app_limits_config.json"


def load_canonical_config() -> dict:
    """Loads the single canonical configuration file."""
    if CONFIG_JSON_PATH.exists():
        with open(CONFIG_JSON_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "limits": {
            "base_max_file_mb": 10,
            "base_max_pages": 10,
            "simple_quota_5h": 20,
            "complex_quota_5h": 5,
            "boost_per_ad_mb": 20,
            "boost_per_ad_pages": 15,
            "ad_boost_ttl_seconds": 3600,
            "max_stack_file_mb": 500,
            "max_stack_pages": 500,
        },
        "monetization": {
            "ad_rotation_interval_seconds": 35,
            "rewarded_ad_duration_seconds": 15,
            "display_ads_enabled": True,
            "rewarded_ads_enabled": True,
        },
        "engines": {
            "simple_engine": "OCRmyPDF",
            "complex_engine": "Baidu_Unlimited_OCR",
        },
        "queues": {
            "cpu_queue": "ocr:queue:cpu",
            "gpu_queue": "ocr:queue:gpu",
        },
    }


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./dev.db"
    REDIS_URL: str = "redis://localhost:6379/0"
    ENVIRONMENT: str = "development"
    FREE_TIER_MAX_FILE_MB: int = 10
    ALLOWED_EXTENSIONS: set = {".pdf", ".jpg", ".jpeg", ".png"}

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    def get_canonical_config(self) -> dict:
        return load_canonical_config()


settings = Settings()
