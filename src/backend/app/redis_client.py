import json
import redis
from .config import settings

DEV_JOB_STORE: dict[str, str] = {}
DEV_AD_PASS_STORE: dict[str, str] = {}


def get_redis_client() -> redis.Redis:
    return redis.Redis.from_url(settings.REDIS_URL, socket_timeout=2.0)


def check_redis_connection() -> bool:
    try:
        client = get_redis_client()
        return bool(client.ping())
    except Exception:
        return False


def store_job_metadata(job_id: str, payload: dict) -> None:
    """
    Stores job payload in Redis, with fallback to in-memory store when Redis is unavailable.
    """
    json_str = json.dumps(payload)
    DEV_JOB_STORE[job_id] = json_str
    try:
        client = get_redis_client()
        client.incr(f"ip_limit:{payload.get('client_ip', '127.0.0.1')}")
        client.set(f"job:{job_id}", json_str, ex=86400)
    except Exception:
        pass


def get_job_metadata(job_id: str) -> str | None:
    """
    Retrieves job payload string from Redis, falling back to in-memory store.
    """
    try:
        client = get_redis_client()
        data = client.get(f"job:{job_id}")
        if data:
            return data.decode("utf-8") if isinstance(data, bytes) else str(data)
    except Exception:
        pass
    return DEV_JOB_STORE.get(job_id)


def store_ad_pass_metadata(key: str, payload: dict, ttl_seconds: int = 3600) -> None:
    """
    Stores ad pass payload in Redis, with fallback to in-memory store when Redis is unavailable.
    """
    json_str = json.dumps(payload)
    DEV_AD_PASS_STORE[key] = json_str
    try:
        client = get_redis_client()
        client.set(key, json_str, ex=ttl_seconds)
    except Exception:
        pass


def get_ad_pass_metadata(key: str) -> dict | None:
    """
    Retrieves ad pass payload dict from Redis, falling back to in-memory store.
    """
    try:
        client = get_redis_client()
        data = client.get(key)
        if data:
            raw_str = data.decode("utf-8") if isinstance(data, bytes) else str(data)
            return json.loads(raw_str)
    except Exception:
        pass

    fallback = DEV_AD_PASS_STORE.get(key)
    if fallback:
        try:
            return json.loads(fallback)
        except Exception:
            pass
    return None
