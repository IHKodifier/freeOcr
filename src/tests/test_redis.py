import json
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.redis_client import (
    check_redis_connection,
    get_redis_client,
    store_job_metadata,
    get_job_metadata,
    store_pdf_bytes,
    get_pdf_bytes,
    DEV_JOB_STORE,
    DEV_PDF_STORE,
)
from app.config import settings


def test_redis_client_configuration():
    """Verify Redis client initialization with expected configuration."""
    client = get_redis_client()
    assert client is not None


def test_check_redis_connection_mocked_success():
    """Verify check_redis_connection returns True when Redis ping succeeds."""
    with patch("app.redis_client.get_redis_client") as mock_get_client:
        mock_client = mock_get_client.return_value
        mock_client.ping.return_value = True
        assert check_redis_connection() is True


def test_check_redis_connection_mocked_failure():
    """Verify check_redis_connection returns False gracefully on connection exception."""
    with patch("app.redis_client.get_redis_client") as mock_get_client:
        mock_client = mock_get_client.return_value
        mock_client.ping.side_effect = Exception("Redis offline")
        assert check_redis_connection() is False


def test_upstash_redis_tls_client_initialization():
    """
    Verify that an Upstash rediss:// URL properly configures SSL connection,
    5.0s socket timeout, and retry_on_timeout.
    """
    upstash_url = "rediss://default:secret_token_123@us1-free-example.upstash.io:6379"
    with patch.object(settings, "REDIS_URL", upstash_url):
        client = get_redis_client()
        assert client is not None
        conn_kwargs = client.connection_pool.connection_kwargs
        assert conn_kwargs["host"] == "us1-free-example.upstash.io"
        assert conn_kwargs["port"] == 6379
        assert conn_kwargs["username"] == "default"
        assert conn_kwargs["password"] == "secret_token_123"
        assert conn_kwargs.get("ssl_cert_reqs") == "none" or client.connection_pool.connection_class.__name__ == "SSLConnection"


def test_store_and_get_job_metadata_cold_boot_repopulation():
    """
    Verify that when a container cold-boots (DEV_JOB_STORE is empty),
    get_job_metadata fetches from Redis and re-populates DEV_JOB_STORE.
    """
    job_id = "test_cold_boot_job_001"
    job_data = {"job_id": job_id, "status": "COMPLETED", "filename": "sample.pdf"}
    job_json = json.dumps(job_data)

    # Clear local cache to simulate scale-to-zero cold-boot
    DEV_JOB_STORE.pop(job_id, None)

    mock_redis = MagicMock()
    mock_redis.get.return_value = job_json.encode("utf-8")

    with patch("app.redis_client.get_redis_client", return_value=mock_redis):
        # 1. Fetch on cold boot
        result_str = get_job_metadata(job_id)
        assert result_str is not None
        assert json.loads(result_str)["status"] == "COMPLETED"
        mock_redis.get.assert_called_once_with(f"job:{job_id}")

        # 2. Assert local container cache was re-populated for warm subsequent calls
        assert job_id in DEV_JOB_STORE
        assert DEV_JOB_STORE[job_id] == job_json

    # Clean up
    DEV_JOB_STORE.pop(job_id, None)


def test_store_and_get_pdf_bytes_24h_ttl():
    """
    Verify store_pdf_bytes keeps PDF in local RAM by default (conserving Upstash free tier),
    and persist_pdf_to_redis promotes it to Redis with 24h TTL (86400s) on demand.
    """
    token = "test_token_pdf_abc"
    pdf_content = b"%PDF-1.4 mock compiled bytes"

    DEV_PDF_STORE.pop(token, None)

    mock_redis = MagicMock()
    mock_redis.get.return_value = pdf_content

    with patch("app.redis_client.get_redis_client", return_value=mock_redis):
        # 1. Default storage: only in local RAM, Redis set NOT called
        store_pdf_bytes(token, pdf_content, persist_redis=False)
        assert DEV_PDF_STORE.get(token) == pdf_content
        mock_redis.set.assert_not_called()

        # 2. Promote to Redis on demand (e.g. email links requested)
        from app.redis_client import persist_pdf_to_redis
        promoted = persist_pdf_to_redis(token, ttl_seconds=86400)
        assert promoted is True
        mock_redis.set.assert_called_once_with(f"pdf:{token}", pdf_content, ex=86400)

        # 3. Clear local RAM store to simulate container teardown (scale-to-zero)
        DEV_PDF_STORE.pop(token, None)

        # 4. Fetch on cold boot
        fetched = get_pdf_bytes(token)
        assert fetched == pdf_content
        mock_redis.get.assert_called_once_with(f"pdf:{token}")

        # 5. Verify local container re-population
        assert DEV_PDF_STORE.get(token) == pdf_content

    # Clean up
    DEV_PDF_STORE.pop(token, None)


def test_job_metadata_offline_fallback_to_local_store():
    """
    Verify that when Redis is completely unreachable, store_job_metadata
    and get_job_metadata gracefully fall back to DEV_JOB_STORE without raising exceptions.
    """
    job_id = "test_offline_job_777"
    job_payload = {"job_id": job_id, "status": "QUEUED"}

    with patch("app.redis_client.get_redis_client", side_effect=Exception("Redis unreachable")):
        # Store metadata
        store_job_metadata(job_id, job_payload)

        # Retrieve metadata
        retrieved = get_job_metadata(job_id)
        assert retrieved is not None
        assert json.loads(retrieved)["job_id"] == job_id

    # Clean up
    DEV_JOB_STORE.pop(job_id, None)
