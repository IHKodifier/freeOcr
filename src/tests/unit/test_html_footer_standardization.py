"""
test_html_footer_standardization.py — Automated Guard Against HTML / Flutter Footer Drift

Enforces that 100% of pre-rendered static HTML files in src/frontend/web strictly
match the canonical 4-column footer component (AppFooter) defined in
scripts/common_html_components.py and Flutter's AppFooter widget.
"""

import os
import re
from pathlib import Path
import pytest

ROOT_DIR = Path(__file__).resolve().parent.parent.parent.parent
WEB_DIR = ROOT_DIR / "src" / "frontend" / "web"
SCRIPTS_DIR = ROOT_DIR / "scripts"

FOOTER_TAG_REGEX = re.compile(r"<footer\b[^>]*>", re.IGNORECASE)


def get_html_files_with_footers():
    """Returns all HTML files in src/frontend/web that render a footer."""
    if not WEB_DIR.exists():
        return []
    files = []
    for f in WEB_DIR.rglob("*.html"):
        content = f.read_text(encoding="utf-8")
        if FOOTER_TAG_REGEX.search(content):
            files.append(f)
    return files


@pytest.fixture(scope="module")
def html_files():
    return get_html_files_with_footers()


def test_html_files_detected(html_files):
    """Ensure there are static HTML files present and being audited."""
    assert len(html_files) >= 5, f"Expected at least 5 static HTML files with footers, found {len(html_files)}"


def test_every_footer_has_app_footer_class(html_files):
    """Every footer must use the canonical .app-footer container class."""
    failures = []
    for f in html_files:
        content = f.read_text(encoding="utf-8")
        if 'class="app-footer"' not in content and "class='app-footer'" not in content:
            failures.append(str(f.relative_to(WEB_DIR)))
    assert not failures, f"Files missing class='app-footer': {failures}"


def test_every_footer_contains_engine_chips(html_files):
    """Every footer must contain all 4 open-source engine chips with .engine-chip class."""
    required_engines = ["Baidu Unlimited OCR", "Tesseract OCR", "OCRmyPDF", "PyMuPDF"]
    failures = []
    for f in html_files:
        content = f.read_text(encoding="utf-8")
        for eng in required_engines:
            if eng not in content:
                failures.append(f"{f.name} missing engine: {eng}")
        if "engine-chip" not in content:
            failures.append(f"{f.name} missing class engine-chip")
    assert not failures, f"Engine chip discrepancies found:\n" + "\n".join(failures[:10])


def test_every_footer_contains_ai_ocr_route(html_files):
    """Every footer must contain the canonical link to /kb/ai-vs-traditional-ocr."""
    failures = []
    for f in html_files:
        content = f.read_text(encoding="utf-8")
        if "/kb/ai-vs-traditional-ocr" not in content:
            failures.append(str(f.relative_to(WEB_DIR)))
    assert not failures, f"Files missing /kb/ai-vs-traditional-ocr link: {failures}"


def test_every_footer_has_legal_section_title(html_files):
    """Section title must strictly be 'Legal' matching Flutter AppFooter (not 'Legal & Support')."""
    failures = []
    for f in html_files:
        content = f.read_text(encoding="utf-8")
        if "<h3>Legal</h3>" not in content:
            failures.append(str(f.relative_to(WEB_DIR)))
    assert not failures, f"Files missing <h3>Legal</h3> section title: {failures}"


def test_every_footer_has_social_channels(html_files):
    """Every footer must contain links to official Twitter/X, Instagram, and Facebook handles."""
    required_socials = [
        "https://x.com/freeocrme",
        "https://instagram.com/freeocrme",
        "https://facebook.com/freeOCRme",
    ]
    failures = []
    for f in html_files:
        content = f.read_text(encoding="utf-8")
        for soc in required_socials:
            if soc not in content:
                failures.append(f"{f.name} missing social link: {soc}")
    assert not failures, f"Social link discrepancies found:\n" + "\n".join(failures[:10])


def test_generator_scripts_import_common_html_components():
    """Verify that all static generator scripts import common_html_components."""
    generators = [
        SCRIPTS_DIR / "generate_kb_static_pages.py",
        SCRIPTS_DIR / "generate_kb_index_hub.py",
        SCRIPTS_DIR / "build_seo_pages.py",
    ]
    for gen in generators:
        assert gen.exists(), f"Generator script {gen} not found"
        code = gen.read_text(encoding="utf-8")
        assert "common_html_components" in code, f"{gen.name} does not import common_html_components"
        assert "get_canonical_footer_html" in code, f"{gen.name} does not call get_canonical_footer_html"
