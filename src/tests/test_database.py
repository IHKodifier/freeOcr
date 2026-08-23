import sys
from pathlib import Path

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.database import Base, check_database_connection, engine


def test_database_connection():
    """Verify that database connection check returns True for SQLite dev.db."""
    assert check_database_connection() is True


def test_database_metadata_create_all():
    """Verify metadata create_all executes cleanly on SQLite engine."""
    Base.metadata.create_all(bind=engine)
    assert check_database_connection() is True
