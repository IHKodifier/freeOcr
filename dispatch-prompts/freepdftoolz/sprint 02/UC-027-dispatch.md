# TASK DISPATCH: Implement UC-027 (Sign PDF Engine & Flutter Signature Canvas Pad)

> **Ticket:** `UC-027`  
> **Sprint:** `Sprint F2` (FreePDFToolz Transformation, Optimization & Security)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 02/UC-027-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2002/UC-027-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-027-sign` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-027-sign-pdf-engine--flutter-signature-canvas-pad)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-027

**Ticket ID:** UC-027  
**Name:** Sign PDF Engine & Flutter Signature Canvas Pad  
**Epic:** Epic 7 (FreePDFToolz Transformation, Optimization & Security)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/sign` and uploads a PDF.  

### Preconditions
- [x] Sprint F1 merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-027-sign` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-027-sign
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment.

---

### Main Implementation Steps

#### Step 1: Backend Signature Stamping Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_sign_service.py`:
   - Function `sign_pdf(input_path: Path, output_path: Path, signature_bytes: bytes, target_page: int, x: float, y: float, width: float, height: float) -> Path`:
     - Opens document with `fitz.open()`.
     - Validates `0 <= target_page < len(doc)`.
     - Calculates target rectangle: `rect = fitz.Rect(x, y, x + width, y + height)`.
     - Inserts signature image stream onto target page with `page.insert_image(rect, stream=signature_bytes, keep_proportion=True)`.
     - Preserves transparent alpha background without corrupting underlying page content.
     - Leaves all non-target pages completely untouched.
     - Saves document with `deflate=True`.
2. Create `src/backend/app/api/v1/endpoints/tools_sign.py`:
   - Endpoint `POST /api/v1/tools/sign`:
     - Accepts `file: UploadFile`, `signature: UploadFile`, `page: int = Form(1)`, `x: float = Form(...)`, `y: float = Form(...)`, `width: float = Form(...)`, `height: float = Form(...)`.
     - Validates PDF format, signature PNG format, and size limits against `app_limits_config.json`.
     - Returns signed PDF stream (`FileResponse`).
     - Cleans up ephemeral storage in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Architecture & Signature Canvas Pad (`src/frontend/`)
1. **Tool Landing Page (`/sign` in `src/frontend/lib/pages/pdf_sign_page.dart`):**
   - Displays header, description, **Ad #1 (`AdSenseBanner()`)**, dropzone, dynamic limits badge.
   - Action-driven navigation: immediately routes to `/sign/process` on file selection.
2. **Workspace Page (`/sign/process` in `src/frontend/lib/pages/pdf_sign_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/sign/process', pageTitle: 'FreePDFToolz — Sign PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) with GAM 60s auto-refresh**.
   - Interactive Signature Workflow:
     - **Signature Pad Modal**:
       - *Draw*: Interactive touch/mouse drawing pad with stroke smoothing, Clear, and Confirm buttons.
       - *Type*: Text field rendering handwritten script signatures in multiple styles.
       - *Upload*: File picker for pre-existing PNG signature scans.
     - **Placement Workspace**:
       - Page selector: Browse pages to choose which page to sign.
       - Position selector / draggable signature stamp over miniature document preview.
       - Scale / size slider for signature dimensions.
   - Primary Action: "Apply Signature" button with loading spinner.
   - Download Result Card with Ad #3.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_sign.py`):
1. `test_sign_pdf_inserts_signature_on_target_page()`:
   - Stamps signature PNG on page 1 of 3; asserts page 1 contains the image while page 0 and page 2 remain untouched.
2. `test_sign_pdf_preserves_transparent_background()`:
   - Verifies transparent PNG stamps without black background bounding box artifacts.
3. `test_sign_pdf_out_of_bounds_page_raises_value_error()`:
   - Stamping on page 99 of 2-page document raises `ValueError`.
4. `test_sign_endpoint_success()`:
   - Asserts `POST /api/v1/tools/sign` returns HTTP 200 and valid PDF stream.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_sign_page_test.dart`):
1. `test_sign_page_renders_dropzone()`:
   - Verifies landing page renders with title "Sign PDF" and Ad #1.
2. `test_sign_progress_page_renders_signature_options()`:
   - Verifies "Create Signature" button and placement preview render.
3. `test_signature_modal_switches_tabs()`:
   - Verifies switching between Draw, Type, and Upload tabs.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_sign.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_sign_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] PyMuPDF image stamping engine with transparent PNG alpha support.
- [ ] Multi-page target selection ensuring signature is placed strictly on requested page.
- [ ] Signature creation modal (Draw canvas pad, Type script font, Upload file).
- [ ] 100% automated tests passing locally.
