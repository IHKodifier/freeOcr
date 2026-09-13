# TASK DISPATCH: Implement UC-020 (Delete Pages Engine & Visual Page Deletion Grid)

> **Ticket:** `UC-020`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-020-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-020-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-020-delete-pages` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-020-delete-pages-engine--visual-page-deletion-grid)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-020

**Ticket ID:** UC-020  
**Name:** Delete Pages Engine & Visual Page Deletion Grid  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/delete-pages` and uploads a PDF.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-020-delete-pages` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-020-delete-pages
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Delete Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_delete_pages_service.py`:
   - Function `delete_pdf_pages(input_path: Path, output_path: Path, pages_to_delete: list[int]) -> dict`:
     - Opens input document with `fitz.open()`.
     - Validates page count: if `len(set(pages_to_delete)) >= len(doc)`, raises `ValueError("Cannot delete all pages from a PDF")`.
     - Sorts `pages_to_delete` in descending order to prevent index shift during sequential deletion, or uses PyMuPDF `doc.delete_pages(pages_to_delete)`.
     - Saves document with `deflate=True, garbage=3`.
     - Returns summary with `remaining_pages` count.
2. Create `src/backend/app/api/v1/endpoints/tools_delete_pages.py`:
   - Endpoint `POST /api/v1/tools/delete-pages`:
     - Validates PDF format and file size limit against canonical `app_limits_config.json` (`base_max_file_mb: 100`, expandable to `max_stack_file_mb: 1024` with session boost).
     - Returns HTTP 400 Bad Request if user requests deletion of all pages in the PDF.
     - Returns pruned PDF stream (`FileResponse`).
     - Cleans up temporary files in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Canonical Limits & Action-Driven Navigation Architecture (`src/frontend/`)
1. **Canonical Limits Config (`AppLimitsConfig`):**
   - Sourced from `assets/config/app_limits_config.json` / `GET /api/v1/config` (identical to freeOCR.me).
   - Zero hardcoded limits anywhere in UI copy or validation.
   - Stackable limit boost: +50MB per 15s video ad up to 1,024MB (1-hour session window).
2. **Tool Landing Page (`/delete-pages` in `src/frontend/lib/pages/pdf_delete_pages_page.dart`):**
   - Displays header, tool description, and **Ad #1 (`AdSenseBanner()`)**.
   - Apple-grade dropzone with file picker button.
   - **Action-Driven Navigation:** When user drops a PDF or picks a file:
     - Evaluates file size against `AppLimitsConfig.activeLimitMb`. If exceeded, pops `RewardedVideoAdModal`.
     - Once validated, **immediately navigates to `/delete-pages/process`** passing the selected file in route arguments. User does NOT stay on landing page.
3. **Status / Progress Page (`/delete-pages/process` in `src/frontend/lib/pages/pdf_delete_pages_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/delete-pages/process', pageTitle: 'FreePDFToolz — Delete Pages')`.
   - Displays **Ad #2 (`AdSenseBanner()`) configured with Google Ad Manager (GAM) 60-second declared auto-refresh**.
   - Page Selection Grid:
     - Visual thumbnail cards showing page number badge.
     - Hover red trash icon.
     - Tapping a card toggles deleted state:
       - Displays red "DELETE" overlay tag.
       - Dimmed opacity (0.4) and red border.
   - Status Bar:
     - E.g. "Selected 2 of 8 pages to remove (6 pages will remain)".
     - Guard: disables action button if all pages are selected with warning text: "A PDF must retain at least one page."
   - Primary Action: "Delete Pages & Generate PDF" button with live progress spinner.
   - Download Result Card (with Ad #3): Prominent button to download pruned PDF and "Delete More Pages" reset button.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_delete_pages.py`):
1. `test_delete_pages_rejects_100_percent_deletion_with_400()`:
   - Requesting deletion of pages `[0, 1]` on a 2-page document returns HTTP 400 Bad Request.
2. `test_delete_pages_removes_specified_pages_accurately()`:
   - Creates a 5-page document, deletes pages `[1, 3]`, verifies output document has exactly 3 pages.
3. `test_delete_pages_handles_duplicate_indices_gracefully()`:
   - Passing `[1, 1, 2]` deduplicates indices and produces clean result.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_delete_pages_page_test.dart`):
1. `test_delete_page_renders_dropzone()`:
   - Verifies dropzone renders with title "Delete PDF Pages".
2. `test_selecting_all_pages_disables_delete_button()`:
   - Simulates selecting all page cards and asserts action button is disabled.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_delete_pages.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_delete_pages_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Backend deletion service protects against empty PDF output (HTTP 400).
- [ ] PyMuPDF reverse index deletion ensures page index integrity.
- [ ] Flutter interactive deletion grid with visual badge toggles and guard messaging.
- [ ] 100% automated tests passing locally.
