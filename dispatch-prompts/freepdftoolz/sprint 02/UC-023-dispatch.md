# TASK DISPATCH: Implement UC-023 (Compress PDF Engine & Compression Level Selector UI)

> **Ticket:** `UC-023`  
> **Sprint:** `Sprint F2` (FreePDFToolz Transformation, Optimization & Security)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 02/UC-023-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2002/UC-023-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-023-compress` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF / pikepdf execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-023-compress-pdf-engine-stream-optimization--dpi-downsampling)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-023

**Ticket ID:** UC-023  
**Name:** Compress PDF Engine (Stream Optimization & DPI Downsampling)  
**Epic:** Epic 7 (FreePDFToolz Transformation, Optimization & Security)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/compress` and uploads a PDF.  

### Preconditions
- [x] Sprint F1 (UC-016 through UC-022) completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-023-compress` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-023-compress
  ```
- [x] PyMuPDF (`fitz`) and `pikepdf` / `Pillow` available in backend environment (`C:\python31315\python.exe`).

---

### Main Implementation Steps

#### Step 1: Backend Compression Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_compress_service.py`:
   - Function `compress_pdf(input_path: Path, output_path: Path, level: str = "recommended") -> dict`:
     - Opens input PDF document using `fitz.open()`.
     - Supports 3 compression presets:
       - `recommended` (Default): Downsamples embedded images to 150 DPI with JPEG quality 75, deflates streams, deduplicates font/image objects (`garbage=4, deflate=True`).
       - `extreme`: Downsamples images to 72 DPI with JPEG quality 50, aggressive stream optimization and font subset cleaning.
       - `low` (Lossless): Zero image downsampling; removes unused objects, duplicate streams, and applies maximum deflate (`garbage=4, deflate=True`).
     - Calculates byte metrics: `original_size`, `compressed_size`, `saved_bytes`, `percent_saved`.
     - Guard: If compressed file size ends up larger than original (e.g. on already compressed files), safely retains the smaller original bytes.
     - Saves compressed document with `deflate=True, garbage=4`.
     - Returns metrics dictionary.
2. Create `src/backend/app/api/v1/endpoints/tools_compress.py`:
   - Endpoint `POST /api/v1/tools/compress`:
     - Accepts `file: UploadFile`, `level: str = Form("recommended")`.
     - Validates PDF format and file size against canonical `app_limits_config.json`.
     - Returns compressed PDF stream (`FileResponse`) with custom response headers:
       - `X-Original-Size`: original byte count
       - `X-Compressed-Size`: compressed byte count
       - `X-Percent-Saved`: percentage saved (e.g. `45.2`)
     - Cleans up temporary directory in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Canonical Limits & Action-Driven Navigation Architecture (`src/frontend/`)
1. **Canonical Limits Config (`AppLimitsConfig`):**
   - Sourced from `assets/config/app_limits_config.json` / `GET /api/v1/config`. Zero hardcoded limits.
   - Stackable limit boost: +50MB per 15s video ad up to 1,024MB.
2. **Tool Landing Page (`/compress` in `src/frontend/lib/pages/pdf_compress_page.dart`):**
   - Displays header, tool description, and **Ad #1 (`AdSenseBanner()`)**.
   - Apple-grade dropzone with file picker button.
   - **Action-Driven Navigation:** On file drop/selection, validates size and immediately routes to `/compress/process`.
   - Comprehensive feature highlights and FAQ section below the fold.
3. **Status / Progress Page (`/compress/process` in `src/frontend/lib/pages/pdf_compress_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/compress/process', pageTitle: 'FreePDFToolz — Compress PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) with Google Ad Manager (GAM) 60-second auto-refresh**.
   - Document overview card (Filename, page count, original file size).
   - Interactive Compression Configurator:
     - **Compression Level Cards (3 selectable presets)**:
       - *Recommended Compression* (Good quality, high compression — 150 DPI) [Default].
       - *Extreme Compression* (Smallest size, lower image quality — 72 DPI).
       - *Low / Lossless Compression* (Best quality, cleans metadata & streams — Original DPI).
     - Visual badge indicating recommended option.
   - Primary Action: "Compress PDF" button with live progress indicator.
   - **Results Comparison Banner**: Displays original size, compressed size, and percentage saved (e.g. *"Compressed from 12.4 MB to 3.2 MB (-74%)"*).
   - Download Result Card (with Ad #3): Prominent button to download compressed PDF and "Compress Another PDF" reset button.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_compress.py`):
1. `test_compress_pdf_recommended_reduces_size()`:
   - Compresses a test PDF containing raster images; asserts `compressed_size <= original_size`.
2. `test_compress_pdf_extreme_dpi_downsampling()`:
   - Verifies extreme compression produces smaller or equal byte size compared to recommended.
3. `test_compress_pdf_lossless_preserves_images()`:
   - Verifies lossless mode compresses streams without corrupting text or structure.
4. `test_compress_endpoint_returns_metrics_headers()`:
   - Asserts `POST /api/v1/tools/compress` returns HTTP 200, `application/pdf`, and custom `X-Original-Size` headers.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_compress_page_test.dart`):
1. `test_compress_page_renders_dropzone()`:
   - Verifies landing page renders with title "Compress PDF" and Ad #1.
2. `test_compress_progress_page_renders_presets()`:
   - Verifies level selector renders Recommended, Extreme, and Low presets.
3. `test_selecting_preset_updates_active_state()`:
   - Verifies tapping Extreme compression highlights the card.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_compress.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_compress_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] PyMuPDF compression engine supporting 3 levels (Recommended, Extreme, Low/Lossless).
- [ ] Byte size guard ensuring output is never larger than original.
- [ ] Compression comparison banner showing MB saved and percentage reduction.
- [ ] 100% automated tests passing locally.
