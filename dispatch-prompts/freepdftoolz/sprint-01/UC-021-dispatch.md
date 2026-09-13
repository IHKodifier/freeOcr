# TASK DISPATCH: Implement UC-021 (Extract Pages Engine & Multi-Page Extractor UI)

> **Ticket:** `UC-021`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-021-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-021-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-021-extract-pages` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-021-extract-pages-engine--multi-page-extractor-ui)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-021

**Ticket ID:** UC-021  
**Name:** Extract Pages Engine & Multi-Page Extractor UI  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/extract-pages` and uploads a PDF.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-021-extract-pages` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-021-extract-pages
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Extract Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_extract_pages_service.py`:
   - Function `extract_pdf_pages(input_path: Path, pages_to_extract: list[int], mode: str, output_dir: Path) -> Path`:
     - Mode `"merged"`: Opens input document, runs `doc.select(pages_to_extract)`, saves to `extracted.pdf`.
     - Mode `"separate"`: Creates individual single-page PDF files for each extracted page, packages into `extracted_pages.zip`.
     - Validates page indices are in range `1 <= p <= doc.page_count`.
2. Create `src/backend/app/api/v1/endpoints/tools_extract_pages.py`:
   - Endpoint `POST /api/v1/tools/extract-pages`:
     - Accepts `file: UploadFile`, `pages: str` (e.g. `"1, 3, 5"` or range `"2-4"`), `output_mode: str` (`"merged"` or `"separate"`).
     - Returns PDF (`FileResponse` as `.pdf`) or ZIP archive (`FileResponse` as `.zip`).
     - Cleans up temporary files in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Extraction UI (`src/frontend/lib/pages/pdf_extract_pages_page.dart`)
1. Replace placeholder route for `/extract-pages` with dedicated `PdfExtractPagesPage`:
   - Upload dropzone for a single PDF.
   - Interactive Page Selector:
     - Checkbox thumbnail cards with page number badge.
     - Quick selection buttons: "Select All", "Deselect All", "Even Pages", "Odd Pages".
     - Text field fallback: "Or enter pages manually (e.g. 1, 3-5)".
   - Output Mode Segmented Control:
     - "Merge into one PDF"
     - "Extract into separate PDFs (ZIP)"
   - Action Button: "Extract Pages" with download trigger.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_extract_pages.py`):
1. `test_extract_pages_merged_produces_correct_page_count()`:
   - Extract pages `[1, 3]` from 5-page PDF into single PDF; asserts output has exactly 2 pages.
2. `test_extract_pages_separate_produces_zip()`:
   - Extract pages `[1, 3]` with mode `"separate"`; asserts ZIP contains 2 PDF files.
3. `test_extract_invalid_pages_returns_422()`:
   - Requesting page 99 on a 3-page document returns HTTP 422.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_extract_pages_page_test.dart`):
1. `test_extract_page_renders_dropzone()`:
   - Verifies dropzone renders with title "Extract PDF Pages".
2. `test_quick_select_even_pages_toggles_checkboxes()`:
   - Verifies tapping "Even Pages" selects pages 2, 4, etc.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_extract_pages.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_extract_pages_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Backend extraction engine supports both single merged PDF and multi-file ZIP modes.
- [ ] Quick selection presets (All, None, Even, Odd) + visual thumbnail toggles.
- [ ] 100% automated tests passing locally.
