"""
standardize_footers.py — Enforce and Synchronize Canonical HTML Footers Across Web Root

Replaces divergent inline footers with the canonical 4-column freeOCR.me footer component from
scripts/common_html_components.py across all static HTML files in src/frontend/web.
Supports --check flag for automated CI/CD and pre-commit regression checks.
"""

import argparse
import os
import re
import sys
from pathlib import Path

# Ensure scripts dir is in sys.path
sys.path.insert(0, str(Path(__file__).parent))
from common_html_components import get_canonical_footer_css, get_canonical_footer_html

FOOTER_REGEX = re.compile(r"<footer[\s\S]*?</footer>", re.IGNORECASE)
STYLE_END_REGEX = re.compile(r"</style>", re.IGNORECASE)


def standardize_file(file_path: Path, check_only: bool = False) -> bool:
    """
    Validates or standardizes a single HTML file.
    Returns True if file was modified (or needs modification in check_only mode).
    """
    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as e:
        print(f"[ERROR] Could not read {file_path}: {e}")
        return False

    if not FOOTER_REGEX.search(content):
        # File has no footer (e.g., manifest, minimal stub)
        return False

    canonical_footer = get_canonical_footer_html()

    # Compliance checks:
    has_app_footer = 'class="app-footer"' in content or "class='app-footer'" in content
    has_engine_chips = "engine-chip" in content and "Baidu Unlimited OCR" in content
    has_ai_ocr_link = "/kb/ai-vs-traditional-ocr" in content
    has_legal_title = "<h3>Legal</h3>" in content
    has_footer_css = ".app-footer" in content or ".engine-chip" in content

    is_compliant = (
        has_app_footer
        and has_engine_chips
        and has_ai_ocr_link
        and has_legal_title
        and has_footer_css
    )

    if check_only:
        if not is_compliant:
            print(f"[NON-COMPLIANT] {file_path.relative_to(file_path.parents[2])}")
            return True
        return False

    # Perform replacement
    new_content = FOOTER_REGEX.sub(canonical_footer, content, count=1)

    # Inject CSS if not present
    if not has_footer_css and STYLE_END_REGEX.search(new_content):
        footer_css = f"\n{get_canonical_footer_css()}\n</style>"
        new_content = STYLE_END_REGEX.sub(footer_css, new_content, count=1)

    if new_content != content:
        file_path.write_text(new_content, encoding="utf-8")
        return True

    return False


def main():
    parser = argparse.ArgumentParser(description="Standardize static HTML footers across frontend web root.")
    parser.add_argument("--check", action="store_true", help="Fail if any HTML file has a non-standard footer.")
    parser.add_argument("--target-dir", default=None, help="Specific directory to scan (defaults to src/frontend/web).")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    web_dir = Path(args.target_dir) if args.target_dir else project_root / "src" / "frontend" / "web"

    if not web_dir.exists():
        print(f"[SKIP] Directory {web_dir} does not exist.")
        sys.exit(0)

    html_files = sorted(list(web_dir.rglob("*.html")))
    total_files = len(html_files)
    modified_count = 0

    print(f"Scanning {total_files} HTML files in {web_dir}...")

    for f in html_files:
        if standardize_file(f, check_only=args.check):
            modified_count += 1

    if args.check:
        if modified_count > 0:
            print(f"\n[FAILED] {modified_count} out of {total_files} files deviated from canonical footer standard!")
            sys.exit(1)
        else:
            print(f"\n[PASSED] All {total_files} files comply 100% with the canonical footer standard.")
            sys.exit(0)
    else:
        print(f"\n[DONE] Standardized footers in {modified_count} files (out of {total_files} scanned).")


if __name__ == "__main__":
    main()
