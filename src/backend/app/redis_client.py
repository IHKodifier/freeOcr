import redis
from .config import settings


def get_redis_client() -> redis.Redis:
    return redis.Redis.from_url(settings.REDIS_URL, socket_timeout=2.0)


def check_redis_connection() -> bool:
    try:
        client = get_redis_client()
        return bool(client.ping())
    except Exception:
        return False
