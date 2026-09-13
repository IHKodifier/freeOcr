# TASK DISPATCH: Implement UC-022 (Number Pages Engine & Position/Format Selector UI)

> **Ticket:** `UC-022`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-022-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-022-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-022-number-pages` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-022-number-pages-engine--positionformat-selector-ui)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-022

**Ticket ID:** UC-022  
**Name:** Number Pages Engine & Position/Format Selector UI  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/number-pages` and uploads a PDF.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-022-number-pages` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-022-number-pages
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Numbering Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_number_pages_service.py`:
   - Function `number_pdf_pages(input_path: Path, output_path: Path, position: str, format_str: str, skip_first_page: bool, start_number: int, font_size: float = 10.0) -> dict`:
     - Opens input document with `fitz.open()`.
     - Supports positions: `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`.
     - Dynamically computes coordinate offsets based on `page.rect.width` and `page.rect.height`.
     - Replaces `{n}` with active index and `{total}` with total page count.
     - If `skip_first_page=True`, skips page index 0 and starts numbering on page 1.
     - Calls `page.insert_textbox(...)` or `page.insert_text(...)` with clean Helvetica font.
     - Saves document with `deflate=True`.
2. Create `src/backend/app/api/v1/endpoints/tools_number_pages.py`:
   - Endpoint `POST /api/v1/tools/number-pages`:
     - Accepts `file: UploadFile`, `position: str`, `format: str`, `skip_cover: bool = False`, `start_page: int = 1`, `font_size: float = 10.0`.
     - Returns numbered PDF stream (`FileResponse`).
     - Cleans up temporary files in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Number Pages UI (`src/frontend/lib/pages/pdf_number_pages_page.dart`)
1. Replace placeholder route for `/number-pages` with dedicated `PdfNumberPagesPage`:
   - Upload dropzone for a single PDF.
   - Interactive Numbering Configurator:
     - **3x3 Position Grid Selector**: Interactive visual matrix with 6 selectable placement anchors (Top: L, C, R; Bottom: L, C, R).
     - **Format Selector**: Segmented buttons or dropdown (`Page {n} of {total}`, `{n}`, `Page {n}`, `- {n} -`).
     - **Cover Page Toggle**: Switch for "Skip First Page / Cover Page".
     - **Live Document Preview Box**: Simulated page showing where the number will appear based on selected position and format.
   - Action Button: "Apply Page Numbers & Download".

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_number_pages.py`):
1. `test_number_pages_bottom_center_inserts_text()`:
   - Numbers a 3-page document with `bottom-center` and format `"Page {n} of {total}"`.
   - Inspects page text via `page.get_text()` to verify `"Page 1 of 3"` is present.
2. `test_skip_cover_page_leaves_first_page_untouched()`:
   - Numbers with `skip_cover=True`; asserts page 0 contains no page number string while page 1 contains number.
3. `test_number_pages_respects_custom_start_index()`:
   - Starting at 5 on a 2-page document produces `"Page 5 of 6"` and `"Page 6 of 6"`.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_number_pages_page_test.dart`):
1. `test_number_pages_page_renders_dropzone()`:
   - Verifies dropzone renders with title "Number PDF Pages".
2. `test_position_grid_selection_updates_preview()`:
   - Verifies selecting "Top-Right" updates the active position state.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_number_pages.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_number_pages_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Backend numbering engine supports 6 positions and variable template formatting (`{n}`, `{total}`).
- [ ] Cover page skipping logic tested and verified.
- [ ] Flutter interactive 3x3 position selector with instant preview update.
- [ ] 100% automated tests passing locally.
