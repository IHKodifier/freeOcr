import sys
from pathlib import Path
from unittest.mock import patch

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.redis_client import check_redis_connection, get_redis_client


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
