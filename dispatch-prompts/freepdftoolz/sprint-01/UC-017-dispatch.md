# TASK DISPATCH: Implement UC-017 (Merge PDF Engine & Multi-File Drag-and-Drop Reorder UI)

> **Ticket:** `UC-017`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-017-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-017-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-017-pdf-merge` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** All PDF operations execute locally using PyMuPDF (`fitz`) and RAM disk / temporary disk; no paid external cloud APIs.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-017-merge-pdf-engine--multi-file-drag-and-drop-reorder-ui)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-017

**Ticket ID:** UC-017  
**Name:** Merge PDF Engine & Multi-File Drag-and-Drop Reorder UI  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/merge` and drops 2 or more PDF documents.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-017-pdf-merge` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-017-pdf-merge
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Merge Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_merge_service.py`:
   - Function `merge_pdfs(file_paths: list[Path], output_path: Path) -> dict`:
     - Instantiates target `fitz.open()`.
     - Iterates through input files in order, calls `merged_doc.insert_pdf(src_doc)`.
     - Saves with `deflate=True, garbage=3` for optimal file size.
     - Returns summary with `total_pages`, `output_bytes`, `page_counts_per_file`.
2. Create `src/backend/app/api/v1/endpoints/tools_merge.py`:
   - Endpoint `POST /api/v1/tools/merge`:
     - Receives `files: list[UploadFile]` as `multipart/form-data`.
     - Rejection: if `len(files) < 2`, returns HTTP 400 Bad Request (`"At least 2 PDF files are required to merge"`).
     - File validation: ensures content type is `application/pdf` or extension is `.pdf`.
     - Tier size validation: cumulative file size validated against canonical `app_limits_config.json` (`base_max_file_mb: 100`, expandable up to `max_stack_file_mb: 1024`). Returns HTTP 413 if exceeded.
     - Stream input files to temporary directory / RAM disk.
     - Execute merge with PyMuPDF.
     - Returns `FileResponse` with `application/pdf` and `Content-Disposition: attachment; filename="merged_document.pdf"`, or JSON job payload for streaming download.
     - Uses FastAPI `BackgroundTasks` to purge temporary input files immediately upon completion.
3. Register merge router in `src/backend/app/api/v1/router.py`.

#### Step 2: Canonical Limits & Action-Driven Navigation Architecture (`src/frontend/`)
1. **Canonical Limits Config (`AppLimitsConfig`):**
   - Sourced from `assets/config/app_limits_config.json` / `GET /api/v1/config` (identical to freeOCR.me).
   - Zero hardcoded limits anywhere in UI copy or validation.
   - Stackable limit boost: +50MB per 15s video ad up to 1,024MB (1-hour session window).
2. **Tool Landing Page (`/merge` in `src/frontend/lib/pages/pdf_merge_page.dart`):**
   - Displays header, tool description, and **Ad #1 (`AdSenseBanner()`)**.
   - Apple-grade multi-file dropzone with file picker support (`FilePicker.platform.pickFiles`).
   - **Action-Driven Navigation:** When a user takes an action (dropping a file or picking files):
     - Evaluates file size against `AppLimitsConfig.activeLimitMb`. If exceeded, pops `RewardedVideoAdModal`.
     - Once validated, **immediately navigates to `/merge/process`** passing selected files in route arguments. User does NOT stay on landing page.
3. **Status / Progress Page (`/merge/process` in `src/frontend/lib/pages/pdf_merge_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/merge/process', pageTitle: 'FreePDFToolz — Merging PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) configured with Google Ad Manager (GAM) 60-second declared auto-refresh**.
   - Visual `ReorderableListView`: drag handles, PDF icons, filenames, formatted sizes, and delete action.
   - "Add More Files" secondary button and primary "Merge PDFs" action button.
   - Real-time progress spinner / status messages during merge execution.
   - Success State / Result Card (with Ad #3): Prominent "Download Merged PDF" button, output size/page summary, and "Merge Another PDF" button.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_merge.py`):
1. `test_merge_rejects_less_than_two_files()`:
   - Calling `POST /api/v1/tools/merge` with 0 or 1 file returns HTTP 400 Bad Request.
2. `test_merge_combines_multiple_pdfs_correctly()`:
   - Creates 2 mock 2-page PDFs.
   - Posts to `/api/v1/tools/merge`.
   - Asserts HTTP 200 and returned PDF has exactly 4 pages.
3. `test_merge_preserves_custom_file_order()`:
   - Creates Doc A (marked "Page A") and Doc B (marked "Page B").
   - Posts in order `[Doc B, Doc A]`.
   - Inspects merged document text to verify Page B precedes Page A.
4. `test_merge_enforces_size_limit()`:
   - Mock cumulative size > 100MB without boost returns HTTP 413.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_merge_page_test.dart`):
1. `test_merge_page_renders_dropzone_initially()`:
   - Verify dropzone and helper copy "Merge PDF Files" are present.
2. `test_merge_button_disabled_when_under_two_files()`:
   - Verify "Merge PDFs" button is disabled or hidden when file count < 2.
3. `test_reorderable_list_displays_added_files()`:
   - Pump page with mock file state and verify filenames and drag tiles render.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_merge.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_merge_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] PyMuPDF merge backend engine tested and passing 100% of test cases.
- [ ] Multipart `/api/v1/tools/merge` endpoint live with cumulative size limits and temp-file auto-purge.
- [ ] Flutter `/merge` page features drag-and-drop file reordering, progress feedback, and instant download.
- [ ] All unit & widget tests passing locally without errors or warnings.
- [ ] Trackers updated (`master-tracker.md` -> `UC-017` marked Completed).
