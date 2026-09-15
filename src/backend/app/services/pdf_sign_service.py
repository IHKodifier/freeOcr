import io
import logging
from pathlib import Path

import fitz  # PyMuPDF
from PIL import Image

logger = logging.getLogger(__name__)


def sign_pdf(
    input_path: Path,
    output_path: Path,
    signature_bytes: bytes,
    target_page: int = 0,
    x: float = 100.0,
    y: float = 100.0,
    width: float = 150.0,
    height: float = 60.0,
) -> Path:
    """
    Inserts a signature image stream onto a specific page of a PDF document at specified coordinates.

    Args:
        input_path: Path to source PDF.
        output_path: Destination path for signed PDF.
        signature_bytes: Binary image content (PNG, JPG, WEBP) of the signature.
        target_page: 0-indexed page number to place signature on.
        x: Top-left X coordinate in PDF points.
        y: Top-left Y coordinate in PDF points.
        width: Width of signature box in PDF points.
        height: Height of signature box in PDF points.

    Returns:
        Path to the output signed PDF.

    Raises:
        ValueError: If parameters, page indices, or signature bytes are invalid.
        RuntimeError: If document processing or saving fails.
    """
    if not signature_bytes or len(signature_bytes) == 0:
        raise ValueError("Signature image bytes cannot be empty.")

    # Validate image can be loaded
    try:
        with Image.open(io.BytesIO(signature_bytes)) as test_img:
            test_img.verify()
    except Exception as img_err:
        raise ValueError(f"Invalid signature image format: {img_err}") from img_err

    if width <= 0 or height <= 0:
        raise ValueError(f"Signature dimensions must be positive numbers. Got width={width}, height={height}.")

    try:
        doc = fitz.open(str(input_path))
    except Exception as exc:
        logger.error("Failed to open PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Failed to open PDF document: {exc}") from exc

    try:
        total_pages = len(doc)
        if total_pages == 0:
            raise ValueError("PDF document has 0 pages.")

        if not (0 <= target_page < total_pages):
            raise ValueError(
                f"Target page index {target_page} is out of bounds. Document contains {total_pages} pages."
            )

        page = doc[target_page]

        # Calculate bounding rect for signature
        rect = fitz.Rect(float(x), float(y), float(x + width), float(y + height))

        # Insert signature image onto target page preserving transparency
        page.insert_image(
            rect,
            stream=signature_bytes,
            keep_proportion=True,
            overlay=True,
        )

        output_path.parent.mkdir(parents=True, exist_ok=True)
        doc.save(
            str(output_path),
            garbage=3,
            deflate=True,
        )
        logger.info("Successfully signed PDF page %d -> %s", target_page + 1, output_path)
        return output_path

    except Exception as exc:
        if isinstance(exc, ValueError):
            raise
        logger.error("Failed to sign PDF %s: %s", input_path, exc)
        raise RuntimeError(f"Signature processing error: {exc}") from exc
    finally:
        doc.close()
