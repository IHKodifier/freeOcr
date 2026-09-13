# TASK DISPATCH: Implement UC-019 (Rotate PDF Engine & Visual Page Rotation Grid)

> **Ticket:** `UC-019`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-019-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-019-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-019-pdf-rotate` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-019-rotate-pdf-engine--visual-page-rotation-grid)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-019

**Ticket ID:** UC-019  
**Name:** Rotate PDF Engine & Visual Page Rotation Grid  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/rotate` and uploads a PDF.  

### Preconditions
- [x] UC-016 (Routing Hub & Navigation Shell) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-019-pdf-rotate` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-019-pdf-rotate
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Rotate Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_rotate_service.py`:
   - Function `rotate_pdf_pages(input_path: Path, output_path: Path, rotations: dict[int, int]) -> dict`:
     - Opens input document with `fitz.open()`.
     - Applies `page.set_rotation((page.rotation + angle) % 360)` for each entry in `rotations` (`{page_index: angle}`).
     - Saves document with `deflate=True`.
     - Returns summary of modified pages.
2. Create `src/backend/app/api/v1/endpoints/tools_rotate.py`:
   - Endpoint `POST /api/v1/tools/rotate`:
     - Receives `file: UploadFile`, `rotations_json: str` (or form field with JSON mapping e.g. `{"0": 90, "1": 180}`).
     - Validates PDF format and file size limit against canonical `app_limits_config.json` (`base_max_file_mb: 100`, expandable to `max_stack_file_mb: 1024` with session boost).
     - Returns modified PDF stream (`FileResponse`).
     - Cleans up temporary files in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Canonical Limits & Action-Driven Navigation Architecture (`src/frontend/`)
1. **Canonical Limits Config (`AppLimitsConfig`):**
   - Sourced from `assets/config/app_limits_config.json` / `GET /api/v1/config` (identical to freeOCR.me).
   - Zero hardcoded limits anywhere in UI copy or validation.
   - Stackable limit boost: +50MB per 15s video ad up to 1,024MB (1-hour session window).
2. **Tool Landing Page (`/rotate` in `src/frontend/lib/pages/pdf_rotate_page.dart`):**
   - Displays header, tool description, and **Ad #1 (`AdSenseBanner()`)**.
   - Apple-grade dropzone with file picker button.
   - **Action-Driven Navigation:** When user drops a PDF or picks a file:
     - Evaluates file size against `AppLimitsConfig.activeLimitMb`. If exceeded, pops `RewardedVideoAdModal`.
     - Once validated, **immediately navigates to `/rotate/process`** passing the selected file in route arguments. User does NOT stay on landing page.
3. **Status / Progress Page (`/rotate/process` in `src/frontend/lib/pages/pdf_rotate_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/rotate/process', pageTitle: 'FreePDFToolz — Rotate PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) configured with Google Ad Manager (GAM) 60-second declared auto-refresh**.
   - Page Preview Grid:
     - Displays page thumbnail cards with page number badge (`Page 1`, `Page 2`...).
     - Individual rotate buttons on each card: Rotate Left (-90°) and Rotate Right (+90°).
     - Animated thumbnail rotation (Flutter `AnimatedRotation`) providing instant visual feedback.
   - Global Toolbar: "Rotate All Right (90°)", "Rotate All Left (-90°)", "Reset".
   - Primary Action: "Save and Apply Rotation" button with live progress spinner.
   - Download Result Card (with Ad #3): Prominent button to download modified PDF and "Rotate Another PDF" reset button.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_rotate.py`):
1. `test_rotate_page_applies_90_degree_rotation()`:
   - Sets page 0 to 90 degrees, verifies `page.rotation == 90` in output PDF.
2. `test_rotate_multiple_distinct_pages()`:
   - Sets page 0 to 90° and page 1 to 180°, asserts both rotation values match.
3. `test_rotate_invalid_angle_returns_422()`:
   - Submitting an angle of 45° returns HTTP 422 Unprocessable Entity.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_rotate_page_test.dart`):
1. `test_rotate_page_renders_dropzone()`:
   - Verifies dropzone renders with title "Rotate PDF".
2. `test_rotate_card_controls_trigger_angle_updates()`:
   - Verifies tapping individual page rotate buttons updates rotation state.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_rotate.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_rotate_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Backend rotation engine applies standard 90/180/270 degree transformations via PyMuPDF dictionary properties.
- [ ] Responsive grid UI in Flutter with visual card rotation feedback and global toolbar.
- [ ] 100% automated tests passing locally.
