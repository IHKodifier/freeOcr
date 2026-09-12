from typing import Any, Dict, List
from fastapi import APIRouter, HTTPException

router = APIRouter()

TOOLS_CATALOG: List[Dict[str, Any]] = [
    # Page Operations (6 tools)
    {
        "id": "merge",
        "name": "Merge PDF",
        "description": "Combine multiple PDF files into a single unified document in any order.",
        "category": "page_ops",
        "route": "/merge",
        "icon": "merge_type",
        "badge": "POPULAR",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "split",
        "name": "Split PDF",
        "description": "Separate one page or an entire set of pages for easy conversion into independent PDF files.",
        "category": "page_ops",
        "route": "/split",
        "icon": "call_split",
        "badge": "POPULAR",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "rotate",
        "name": "Rotate PDF",
        "description": "Rotate PDF pages clockwise or counterclockwise permanently.",
        "category": "page_ops",
        "route": "/rotate",
        "icon": "rotate_right",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "delete-pages",
        "name": "Delete Pages",
        "description": "Remove unwanted or duplicate pages from your PDF file effortlessly.",
        "category": "page_ops",
        "route": "/delete-pages",
        "icon": "delete_sweep",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "extract-pages",
        "name": "Extract Pages",
        "description": "Select specific pages to extract into a fresh, clean PDF document.",
        "category": "page_ops",
        "route": "/extract-pages",
        "icon": "file_copy",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "number-pages",
        "name": "Number Pages",
        "description": "Add clean, customizable page numbering with custom font, size, and position.",
        "category": "page_ops",
        "route": "/number-pages",
        "icon": "format_list_numbered",
        "badge": "NEW",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    # Security & Privacy (5 tools)
    {
        "id": "compress",
        "name": "Compress PDF",
        "description": "Reduce PDF file size while preserving high visual quality.",
        "category": "security",
        "route": "/compress",
        "icon": "compress",
        "badge": "POPULAR",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "watermark",
        "name": "Watermark PDF",
        "description": "Stamp custom text or transparent image watermarks across your document.",
        "category": "security",
        "route": "/watermark",
        "icon": "branding_watermark",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "crop",
        "name": "Crop PDF",
        "description": "Trim page margins or select custom viewport boundaries for your PDF.",
        "category": "security",
        "route": "/crop",
        "icon": "crop",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "redact",
        "name": "Redact PDF",
        "description": "Permanently sanitize and black out sensitive data, text, and confidential areas.",
        "category": "security",
        "route": "/redact",
        "icon": "shield",
        "badge": "SECURITY",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "sign",
        "name": "Sign PDF",
        "description": "Draw, type, or upload verifiable digital signatures to sign PDF documents.",
        "category": "security",
        "route": "/sign",
        "icon": "draw",
        "badge": "POPULAR",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    # AI & Conversions (5 tools)
    {
        "id": "ocr",
        "name": "OCR PDF",
        "description": "Convert scanned PDFs and images into searchable PDFs and selectable text.",
        "category": "ai_conversions",
        "route": "/ocr",
        "icon": "document_scanner",
        "badge": "AI",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "annotate",
        "name": "Annotate PDF",
        "description": "Highlight text, add sticky comments, shapes, and freehand markup directly on PDF.",
        "category": "ai_conversions",
        "route": "/annotate",
        "icon": "edit_note",
        "badge": None,
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "edit-text",
        "name": "Edit Text",
        "description": "Modify, correct, and update existing text inside PDF documents directly.",
        "category": "ai_conversions",
        "route": "/edit-text",
        "icon": "text_fields",
        "badge": "NEW",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "pdf-to-word",
        "name": "Convert to Word",
        "description": "Convert PDF documents to editable Microsoft Word .docx files with high layout accuracy.",
        "category": "ai_conversions",
        "route": "/pdf-to-word",
        "icon": "article",
        "badge": "POPULAR",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
    {
        "id": "summarize",
        "name": "Summarize PDF",
        "description": "Generate concise AI summaries, key takeaways, and outline briefs from long PDFs.",
        "category": "ai_conversions",
        "route": "/summarize",
        "icon": "auto_stories",
        "badge": "AI",
        "max_free_mb": 100,
        "max_boosted_mb": 1000,
    },
]

CATEGORIES_META: Dict[str, Dict[str, Any]] = {
    "page_ops": {
        "title": "Page Operations",
        "description": "Organize, merge, split, rotate, and manage PDF pages.",
    },
    "security": {
        "title": "Security & Optimization",
        "description": "Compress, watermark, crop, redact, and sign PDF files.",
    },
    "ai_conversions": {
        "title": "AI & Conversions",
        "description": "Optical character recognition, text editing, conversion, and AI summarization.",
    },
}


@router.get("")
def get_tools_catalog() -> Dict[str, Any]:
    """
    Returns the complete catalog of all 16 PDF tools with metadata,
    routes, and tier limits.
    """
    return {
        "tools": TOOLS_CATALOG,
        "total": len(TOOLS_CATALOG),
    }


@router.get("/categories")
def get_tool_categories() -> Dict[str, Any]:
    """
    Returns the categorized breakdown of tools.
    """
    result: Dict[str, Any] = {}
    for cat_key, meta in CATEGORIES_META.items():
        cat_tools = [t for t in TOOLS_CATALOG if t["category"] == cat_key]
        result[cat_key] = {
            **meta,
            "tools": cat_tools,
            "count": len(cat_tools),
        }
    return result


@router.get("/{tool_id}")
def get_tool_detail(tool_id: str) -> Dict[str, Any]:
    """
    Returns metadata for a specific tool by ID.
    Raises 404 if tool does not exist.
    """
    for tool in TOOLS_CATALOG:
        if tool["id"] == tool_id:
            return tool
    raise HTTPException(status_code=404, detail="Tool not found")
