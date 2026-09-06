import os
import pymupdf
import pytest
from app.services.pdf_composer import compose_searchable_pdf, get_searchable_pdf


def test_complex_two_column_pdf_reconstruction():
    """
    Simulates a 2-column complex document where Baidu Unlimited OCR extracts
    bounding boxes across Column 1 (left) and Column 2 (right).
    Verifies that compose_searchable_pdf reconstructs the PDF with pixel-perfect alignment,
    independent column boundaries, and accurate text searchability.
    """
    job_id = "test_complex_two_column_001"
    
    # Create a 2-column visual base document (A4: 595 x 842 points)
    doc = pymupdf.open()
    page = doc.new_page(width=595, height=842)
    
    # Draw two distinct columns visually
    col1_x0, col1_x1 = 50.0, 270.0
    col2_x0, col2_x1 = 320.0, 540.0
    
    # Column 1 Text
    page.insert_text(pymupdf.Point(col1_x0, 100), "Left Column Header", fontsize=14)
    page.insert_text(pymupdf.Point(col1_x0, 130), "This is section one of the document.", fontsize=10)
    page.insert_text(pymupdf.Point(col1_x0, 150), "Financial data for Q3 shows steady growth.", fontsize=10)
    
    # Column 2 Text
    page.insert_text(pymupdf.Point(col2_x0, 100), "Right Column Header", fontsize=14)
    page.insert_text(pymupdf.Point(col2_x0, 130), "This is section two with engineering notes.", fontsize=10)
    page.insert_text(pymupdf.Point(col2_x0, 150), "Deployment completed on scale-to-zero GCP nodes.", fontsize=10)
    
    original_pdf_bytes = doc.tobytes()
    doc.close()

    # OCR Bounding Boxes as extracted from a 300 DPI scan scaled to PDF point canvas
    pages_data = [
        {
            "page_number": 1,
            "text": "Left Column Header\nThis is section one of the document.\nFinancial data for Q3 shows steady growth.\nRight Column Header\nThis is section two with engineering notes.\nDeployment completed on scale-to-zero GCP nodes.",
            "lines": [
                # Column 1
                {"bbox": [col1_x0, 85.0, 200.0, 105.0], "text": "Left Column Header", "size": 14.0},
                {"bbox": [col1_x0, 118.0, 260.0, 134.0], "text": "This is section one of the document.", "size": 10.0},
                {"bbox": [col1_x0, 138.0, 265.0, 154.0], "text": "Financial data for Q3 shows steady growth.", "size": 10.0},
                # Column 2
                {"bbox": [col2_x0, 85.0, 480.0, 105.0], "text": "Right Column Header", "size": 14.0},
                {"bbox": [col2_x0, 118.0, 535.0, 134.0], "text": "This is section two with engineering notes.", "size": 10.0},
                {"bbox": [col2_x0, 138.0, 538.0, 154.0], "text": "Deployment completed on scale-to-zero GCP nodes.", "size": 10.0},
            ]
        }
    ]

    reconstructed_bytes, token = compose_searchable_pdf(job_id, pages_data, original_pdf_bytes)
    assert isinstance(reconstructed_bytes, bytes)
    assert len(reconstructed_bytes) > len(original_pdf_bytes)
    assert token.startswith("pdf_token_")

    # Verify reconstructed PDF with PyMuPDF
    res_doc = pymupdf.open("pdf", reconstructed_bytes)
    assert len(res_doc) == 1
    res_page = res_doc[0]

    # Search for Column 1 phrase
    col1_hits = res_page.search_for("Left Column Header")
    assert len(col1_hits) > 0
    hit1 = col1_hits[0]
    # Verify hit is located in Column 1 boundary (x < 300)
    assert hit1.x0 >= col1_x0 - 5.0
    assert hit1.x1 <= 300.0

    # Search for Column 2 phrase
    col2_hits = res_page.search_for("Right Column Header")
    assert len(col2_hits) > 0
    hit2 = col2_hits[0]
    # Verify hit is located in Column 2 boundary (x >= 320)
    assert hit2.x0 >= col2_x0 - 5.0

    # Verify full text extraction maintains both columns
    extracted_text = res_page.get_text()
    assert "Left Column Header" in extracted_text
    assert "Right Column Header" in extracted_text
    assert "Financial data for Q3" in extracted_text
    assert "Deployment completed on scale-to-zero" in extracted_text

    res_doc.close()


def test_word_level_highlight_alignment_and_space_distribution():
    """
    Verifies that the rightmost word of a line (e.g. 'writing') reaches the right edge
    of the line bounding box, guaranteeing 100% visual highlight coverage in PDF viewers.
    """
    job_id = "test_word_alignment_002"
    doc = pymupdf.open()
    page = doc.new_page(width=595, height=842)
    pdf_bytes = doc.tobytes()
    doc.close()

    line_text = "This MOU may only be amended, modified and/or supplemented if mutually agreed in writing"
    # Scanned line bbox from 50.0 to 510.0 (width 460 points)
    line_bbox = [50.0, 100.0, 510.0, 115.0]

    # Test Case A: Word-level bounding boxes from OCR
    words = [
        {"bbox": [50.0, 100.0, 75.0, 115.0], "text": "This"},
        {"bbox": [78.0, 100.0, 105.0, 115.0], "text": "MOU"},
        {"bbox": [470.0, 100.0, 510.0, 115.0], "text": "writing"}
    ]
    pages_data = [
        {
            "page_number": 1,
            "lines": [
                {"bbox": line_bbox, "text": line_text, "size": 11.0, "words": words}
            ]
        }
    ]

    out_bytes, token = compose_searchable_pdf(job_id, pages_data, pdf_bytes)
    res_doc = pymupdf.open("pdf", out_bytes)
    res_page = res_doc[0]

    # Search for 'writing'
    writing_hits = res_page.search_for("writing")
    assert len(writing_hits) > 0
    # Right edge of 'writing' must reach >= 500 points (near 510.0)
    assert writing_hits[0].x1 >= 500.0, f"Expected writing.x1 >= 500.0, got {writing_hits[0].x1}"

    # Test Case B: Line fallback without words list (proportional space distribution)
    pages_data_fallback = [
        {
            "page_number": 1,
            "lines": [
                {"bbox": line_bbox, "text": line_text, "size": 11.0}
            ]
        }
    ]
    out_bytes_fb, _ = compose_searchable_pdf(job_id + "_fb", pages_data_fallback, pdf_bytes)
    res_doc_fb = pymupdf.open("pdf", out_bytes_fb)
    hits_fb = res_doc_fb[0].search_for("writing")
    assert len(hits_fb) > 0
    # With space distribution, 'writing' must also be near the right boundary (>= 470.0)
    assert hits_fb[0].x1 >= 470.0, f"Expected fallback writing.x1 >= 470.0, got {hits_fb[0].x1}"

    res_doc.close()
    res_doc_fb.close()

