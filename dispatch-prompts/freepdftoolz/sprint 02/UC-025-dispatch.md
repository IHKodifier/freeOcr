# TASK DISPATCH: Implement UC-025 (Crop PDF Engine & Visual Bounding Box Trimmer)

> **Ticket:** `UC-025`  
> **Sprint:** `Sprint F2` (FreePDFToolz Transformation, Optimization & Security)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 02/UC-025-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2002/UC-025-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-025-crop` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-025-crop-pdf-engine--visual-bounding-box-trimmer)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-025

**Ticket ID:** UC-025  
**Name:** Crop PDF Engine & Visual Bounding Box Trimmer  
**Epic:** Epic 7 (FreePDFToolz Transformation, Optimization & Security)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/crop` and uploads a PDF.  

### Preconditions
- [x] Sprint F1 merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-025-crop` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-025-crop
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment.

---

### Main Implementation Steps

#### Step 1: Backend Crop Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_crop_service.py`:
   - Function `crop_pdf(input_path: Path, output_path: Path, left: float = 0.0, top: float = 0.0, right: float = 0.0, bottom: float = 0.0, apply_to_all: bool = True, target_page: int = 0) -> Path`:
     - Opens input document with `fitz.open()`.
     - Validates margin bounds (margins must leave positive width and height).
     - Calculates new crop rectangle:
       `new_rect = fitz.Rect(page.rect.x0 + left, page.rect.y0 + top, page.rect.x1 - right, page.rect.y1 - bottom)`.
     - Sets `/CropBox` via `page.set_cropbox(new_rect)` on all pages or target page.
     - Saves document with `deflate=True`.
2. Create `src/backend/app/api/v1/endpoints/tools_crop.py`:
   - Endpoint `POST /api/v1/tools/crop`:
     - Accepts `file: UploadFile`, `left: float = Form(0.0)`, `top: float = Form(0.0)`, `right: float = Form(0.0)`, `bottom: float = Form(0.0)`, `apply_to_all: bool = Form(True)`.
     - Validates size limits against canonical `app_limits_config.json`.
     - Returns cropped PDF stream (`FileResponse`).
     - Cleans up ephemeral storage in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Architecture & Interactive Bounding Box Trimmer (`src/frontend/`)
1. **Tool Landing Page (`/crop` in `src/frontend/lib/pages/pdf_crop_page.dart`):**
   - Displays header, tool description, **Ad #1 (`AdSenseBanner()`)**, dropzone, dynamic limits badge.
   - Action-driven navigation: immediately routes to `/crop/process` on file selection.
2. **Workspace Page (`/crop/process` in `src/frontend/lib/pages/pdf_crop_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/crop/process', pageTitle: 'FreePDFToolz — Crop PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) with GAM 60s auto-refresh**.
   - Interactive Crop Configurator:
     - Margin inputs / sliders (Top, Bottom, Left, Right in points or percentage).
     - Margin preset chips: "Zero Margins", "Auto Trim 10%", "Standard 0.5in (36pt)", "Wide 1.0in (72pt)".
     - Scope switch: "Apply to All Pages" vs "Current Page Only".
     - **Interactive Live Preview Box**: Simulated document page with visual crop overlay rectangle indicating the cropped viewport.
   - Primary Action: "Crop PDF" button with loading spinner.
   - Download Result Card with Ad #3.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_crop.py`):
1. `test_crop_pdf_applies_new_cropbox_dimensions()`:
   - Crops 36pt from all sides; asserts output page cropbox rect equals expected dimensions.
2. `test_crop_pdf_excessive_margins_raises_value_error()`:
   - Margins greater than page dimensions raise `ValueError`.
3. `test_crop_pdf_single_page_vs_all_pages()`:
   - Applying crop to single page modifies target page while leaving other pages unaltered.
4. `test_crop_endpoint_success()`:
   - Asserts `POST /api/v1/tools/crop` returns HTTP 200 and valid PDF stream.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_crop_page_test.dart`):
1. `test_crop_page_renders_dropzone()`:
   - Verifies landing page renders with title "Crop PDF" and Ad #1.
2. `test_crop_progress_page_renders_margin_inputs()`:
   - Verifies margin controls and live preview box render.
3. `test_selecting_crop_preset_updates_inputs()`:
   - Verifies tapping a preset updates the margin state.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_crop.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_crop_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] PyMuPDF cropbox engine updating page `/CropBox` without deleting vectors.
- [ ] Margin bounds validation preventing inverted rects.
- [ ] Interactive live document preview showing crop bounding overlay.
- [ ] 100% automated tests passing locally.
