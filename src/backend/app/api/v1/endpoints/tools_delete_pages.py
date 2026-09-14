import json
import logging
import os
import shutil
import tempfile
from pathlib import Path
from typing import List, Optional

from fastapi import APIRouter, BackgroundTasks, File, Form, HTTPException, UploadFile, status
from fastapi.responses import FileResponse

from app.services.pdf_delete_pages_service import delete_pdf_pages

router = APIRouter()
logger = logging.getLogger(__name__)

CONFIG_PATH = Path(__file__).parent.parent.parent / "app_limits_config.json"
DEFAULT_MAX_FILE_BYTES = 100 * 1024 * 1024  # 100MB


def get_max_file_bytes() -> int:
    """Reads base limit from app_limits_config.json or falls back to 100MB."""
    try:
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
                mb = data.get("base_max_file_mb", 100)
                return int(mb * 1024 * 1024)
    except Exception as e:
        logger.warning("Could not read app_limits_config.json: %s", e)
    return DEFAULT_MAX_FILE_BYTES


def cleanup_directory(path: str) -> None:
    """Removes temporary working directory and intermediate files."""
    try:
        if os.path.exists(path):
            shutil.rmtree(path, ignore_errors=True)
            logger.info("Purged temporary delete directory: %s", path)
    except Exception as e:
        logger.warning("Failed to purge temp directory %s: %s", path, e)


def parse_page_indices(raw_input: Optional[str]) -> List[int]:
    """Parses JSON array or comma-separated list of 0-indexed page integers."""
    if not raw_input or not raw_input.strip():
        return []
    s = raw_input.strip()
    # Try parsing as JSON first
    try:
        parsed = json.loads(s)
        if isinstance(parsed, list):
            return [int(x) for x in parsed]
        if isinstance(parsed, int):
            return [parsed]
    except Exception:
        pass

    # Try parsing as comma-separated values
    results = []
    for part in s.split(","):
        p = part.strip()
        if p:
            results.append(int(p))
    return results


@router.post("/delete-pages")
async def delete_pages_endpoint(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    pages: Optional[str] = Form(None),
    pages_to_delete: Optional[str] = Form(None),
    pages_json: Optional[str] = Form(None),
):
    """
    Deletes specified 0-indexed pages from an uploaded PDF document.
    Enforces that at least one page remains (returns 400 Bad Request if 100% deletion requested).
    Executes locally in temporary storage using PyMuPDF.

    Parameters:
    - file: Uploaded PDF file
    - pages / pages_to_delete / pages_json: JSON list or comma-separated string of page indices (e.g. '[0, 2]' or '0,2')
    """
    filename = (file.filename or "document.pdf").strip()
    if not filename.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF files are supported.",
        )

    max_bytes = get_max_file_bytes()

    # Create temporary working directory
    temp_dir = Path(tempfile.mkdtemp(prefix="freepdftoolz_delete_"))
    background_tasks.add_task(cleanup_directory, str(temp_dir))

    temp_input_path = temp_dir / "input.pdf"
    temp_output_path = temp_dir / f"{Path(filename).stem}_pruned.pdf"
    file_size = 0

    try:
        with open(temp_input_path, "wb") as f:
            while chunk := await file.read(1024 * 1024):  # 1MB chunk
                file_size += len(chunk)
                if file_size > max_bytes:
                    raise HTTPException(
                        status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                        detail=f"File exceeds maximum allowed size of {max_bytes // (1024 * 1024)}MB.",
                    )
                f.write(chunk)

        raw_pages = pages or pages_to_delete or pages_json or ""
        try:
            pages_list = parse_page_indices(raw_pages)
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid page indices specification: {str(exc)}",
            )

        if not pages_list:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No pages specified for deletion.",
            )

        # Execute page deletion
        try:
            delete_pdf_pages(temp_input_path, temp_output_path, pages_list)
        except ValueError as val_err:
            msg = str(val_err)
            if "cannot delete all pages" in msg.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=msg,
                )
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=msg,
            )
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to process PDF: {str(exc)}",
            )

        if not temp_output_path.exists():
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Pruned PDF was not successfully generated.",
            )

        return FileResponse(
            path=str(temp_output_path),
            media_type="application/pdf",
            filename=temp_output_path.name,
            background=background_tasks,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Unexpected error deleting pages from PDF: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An error occurred while pruning PDF pages: {str(e)}",
        )
