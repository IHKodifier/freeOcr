# TASK DISPATCH: Implement UC-018 (Split PDF Engine & Page Range Selector UI)

> **Ticket:** `UC-018`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-018-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-018-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-018-pdf-split` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** All PDF split operations execute locally using PyMuPDF (`fitz`) and RAM disk / temporary storage; no paid external cloud APIs.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-018-split-pdf-engine--page-range-selector-ui)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-018

**Ticket ID:** UC-018  
**Name:** Split PDF Engine & Page Range Selector UI  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/split` and uploads a multi-page PDF document.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-018-pdf-split` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-018-pdf-split
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Split Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_split_service.py`:
   - Function `parse_page_ranges(range_str: str, max_pages: int) -> list[list[int]]`:
     - Parses expressions like `"1-3, 5, 8-10"` into 0-indexed page list groupings `[[0, 1, 2], [4], [7, 8, 9]]`.
     - Validates bounds (1 to `max_pages`). Raises `ValueError` for invalid ranges or out-of-bounds page numbers.
   - Function `split_pdf(input_path: Path, ranges: list[list[int]], output_dir: Path) -> list[Path]`:
     - Iterates through ranges, uses `doc.select(page_group)` or `new_doc.insert_pdf(src_doc, from_page, to_page)`.
     - Generates output files e.g. `Document_1-3.pdf`.
     - If multiple output files are produced, creates a clean `.zip` archive via Python `zipfile`.
2. Create `src/backend/app/api/v1/endpoints/tools_split.py`:
   - Endpoint `POST /api/v1/tools/split`:
     - Accepts `file: UploadFile`, `mode: str` (`ranges`, `fixed`, `all`), `ranges: Optional[str]`, `split_every: Optional[int]`.
     - Validates PDF format and file size limit (100MB free / 1GB boosted).
     - Returns HTTP 422 with descriptive error if range syntax is invalid or exceeds page count.
     - Returns single PDF (`FileResponse` as `.pdf`) if 1 range produced, or ZIP archive (`application/zip`) if multiple chunks produced.
     - Cleans up temporary files in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Split View & Range Selector UI (`src/frontend/lib/pages/pdf_split_page.dart`)
1. Replace placeholder route for `/split` with dedicated `PdfSplitPage`:
   - Upload dropzone for a single PDF.
   - Once file uploaded, displays detected document metadata (filename, size, total pages).
   - Mode Selector Tabs/Chips:
     - **Mode A: Custom Ranges** (Text field with helper syntax `e.g. 1-2, 5, 7-10`, dynamic range chips, "Add Range" button).
     - **Mode B: Split Every N Pages** (Numeric stepper `Split every [ 2 ] pages`).
     - **Mode C: Extract All Pages** ("Extract all pages into individual single-page PDFs").
   - Action Button: "Split PDF" with loading spinner and progress state.
   - Download Result Card: Prominent button to download resulting `.pdf` or `.zip`.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_split.py`):
1. `test_parse_page_ranges_valid_syntax()`:
   - Validates `"1-3, 5"` on a 10-page document produces `[[0, 1, 2], [4]]`.
2. `test_parse_page_ranges_out_of_bounds_raises_error()`:
   - Validates `"1-15"` on a 10-page document raises validation error.
3. `test_split_single_range_returns_pdf()`:
   - Splits 5-page PDF with range `"2-3"` and asserts returned output has exactly 2 pages.
4. `test_split_multi_range_returns_zip_with_expected_files()`:
   - Splits 10-page PDF with range `"1-2, 5"` and verifies ZIP contains `Document_1-2.pdf` and `Document_5.pdf`.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_split_page_test.dart`):
1. `test_split_page_initial_upload_state()`:
   - Verifies upload dropzone renders with title "Split PDF".
2. `test_split_mode_selector_displays_range_field()`:
   - Verifies switching modes reveals custom range inputs.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_split.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_split_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Backend split engine supports custom ranges, fixed interval splitting, and 1-click all-page extraction.
- [ ] Automatic fallback to `.zip` when multiple files are generated.
- [ ] Flutter `/split` page with live range syntax validation and error feedback.
- [ ] 100% automated tests passing locally.
