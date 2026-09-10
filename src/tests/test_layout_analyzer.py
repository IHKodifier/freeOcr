import pytest
import pymupdf
from app.services.layout_analyzer import LayoutAnalyzer


def create_sample_pdf(text: str) -> bytes:
    doc = pymupdf.open()
    page = doc.new_page()
    page.insert_text((50, 100), text)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


def test_simple_layout_classification():
    pdf_bytes = create_sample_pdf("This is a simple single column document text.")
    result = LayoutAnalyzer.analyze_pdf_bytes(pdf_bytes)
    assert result["complexity"] == "SIMPLE"
    assert result["target_engine"] == "OCRmyPDF"
    assert result["target_queue"] == "ocr:queue:cpu"


def test_complex_layout_math_formula():
    pdf_bytes = create_sample_pdf("Mathematical equation: \\sum_{i=1}^{n} x_i = \\int_0^1 f(x)dx")
    result = LayoutAnalyzer.analyze_pdf_bytes(pdf_bytes)
    assert result["complexity"] == "COMPLEX"
    assert result["target_engine"] == "Baidu_Unlimited_OCR"
    assert result["target_queue"] == "ocr:queue:gpu"


def test_complex_layout_landscape_orientation():
    # Create landscape page (width > height)
    doc = pymupdf.open()
    page = doc.new_page(width=842, height=595)  # A4 Landscape
    page.insert_text((50, 100), "Landscape financial report")
    pdf_bytes = doc.tobytes()
    doc.close()

    result = LayoutAnalyzer.analyze_pdf_bytes(pdf_bytes)
    assert result["complexity"] == "COMPLEX"
    assert result["target_engine"] == "Baidu_Unlimited_OCR"
    assert result["target_queue"] == "ocr:queue:gpu"


def test_complex_layout_multipage_pure_scan():
    # Create 2-page document with pure image drawings and no text
    doc = pymupdf.open()
    p1 = doc.new_page()
    p1.draw_rect(pymupdf.Rect(50, 50, 200, 200), fill=(0.9, 0.9, 0.9))
    p2 = doc.new_page()
    p2.draw_rect(pymupdf.Rect(50, 50, 200, 200), fill=(0.9, 0.9, 0.9))
    pdf_bytes = doc.tobytes()
    doc.close()

    result = LayoutAnalyzer.analyze_pdf_bytes(pdf_bytes)
    assert result["complexity"] == "COMPLEX"
    assert result["target_engine"] == "Baidu_Unlimited_OCR"
    assert result["target_queue"] == "ocr:queue:gpu"
