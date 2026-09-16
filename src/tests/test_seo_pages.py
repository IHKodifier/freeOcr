import os
import pytest
from scripts.build_seo_pages import markdown_to_simple_html

def test_seo_pages_inject_domain_aware_ga4_tag():
    sample_md = """# Free Online PDF Tools
## Complete Zero-Retention PDF Engine
FreePDFToolz provides 16 high-performance PDF manipulation utilities.
"""
    # 1. Test freepdftoolz.me domain tag
    html_pdftoolz = markdown_to_simple_html(sample_md, "FreePDFToolz Hub", domain="freepdftoolz.me")
    assert "https://www.googletagmanager.com/gtag/js?id=G-W4D8V33FX1" in html_pdftoolz
    assert "G-W4D8V33FX1" in html_pdftoolz
    assert "freepdftoolz.me" in html_pdftoolz

    # 2. Test freeocr.me domain tag
    html_freeocr = markdown_to_simple_html(sample_md, "freeOCR Guide", domain="freeocr.me")
    assert "https://www.googletagmanager.com/gtag/js?id=G-E852V95BXB" in html_freeocr
    assert "G-E852V95BXB" in html_freeocr
    assert "freeocr.me" in html_freeocr

def test_seo_pages_structure_and_meta():
    sample_md = """# PDF Compression Guide
## High Resolution Downsampling
Explaining vector quantization and stream deflate compression.
"""
    html = markdown_to_simple_html(sample_md, "Compress PDF Guide", domain="freepdftoolz.me")
    assert "<title>Compress PDF Guide | FreePDFToolz.me</title>" in html or "FreePDFToolz" in html
    assert "schema.org" in html
    assert "TechArticle" in html
    assert "<h1>" in html
