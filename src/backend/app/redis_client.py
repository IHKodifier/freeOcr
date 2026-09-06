import json
import redis
from .config import settings

import os
import tempfile
import glob

class EphemeralRamStore(dict):
    """
    In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH)
    so multiple workers or processes share job and PDF state without mandatory external Redis.
    """
    def __init__(self, prefix: str, is_bytes: bool = False):
        super().__init__()
        self.prefix = prefix
        self.is_bytes = is_bytes
        self.base_dir = os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()

    def _file_path(self, key: str) -> str:
        safe_key = "".join(c if (c.isalnum() or c in ("-", "_")) else "_" for c in str(key))
        return os.path.join(self.base_dir, f"ephem_{self.prefix}_{safe_key}.dat")


    def __getitem__(self, key: str):
        if super().__contains__(key):
            return super().__getitem__(key)
        path = self._file_path(key)
        if os.path.exists(path):
            mode = "rb" if self.is_bytes else "r"
            encoding = None if self.is_bytes else "utf-8"
            try:
                with open(path, mode, encoding=encoding) as f:
                    val = f.read()
                super().__setitem__(key, val)
                return val
            except Exception:
                pass
        raise KeyError(key)

    def __setitem__(self, key: str, value):
        super().__setitem__(key, value)
        path = self._file_path(key)
        mode = "wb" if self.is_bytes else "w"
        encoding = None if self.is_bytes else "utf-8"
        try:
            with open(path, mode, encoding=encoding) as f:
                f.write(value)
        except Exception:
            pass

    def __contains__(self, key: object) -> bool:
        if super().__contains__(key):
            return True
        if isinstance(key, str):
            path = self._file_path(key)
            if os.path.exists(path):
                try:
                    self[key]
                    return True
                except Exception:
                    pass
        return False

    def get(self, key: str, default=None):
        try:
            return self[key]
        except KeyError:
            return default

    def clear(self):
        super().clear()
        try:
            pattern = os.path.join(self.base_dir, f"ephem_{self.prefix}_*.dat")
            for f in glob.glob(pattern):
                try:
                    os.remove(f)
                except Exception:
                    pass
        except Exception:
            pass


DEV_JOB_STORE: EphemeralRamStore = EphemeralRamStore("jobs", is_bytes=False)
DEV_AD_PASS_STORE: EphemeralRamStore = EphemeralRamStore("adpass", is_bytes=False)



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
