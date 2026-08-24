import os
import time
import tempfile


def purge_ephemeral_ram_disk(max_age_seconds: int = 60, ram_disk_path: str | None = None) -> int:
    """
    Scans RAM disk / ephemeral temp storage directory for orphan temporary files
    matching prefix 'ephemeral_' with mtime older than max_age_seconds (default 60s),
    and executes os.remove() to enforce RAM disk hygiene.

    Args:
        max_age_seconds (int): Maximum age threshold in seconds before file purge (default: 60s).
        ram_disk_path (str | None): Directory path to scan. Defaults to RAM_DISK_PATH env var or tempdir.

    Returns:
        int: Total number of orphan ephemeral files successfully purged.
    """
    target_dir = ram_disk_path or os.environ.get("RAM_DISK_PATH") or tempfile.gettempdir()
    if not os.path.exists(target_dir) or not os.path.isdir(target_dir):
        return 0

    now = time.time()
    purged_count = 0

    try:
        filenames = os.listdir(target_dir)
    except Exception:
        return 0

    for filename in filenames:
        if filename.startswith("ephemeral_"):
            filepath = os.path.join(target_dir, filename)
            try:
                if os.path.isfile(filepath):
                    mtime = os.path.getmtime(filepath)
                    if (now - mtime) > max_age_seconds:
                        os.remove(filepath)
                        purged_count += 1
            except Exception:
                pass

    return purged_count
