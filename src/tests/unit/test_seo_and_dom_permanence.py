"""
test_seo_and_dom_permanence.py — Governance and SEO Verification Test Suite

Verifies:
1. Permanent DOM retention of #editorial-content in index.html (zero scaffolding deletion).
2. All 23 Knowledge Base articles exist, contain >800 words, valid TechArticle schema, and AdSense tags.
3. Zero Flutter scripts on KB static pages (instant crawlability for AdSense review bots).
4. Completeness and validity of sitemap.xml across all 23 articles and compliance pages.
5. AdSense-friendly crawler access in robots.txt.
"""

import os
import re
import xml.etree.ElementTree as ET
import pytest

WORKSPACE_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
WEB_DIR = os.path.join(WORKSPACE_ROOT, "src", "frontend", "web")
INDEX_HTML = os.path.join(WEB_DIR, "index.html")
SITEMAP_XML = os.path.join(WEB_DIR, "sitemap.xml")
ROBOTS_TXT = os.path.join(WEB_DIR, "robots.txt")
KB_INDEX_HTML = os.path.join(WEB_DIR, "kb", "index.html")

EXPECTED_23_SLUGS = [
    # Pillar 1: Tool Guides & Workflows
    "ocr-guide",
    "low-res-scan-enhancement",
    "batch-invoice-processing",
    "optimal-dpi-settings",
    "pdf-to-searchable-pdf-guide",
    "secure-password-pdf-ocr",
    # Pillar 2: Format & Tech Comparisons
    "pdf-standards",
    "markdown-vs-text",
    "ai-vs-traditional-ocr",
    "searchable-pdf-vs-plain-text",
    "multi-column-layout-analysis",
    "ocr-engine-comparison-tesseract-paddleocr-cloud",
    # Pillar 3: Use-Case Solutions
    "privacy-security",
    "legal-discovery-court-filings",
    "receipt-expense-auditing",
    "academic-research-archiving",
    "medical-records-ocr-privacy",
    "historical-archive-preservation",
    # Pillar 4: Troubleshooting & FAQs
    "scan-restoration",
    "fixing-skewed-rotated-scans",
    "handwriting-vs-print-ocr-limits",
    "font-recognition-ligatures-special-chars",
    "compress-scanned-pdf-without-losing-ocr",
]


def test_editorial_content_permanence_in_index_html():
    """Verify that index.html retains #editorial-content permanently in the live DOM."""
    assert os.path.exists(INDEX_HTML), f"index.html not found at {INDEX_HTML}"

    with open(INDEX_HTML, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Must contain the semantic article container
    assert '<article id="editorial-content"' in content, "Missing <article id=\"editorial-content\"> in index.html"

    # 2. Must NEVER contain the regression code that stripped editorial content
    assert "removeChild(editorial)" not in content, (
        "CRITICAL REGRESSION: removeChild(editorial) found in index.html! "
        "This deletes editorial content upon Flutter canvas load."
    )
    assert "editorial.parentNode.removeChild" not in content, (
        "CRITICAL REGRESSION: editorial.parentNode.removeChild found in index.html!"
    )

    # 3. Must have permanent retention comment / architecture
    assert "Permanent DOM Retention" in content, "Missing Permanent DOM Retention declaration in index.html"

    # 4. Must contain substantial semantic words in #editorial-content
    article_match = re.search(r'<article id="editorial-content"[^>]*>(.*?)</article>', content, re.DOTALL)
    assert article_match, "Could not extract #editorial-content body"
    article_text = re.sub(r'<[^>]+>', ' ', article_match.group(1))
    words = [w for w in article_text.split() if w.strip()]
    assert len(words) >= 1500, f"index.html editorial content has only {len(words)} words; expected >= 1500"


def test_all_23_articles_generated_and_rich():
    """Verify that all 23 articles exist, are substantial (>800 words), and adhere to SEO standards."""
    assert len(EXPECTED_23_SLUGS) == 23

    for slug in EXPECTED_23_SLUGS:
        kb_path = os.path.join(WEB_DIR, "kb", slug, "index.html")
        mirror_path = os.path.join(WEB_DIR, "knowledge-base", slug, "index.html")

        assert os.path.exists(kb_path), f"Missing article: {kb_path}"
        assert os.path.exists(mirror_path), f"Missing mirror article: {mirror_path}"

        with open(kb_path, "r", encoding="utf-8") as f:
            html = f.read()

        # 1. Zero Flutter scripts (Instant static paint for crawlers)
        assert "flutter_bootstrap.js" not in html, f"Article {slug} should NOT load flutter_bootstrap.js"
        assert "main.dart.js" not in html, f"Article {slug} should NOT load main.dart.js"

        # 2. Word count check (>800 words)
        article_match = re.search(r'<article[^>]*>(.*?)</article>', html, re.DOTALL)
        assert article_match, f"Article {slug} missing <article> tag"
        text_only = re.sub(r'<[^>]+>', ' ', article_match.group(1))
        words = [w for w in text_only.split() if w.strip()]
        assert len(words) >= 800, f"Article '{slug}' has {len(words)} words; expected >= 800 for AdSense compliance"

        # 3. Canonical link
        expected_canonical = f'<link rel="canonical" href="https://freeocr.me/kb/{slug}">'
        assert expected_canonical in html, f"Article {slug} missing canonical tag: {expected_canonical}"

        # 4. JSON-LD TechArticle Schema
        assert '"@type": "TechArticle"' in html, f"Article {slug} missing TechArticle schema"
        assert f"https://freeocr.me/kb/{slug}" in html, f"Article {slug} schema missing mainEntityOfPage URL"

        # 5. AdSense Tag
        assert "ca-pub-6775900998665017" in html, f"Article {slug} missing AdSense publisher client tag"

        # 6. GA4 Tag
        assert "G-E852V95BXB" in html, f"Article {slug} missing GA4 measurement ID"

        # 7. Internal Cross-Link to Converter
        assert 'href="/"' in html or 'href="https://freeocr.me/"' in html, (
            f"Article {slug} missing backlink to root OCR converter"
        )


def test_sitemap_completeness_and_validity():
    """Verify that sitemap.xml is valid XML and contains all 23 articles plus compliance pages."""
    assert os.path.exists(SITEMAP_XML), f"sitemap.xml not found at {SITEMAP_XML}"

    tree = ET.parse(SITEMAP_XML)
    root = tree.getroot()

    # Namespace handling
    ns = {'ns': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
    locs = [elem.text.strip() for elem in root.findall('ns:url/ns:loc', ns)]

    # Check root and compliance pages
    assert "https://freeocr.me/" in locs
    assert "https://freeocr.me/kb" in locs
    assert "https://freeocr.me/about" in locs
    assert "https://freeocr.me/contact" in locs
    assert "https://freeocr.me/privacy" in locs
    assert "https://freeocr.me/terms" in locs

    # Check all 23 articles
    for slug in EXPECTED_23_SLUGS:
        expected_url = f"https://freeocr.me/kb/{slug}"
        assert expected_url in locs, f"sitemap.xml missing URL for article: {expected_url}"


def test_robots_txt_adsense_friendly():
    """Verify that robots.txt allows all crawlers and AdSense review bots."""
    assert os.path.exists(ROBOTS_TXT), f"robots.txt not found at {ROBOTS_TXT}"

    with open(ROBOTS_TXT, "r", encoding="utf-8") as f:
        content = f.read()

    assert "User-agent: *" in content
    # Ensure neither Googlebot nor Mediapartners-Google is blocked
    assert "Disallow: /kb" not in content
    assert "Disallow: /knowledge-base" not in content
    assert "Sitemap: https://freeocr.me/sitemap.xml" in content


def test_kb_index_hub_catalog():
    """Verify that the Knowledge Base catalog directory lists all 23 articles."""
    assert os.path.exists(KB_INDEX_HTML), f"KB index not found at {KB_INDEX_HTML}"

    with open(KB_INDEX_HTML, "r", encoding="utf-8") as f:
        content = f.read()

    for slug in EXPECTED_23_SLUGS:
        assert f"/kb/{slug}" in content or f"/knowledge-base/{slug}" in content, (
            f"KB catalog hub missing link to article: {slug}"
        )
