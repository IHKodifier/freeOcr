import logging
from pathlib import Path
import shutil
from typing import Dict, Any

import fitz  # PyMuPDF

logger = logging.getLogger(__name__)

VALID_COMPRESSION_LEVELS = ("recommended", "extreme", "low")


def compress_pdf(
    input_path: Path,
    output_path: Path,
    level: str = "recommended",
) -> Dict[str, Any]:
    """
    Compresses an input PDF document using stream optimization, object deduplication,
    garbage collection, and adaptive image downsampling.

    Presets:
    - recommended (Default): Downsamples images to ~150 DPI equivalent (JPEG quality 75)
      with full stream deflation and object garbage collection.
    - extreme: Downsamples images to ~72 DPI equivalent (shrink factor 2+, JPEG quality 50)
      for maximum size reduction.
    - low (Lossless): Stream deflation, object deduplication, and garbage collection
      with zero image downsampling (lossless quality).

    Includes an automated Byte Size Safety Guard: if the resulting output file exceeds
    or equals the original file size, the original file is preserved so the output
    is guaranteed never to be larger than the input.
    """
    normalized_level = (level or "recommended").strip().lower()
    if normalized_level not in VALID_COMPRESSION_LEVELS:
        raise ValueError(
            f"Invalid compression level '{level}'. Must be one of {VALID_COMPRESSION_LEVELS}."
        )

    if not input_path.exists() or input_path.stat().st_size == 0:
        raise ValueError(f"Input file '{input_path}' does not exist or is empty.")

    original_size = input_path.stat().st_size

    # Open document locally
    doc = fitz.open(str(input_path))
    processed_xrefs = set()

    try:
        # Downsample images if not in lossless mode
        if normalized_level in ("recommended", "extreme"):
            for page in doc:
                image_list = page.get_images(full=True)
                for img_info in image_list:
                    xref = img_info[0]
                    if xref in processed_xrefs:
                        continue
                    processed_xrefs.add(xref)

                    try:
                        pix = fitz.Pixmap(doc, xref)

                        # If pixmap has CMYK colorspace or alpha channel, convert to standard RGB
                        if pix.colorspace and pix.colorspace.n >= 4 or pix.alpha:
                            pix = fitz.Pixmap(fitz.csRGB, pix)

                        # Downsampling logic according to level
                        if normalized_level == "extreme":
                            # Aggressive downsampling: shrink factor 2 if dimension >= 100
                            if pix.width >= 100 or pix.height >= 100:
                                pix.shrink(2)
                            jpeg_bytes = pix.tobytes("jpeg", jpg_quality=50)
                            page.replace_image(xref, stream=jpeg_bytes)
                        elif normalized_level == "recommended":
                            # Moderate downsampling: shrink factor 2 if large, otherwise quality 75
                            if pix.width >= 600 or pix.height >= 600:
                                pix.shrink(2)
                            jpeg_bytes = pix.tobytes("jpeg", jpg_quality=75)
                            page.replace_image(xref, stream=jpeg_bytes)
                    except Exception as img_err:
                        logger.debug("Skipping non-standard image xref %s: %s", xref, img_err)

        # Write output with stream deflation and maximum garbage collection
        doc.save(
            str(output_path),
            garbage=4,
            deflate=True,
            deflate_images=True,
            deflate_fonts=True,
            clean=True,
        )
    finally:
        doc.close()

    # Byte Size Guard: Ensure compressed output is not larger than original
    compressed_size = output_path.stat().st_size
    if compressed_size >= original_size:
        logger.info(
            "Compressed size (%d bytes) >= original (%d bytes). Preserving original file.",
            compressed_size,
            original_size,
        )
        shutil.copyfile(str(input_path), str(output_path))
        final_size = original_size
        saved_bytes = 0
        percent_saved = 0.0
    else:
        final_size = compressed_size
        saved_bytes = original_size - final_size
        percent_saved = round((saved_bytes / original_size) * 100, 1)

    return {
        "original_size": original_size,
        "compressed_size": final_size,
        "saved_bytes": saved_bytes,
        "percent_saved": percent_saved,
        "level": normalized_level,
    }
