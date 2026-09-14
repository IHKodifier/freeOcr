import io
from pathlib import Path
import fitz  # PyMuPDF
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.pdf_number_pages_service import (
    number_pdf_pages,
    VALID_POSITIONS,
)

client = TestClient(app)


def create_mock_pdf_bytes(page_texts: list[str]) -> bytes:
    """Helper to generate a minimal valid in-memory PDF with specified page text."""
    doc = fitz.open()
    for text in page_texts:
        page = doc.new_page(width=595, height=842)  # A4
        page.insert_text((50, 100), text, fontsize=14)
    pdf_bytes = doc.write()
    doc.close()
    return pdf_bytes


# --- Unit Tests: Numbering Service ---


def test_number_pages_bottom_center_inserts_text(tmp_path: Path):
    """
    AC: Numbers a 3-page document with 'bottom-center' and format 'Page {n} of {total}'.
    Inspects page text via page.get_text() to verify 'Page 1 of 3' is present on first page.
    """
    pdf_bytes = create_mock_pdf_bytes(["Original P1", "Original P2", "Original P3"])
    input_path = tmp_path / "input.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_numbered.pdf"

    result_path = number_pdf_pages(
        input_path=input_path,
        output_path=output_path,
        position="bottom-center",
        format_str="Page {n} of {total}",
        skip_first_page=False,
        start_number=1,
    )

    assert result_path.exists()
    doc = fitz.open(str(result_path))
    assert doc.page_count == 3
    assert "Page 1 of 3" in doc[0].get_text()
    assert "Page 2 of 3" in doc[1].get_text()
    assert "Page 3 of 3" in doc[2].get_text()
    doc.close()


def test_skip_cover_page_leaves_first_page_untouched(tmp_path: Path):
    """
    AC: Numbers with skip_first_page=True; asserts page 0 contains no page number string
    while page 1 contains the formatted number.
    """
    pdf_bytes = create_mock_pdf_bytes(["Cover Page", "Content Page 1", "Content Page 2"])
    input_path = tmp_path / "input_cover.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_cover.pdf"

    result_path = number_pdf_pages(
        input_path=input_path,
        output_path=output_path,
        position="bottom-center",
        format_str="Page {n} of {total}",
        skip_first_page=True,
        start_number=1,
    )

    assert result_path.exists()
    doc = fitz.open(str(result_path))
    assert doc.page_count == 3

    # First page (cover) should NOT have any "Page" number overlay
    p0_text = doc[0].get_text()
    assert "Cover Page" in p0_text
    assert "Page 1 of" not in p0_text
    assert "Page 2 of" not in p0_text

    # Second page should have Page 1 of 2
    p1_text = doc[1].get_text()
    assert "Content Page 1" in p1_text
    assert "Page 1 of 2" in p1_text

    # Third page should have Page 2 of 2
    p2_text = doc[2].get_text()
    assert "Page 2 of 2" in p2_text
    doc.close()


def test_number_pages_respects_custom_start_index(tmp_path: Path):
    """
    AC: Starting at 5 on a 2-page document produces 'Page 5 of 6' and 'Page 6 of 6'.
    """
    pdf_bytes = create_mock_pdf_bytes(["P1", "P2"])
    input_path = tmp_path / "input_custom_start.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_custom_start.pdf"

    result_path = number_pdf_pages(
        input_path=input_path,
        output_path=output_path,
        position="bottom-center",
        format_str="Page {n} of {total}",
        skip_first_page=False,
        start_number=5,
    )

    assert result_path.exists()
    doc = fitz.open(str(result_path))
    assert doc.page_count == 2
    assert "Page 5 of 6" in doc[0].get_text()
    assert "Page 6 of 6" in doc[1].get_text()
    doc.close()


@pytest.mark.parametrize("pos", list(VALID_POSITIONS))
def test_number_pages_all_positions(tmp_path: Path, pos: str):
    """Verifies that all 6 supported positions apply without errors."""
    pdf_bytes = create_mock_pdf_bytes(["Test Page"])
    input_path = tmp_path / f"input_{pos}.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / f"output_{pos}.pdf"

    result_path = number_pdf_pages(
        input_path=input_path,
        output_path=output_path,
        position=pos,
        format_str="Page {n}",
    )

    assert result_path.exists()
    doc = fitz.open(str(result_path))
    assert doc.page_count == 1
    assert "Page 1" in doc[0].get_text()
    doc.close()


def test_number_pages_invalid_position_raises_value_error(tmp_path: Path):
    """Invalid position string raises ValueError."""
    pdf_bytes = create_mock_pdf_bytes(["Test Page"])
    input_path = tmp_path / "input_bad_pos.pdf"
    input_path.write_bytes(pdf_bytes)
    output_path = tmp_path / "output_bad_pos.pdf"

    with pytest.raises(ValueError, match="Invalid position"):
        number_pdf_pages(
            input_path=input_path,
            output_path=output_path,
            position="center-middle",
        )


def test_number_pages_empty_file_raises_error(tmp_path: Path):
    """Empty 0-byte file raises RuntimeError."""
    empty_path = tmp_path / "empty.pdf"
    empty_path.write_bytes(b"")

    out_path = tmp_path / "empty_out.pdf"
    with pytest.raises(RuntimeError, match="Failed to open PDF"):
        number_pdf_pages(input_path=empty_path, output_path=out_path)



# --- Integration Tests: POST /api/v1/tools/number-pages ---


def test_number_pages_endpoint_success():
    """Verifies endpoint numbers pages and returns valid PDF stream with correct headers."""
    pdf = create_mock_pdf_bytes(["Hello World", "Second Page"])
    files = {"file": ("report.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {
        "position": "bottom-center",
        "format": "Page {n} of {total}",
        "skip_cover": "false",
        "start_page": "1",
        "font_size": "10.0",
    }

    response = client.post("/api/v1/tools/number-pages", files=files, data=data)
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert "report_numbered.pdf" in response.headers.get("content-disposition", "")

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert "Page 1 of 2" in result_doc[0].get_text()
    assert "Page 2 of 2" in result_doc[1].get_text()
    result_doc.close()


def test_number_pages_endpoint_skip_cover():
    """Verifies endpoint respects skip_cover=true."""
    pdf = create_mock_pdf_bytes(["Front Cover", "Chapter 1"])
    files = {"file": ("book.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {
        "position": "bottom-right",
        "format": "Page {n}",
        "skip_cover": "true",
        "start_page": "1",
    }

    response = client.post("/api/v1/tools/number-pages", files=files, data=data)
    assert response.status_code == 200

    result_doc = fitz.open(stream=response.content, filetype="pdf")
    assert result_doc.page_count == 2
    assert "Page 1" not in result_doc[0].get_text()
    assert "Page 1" in result_doc[1].get_text()
    result_doc.close()


def test_number_pages_endpoint_invalid_file_type():
    """Uploading a non-PDF file returns HTTP 400 Bad Request."""
    files = {"file": ("doc.txt", io.BytesIO(b"Just text"), "text/plain")}
    data = {"position": "bottom-center"}

    response = client.post("/api/v1/tools/number-pages", files=files, data=data)
    assert response.status_code == 400
    assert "pdf" in response.json().get("detail", "").lower()


def test_number_pages_endpoint_invalid_position():
    """Invalid position parameter returns HTTP 400 Bad Request."""
    pdf = create_mock_pdf_bytes(["Test"])
    files = {"file": ("test.pdf", io.BytesIO(pdf), "application/pdf")}
    data = {"position": "middle-center"}

    response = client.post("/api/v1/tools/number-pages", files=files, data=data)
    assert response.status_code == 400
    assert "invalid position" in response.json().get("detail", "").lower()
