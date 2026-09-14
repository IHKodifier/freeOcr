# TASK DISPATCH: Implement UC-024 (Watermark PDF Engine & Text/Image Overlay UI)

> **Ticket:** `UC-024`  
> **Sprint:** `Sprint F2` (FreePDFToolz Transformation, Optimization & Security)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 02/UC-024-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2002/UC-024-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-024-watermark` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-024-watermark-pdf-engine-text-angleopacity--image-logo-overlay)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-024

**Ticket ID:** UC-024  
**Name:** Watermark PDF Engine (Text Angle/Opacity & Image Logo Overlay)  
**Epic:** Epic 7 (FreePDFToolz Transformation, Optimization & Security)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/watermark` and uploads a PDF.  

### Preconditions
- [x] Sprint F1 merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-024-watermark` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-024-watermark
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment.

---

### Main Implementation Steps

#### Step 1: Backend Watermark Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_watermark_service.py`:
   - Function `watermark_pdf(input_path: Path, output_path: Path, watermark_type: str = "text", text: str = "CONFIDENTIAL", image_path: Optional[Path] = None, rotation: float = -45.0, opacity: float = 0.3, font_size: float = 48.0, position: str = "center") -> Path`:
     - Text mode: Calculates page center coordinates, draws text with specified rotation angle and `fill_opacity=opacity` without obscuring or modifying underlying text/vector streams.
     - Image mode: Reads transparent PNG/JPG logo, resizes proportionally, and overlays at page center or specified rect with alpha channel preservation.
     - Iterates across all pages in document.
     - Saves document with `deflate=True`.
2. Create `src/backend/app/api/v1/endpoints/tools_watermark.py`:
   - Endpoint `POST /api/v1/tools/watermark`:
     - Accepts `file: UploadFile`, `watermark_type: str = Form("text")`, `text: Optional[str] = Form("CONFIDENTIAL")`, `image: Optional[UploadFile] = None`, `rotation: float = Form(-45.0)`, `opacity: float = Form(0.3)`, `font_size: float = Form(48.0)`.
     - Validates PDF format, file size limits against `app_limits_config.json`.
     - Returns watermarked PDF stream (`FileResponse`).
     - Cleans up ephemeral storage in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Architecture & Interactive Watermark Workspace (`src/frontend/`)
1. **Tool Landing Page (`/watermark` in `src/frontend/lib/pages/pdf_watermark_page.dart`):**
   - Displays header, description, **Ad #1 (`AdSenseBanner()`)**, dropzone, dynamic limits badge.
   - Action-driven navigation: routes immediately to `/watermark/process` on file selection.
2. **Workspace Page (`/watermark/process` in `src/frontend/lib/pages/pdf_watermark_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/watermark/process', pageTitle: 'FreePDFToolz — Watermark PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) with GAM 60s auto-refresh**.
   - Interactive Watermark Configurator:
     - **Type Switcher**: Text Watermark vs Image Logo.
     - For Text: Preset buttons ("CONFIDENTIAL", "DRAFT", "DO NOT COPY", "SAMPLE"), custom text field, angle selector (-45°, 0°, 45°), opacity slider (10% - 100%), font size controls.
     - For Image: Logo image picker with thumbnail preview and scale slider.
     - **Live Document Preview**: Interactive miniature page displaying real-time watermark angle and alpha transparency.
   - Primary Action: "Apply Watermark" with loading spinner.
   - Download Result Card with Ad #3.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_watermark.py`):
1. `test_watermark_text_inserts_overlay()`:
   - Asserts watermarked document contains watermark text string in `page.get_text()`.
2. `test_watermark_preserves_underlying_text()`:
   - Verifies original text on page 1 remains fully searchable and intact.
3. `test_watermark_image_png_preserves_alpha()`:
   - Overlays a transparent PNG onto PDF; verifies page rendering succeeds without errors.
4. `test_watermark_endpoint_invalid_type_returns_400()`:
   - Uploading unsupported watermark type returns HTTP 400.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_watermark_page_test.dart`):
1. `test_watermark_page_renders_dropzone()`:
   - Verifies title "Watermark PDF" and dropzone render.
2. `test_watermark_progress_page_renders_controls()`:
   - Verifies text preset buttons, opacity slider, and live preview box render.
3. `test_typing_custom_text_updates_preview()`:
   - Verifies typing custom text updates the live preview text widget.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_watermark.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_watermark_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] Text watermark engine with configurable rotation (-45°, 0°, 45°) and alpha opacity (10%–100%).
- [ ] Image logo overlay engine with PNG transparency support.
- [ ] Live preview box dynamically mirroring angle and opacity changes.
- [ ] 100% automated tests passing locally.
