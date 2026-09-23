# scripts/kb_articles_data.py
"""
Master Knowledge Base Articles Data for freeOCR.me.
Combines 23 in-depth, authentic technical articles across 4 content pillars:
- Pillar 1: Tool Guides & Workflows (6 articles)
- Pillar 2: Format & Tech Comparisons (6 articles)
- Pillar 3: Use-Case Solutions (6 articles)
- Pillar 4: Troubleshooting & FAQs (5 articles)
"""

import sys
import os

# Add articles subdirectory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "articles"))

from pillar1 import ARTICLES_P1
from pillar2 import ARTICLES_P2
from pillar3 import ARTICLES_P3
from pillar4 import ARTICLES_P4

PILLARS = [
    {
        "id": "workflows",
        "title": "Tool Guides & Workflows",
        "description": "Practical step-by-step guides on optimizing document digitization, batch invoice pipelines, and resolution settings.",
        "icon": "⚡",
        "slugs": [
            "ocr-guide",
            "low-res-scan-enhancement",
            "batch-invoice-processing",
            "optimal-dpi-settings",
            "pdf-to-searchable-pdf-guide",
            "secure-password-pdf-ocr"
        ]
    },
    {
        "id": "comparisons",
        "title": "Format & Tech Comparisons",
        "description": "In-depth engineering analyses of PDF standards, layout analysis engines, and machine-learning models.",
        "icon": "⚖️",
        "slugs": [
            "pdf-standards",
            "markdown-vs-text",
            "ai-vs-traditional-ocr",
            "searchable-pdf-vs-plain-text",
            "multi-column-layout-analysis",
            "ocr-engine-comparison-tesseract-paddleocr-cloud"
        ]
    },
    {
        "id": "solutions",
        "title": "Use-Case Solutions",
        "description": "Targeted enterprise workflows for legal discovery, accounting audits, academic research, and medical records.",
        "icon": "🏢",
        "slugs": [
            "privacy-security",
            "legal-discovery-court-filings",
            "receipt-expense-auditing",
            "academic-research-archiving",
            "medical-records-ocr-privacy",
            "historical-archive-preservation"
        ]
    },
    {
        "id": "troubleshooting",
        "title": "Troubleshooting & FAQs",
        "description": "Expert solutions for skewed pages, low contrast, ligatures, cursive handwriting, and scanned PDF compression.",
        "icon": "🛠️",
        "slugs": [
            "scan-restoration",
            "fixing-skewed-rotated-scans",
            "handwriting-vs-print-ocr-limits",
            "font-recognition-ligatures-special-chars",
            "compress-scanned-pdf-without-losing-ocr"
        ]
    }
]

ARTICLES = ARTICLES_P1 + ARTICLES_P2 + ARTICLES_P3 + ARTICLES_P4
