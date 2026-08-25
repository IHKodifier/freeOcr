"""Document Layout and Complexity Pre-Processing Analyzer.

Analyzes uploaded PDFs to classify layout as SIMPLE or COMPLEX:
- SIMPLE: Single-column text, basic formatting (routed to OCRmyPDF on CPU queue)
- COMPLEX: Multi-column text, complex tables, or math formulas (routed to Baidu Unlimited OCR on GPU queue)
"""

import fitz  # PyMuPDF
from typing import Dict, Any


class LayoutAnalyzer:
    @staticmethod
    def analyze_pdf_bytes(pdf_bytes: bytes) -> Dict[str, Any]:
        """Inspects PDF layout structure and returns complexity classification."""
        try:
            doc = fitz.open(stream=pdf_bytes, filetype="pdf")
            total_pages = len(doc)
            is_complex = False
            reasons = []

            for page_num in range(min(total_pages, 5)):  # Sample up to first 5 pages
                page = doc[page_num]
                blocks = page.get_text("blocks")
                
                # Check column layout by examining block horizontal coordinates
                x_centers = []
                for b in blocks:
                    # b format: (x0, y0, x1, y1, text, block_no, block_type)
                    if len(b) >= 4:
                        x0, y0, x1, y1 = b[0], b[1], b[2], b[3]
                        width = x1 - x0
                        page_width = page.rect.width
                        # If a text block width is < 40% of page width, likely multi-column
                        if width < (page_width * 0.45) and (x1 - x0) > 30:
                            x_centers.append(x0)

                # If blocks are clustered in distinct horizontal bands -> multi-column
                if len(x_centers) >= 3:
                    distinct_cols = len(set(round(x / 50) for x in x_centers))
                    if distinct_cols >= 2:
                        is_complex = True
                        reasons.append(f"Multi-column text layout detected on page {page_num + 1}")

                # Check for tables / grid lines
                drawings = page.get_drawings()
                horizontal_lines = 0
                vertical_lines = 0
                for d in drawings:
                    for item in d.get("items", []):
                        if item[0] == "l":  # line
                            p1, p2 = item[1], item[2]
                            if abs(p1.y - p2.y) < 2 and abs(p1.x - p2.x) > 50:
                                horizontal_lines += 1
                            elif abs(p1.x - p2.x) < 2 and abs(p1.y - p2.y) > 50:
                                vertical_lines += 1

                if horizontal_lines >= 4 and vertical_lines >= 2:
                    is_complex = True
                    reasons.append(f"Complex table grid detected on page {page_num + 1}")

                # Check for math formula symbols in text
                text = page.get_text("text")
                math_symbols = ["\\sum", "\\int", "\\frac", "\\sqrt", "∑", "∫", "√", "±", "≠", "≤", "≥"]
                if any(sym in text for sym in math_symbols):
                    is_complex = True
                    reasons.append(f"Math formulas detected on page {page_num + 1}")

            complexity = "COMPLEX" if is_complex else "SIMPLE"
            target_engine = "Baidu_Unlimited_OCR" if is_complex else "OCRmyPDF"
            target_queue = "ocr:queue:gpu" if is_complex else "ocr:queue:cpu"

            return {
                "complexity": complexity,
                "target_engine": target_engine,
                "target_queue": target_queue,
                "total_pages": total_pages,
                "reasons": reasons if is_complex else ["Single-column standard layout"],
            }
        except Exception as e:
            # Fallback to COMPLEX on analysis error to ensure high accuracy
            return {
                "complexity": "COMPLEX",
                "target_engine": "Baidu_Unlimited_OCR",
                "target_queue": "ocr:queue:gpu",
                "total_pages": 1,
                "reasons": [f"Analysis fallback due to: {str(e)}"],
            }
