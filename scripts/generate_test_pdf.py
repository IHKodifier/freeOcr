#!/usr/bin/env python3
"""
generate_test_pdf.py — Generates a valid PDF file of an exact specified size in megabytes (MB).
Useful for testing file size limits, oversized file rejections, and rewarded ad boosts.

Usage:
    python scripts/generate_test_pdf.py --mb 105 --out test_105mb.pdf
"""

import argparse
import os
import sys

def generate_pdf(target_mb: float, output_path: str):
    target_bytes = int(target_mb * 1024 * 1024)
    if target_bytes < 1024:
        raise ValueError("Target size must be at least 1 KB.")

    # Base valid PDF template structure (PDF-1.4)
    header = b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n"
    
    body = (
        b"1 0 obj\n"
        b"<< /Type /Catalog /Pages 2 0 R >>\n"
        b"endobj\n"
        b"2 0 obj\n"
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>\n"
        b"endobj\n"
        b"3 0 obj\n"
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\n"
        b"endobj\n"
        b"4 0 obj\n"
        b"<< /Length 73 >>\n"
        b"stream\n"
        b"BT\n"
        b"/F1 24 Tf\n"
        b"100 700 Td\n"
        b"(freeOCR.me Test Document) Tj\n"
        b"0 -30 Td\n"
        f"({target_mb:.1f} MB Limit Testing Payload) Tj\n".encode("ascii") +
        b"ET\n"
        b"endstream\n"
        b"endobj\n"
        b"5 0 obj\n"
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\n"
        b"endobj\n"
    )

    xref_and_trailer = (
        b"xref\n"
        b"0 6\n"
        b"0000000000 65535 f \n"
        b"0000000015 00000 n \n"
        b"0000000068 00000 n \n"
        b"0000000125 00000 n \n"
        b"0000000250 00000 n \n"
        b"0000000375 00000 n \n"
        b"trailer\n"
        b"<< /Size 6 /Root 1 0 R >>\n"
        b"startxref\n"
        b"450\n"
        b"%%EOF\n"
    )

    base_len = len(header) + len(body) + len(xref_and_trailer)
    if target_bytes < base_len:
        target_bytes = base_len

    padding_needed = target_bytes - base_len
    # Embed padding as a valid PDF comment stream before trailer
    padding_block = b"% " + (b"0" * (padding_needed - 3)) + b"\n" if padding_needed >= 3 else b""

    with open(output_path, "wb") as f:
        f.write(header)
        f.write(body)
        if padding_block:
            f.write(padding_block)
        f.write(xref_and_trailer)

    actual_size = os.path.getsize(output_path)
    print(f"Generated test PDF:")
    print(f"  Path:        {os.path.abspath(output_path)}")
    print(f"  Target Size: {target_mb:.2f} MB ({target_bytes:,} bytes)")
    print(f"  Actual Size: {actual_size / (1024 * 1024):.2f} MB ({actual_size:,} bytes)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate exact size test PDF.")
    parser.add_argument("--mb", type=float, default=105.0, help="File size in megabytes (e.g. 105 for > 100MB)")
    parser.add_argument("--out", type=str, default="test_105mb.pdf", help="Output file path")
    args = parser.parse_args()
    generate_pdf(args.mb, args.out)
