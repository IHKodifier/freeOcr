import os
import re
import xml.etree.ElementTree as ET
import pytest

PILLARS = ["workflows", "comparisons", "solutions", "troubleshooting"]
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "frontend", "web"))


def test_category_pages_exist():
    """Verify that all 4 category directories and their index.html/flat .html files exist."""
    for pillar in PILLARS:
        dir_index = os.path.join(BASE_DIR, "kb", pillar, "index.html")
        flat_html = os.path.join(BASE_DIR, "kb", f"{pillar}.html")
        assert os.path.exists(dir_index), f"Missing category index: {dir_index}"
        assert os.path.exists(flat_html), f"Missing flat HTML fallback: {flat_html}"


def test_category_pages_meta_and_canonical():
    """Verify that each category page has proper title, description, canonical link, and OpenGraph url."""
    for pillar in PILLARS:
        path = os.path.join(BASE_DIR, "kb", pillar, "index.html")
        assert os.path.exists(path), f"File {path} must exist before checking metadata"
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check canonical
        expected_canonical = f'<link rel="canonical" href="https://freeocr.me/kb/{pillar}">'
        assert expected_canonical in content, f"Canonical tag missing or incorrect in {pillar}/index.html"

        # Check og:url
        expected_og_url = f'<meta property="og:url" content="https://freeocr.me/kb/{pillar}">'
        assert expected_og_url in content, f"og:url tag missing or incorrect in {pillar}/index.html"

        # Check Title & Description
        assert "<title>" in content and "Knowledge Base" in content
        assert '<meta name="description"' in content

        # Check AdSense ad slot
        assert "adsbygoogle" in content

        # Check JSON-LD Structured Data
        assert "application/ld+json" in content
        assert "CollectionPage" in content or "ItemList" in content

        # Check breadcrumbs link to /kb
        assert 'href="/kb"' in content


def test_main_hub_no_fragment_navigation():
    """Verify that the primary navigation and footer on /kb do not use hashtag fragment links for categories."""
    hub_path = os.path.join(BASE_DIR, "kb", "index.html")
    assert os.path.exists(hub_path), "KB index hub file must exist"
    with open(hub_path, "r", encoding="utf-8") as f:
        content = f.read()

    for pillar in PILLARS:
        # Category nav buttons should not be hash fragments
        assert f'href="#{pillar}"' not in content, f'Found disallowed anchor href="#{pillar}" in primary category navigation'
        # Footer links should not be hash fragments
        assert f'/kb#{pillar}' not in content, f'Found disallowed footer link /kb#{pillar}'
        # Real path links should exist
        assert f'/kb/{pillar}' in content, f'Expected path link /kb/{pillar} not found in main hub'


def test_sitemap_contains_categories_and_no_fragments():
    """Verify that sitemap.xml includes all 4 category URLs and contains zero fragment identifiers (#)."""
    sitemap_path = os.path.join(BASE_DIR, "sitemap.xml")
    assert os.path.exists(sitemap_path), "sitemap.xml must exist"

    tree = ET.parse(sitemap_path)
    root = tree.getroot()
    namespace = {"ns": "http://www.sitemaps.org/schemas/sitemap/0.9"}

    loc_elements = root.findall(".//ns:loc", namespace)
    urls = [elem.text.strip() for elem in loc_elements if elem.text]

    # Verify no URLs contain fragments (#)
    for url in urls:
        assert "#" not in url, f"Sitemap violation: URL '{url}' contains invalid fragment identifier '#'"

    # Verify all 4 category URLs exist
    for pillar in PILLARS:
        expected_url = f"https://freeocr.me/kb/{pillar}"
        assert expected_url in urls, f"Missing category URL in sitemap: {expected_url}"


def test_article_breadcrumbs_link_to_category():
    """Verify that child articles have breadcrumbs pointing to their parent category hub."""
    # Test ocr-guide which belongs to workflows pillar
    ocr_guide_path = os.path.join(BASE_DIR, "kb", "ocr-guide", "index.html")
    if os.path.exists(ocr_guide_path):
        with open(ocr_guide_path, "r", encoding="utf-8") as f:
            content = f.read()
        assert '/kb/workflows' in content, "Article breadcrumbs or sidebar should link to parent category /kb/workflows"
