# TASK DISPATCH: Implement UC-026 (Redact PDF Engine & Glyph Sanitization UI)

> **Ticket:** `UC-026`  
> **Sprint:** `Sprint F2` (FreePDFToolz Transformation, Optimization & Security)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 02/UC-026-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2002/UC-026-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-026-redact` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** Local PyMuPDF execution; zero paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-026-redact-pdf-engine-true-cryptographic-glyph-sanitization)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-026

**Ticket ID:** UC-026  
**Name:** Redact PDF Engine (True Cryptographic Glyph Sanitization)  
**Epic:** Epic 7 (FreePDFToolz Transformation, Optimization & Security)  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User navigates to `/redact` and uploads a PDF.  

### Preconditions
- [x] Sprint F1 merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-026-redact` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-026-redact
  ```
- [x] PyMuPDF (`fitz`) installed in backend environment.

---

### Main Implementation Steps

#### Step 1: Backend Redaction Service & Endpoint (`src/backend/app/`)
1. Create `src/backend/app/services/pdf_redact_service.py`:
   - Function `redact_pdf(input_path: Path, output_path: Path, search_phrase: Optional[str] = None, rects: Optional[list[dict]] = None) -> dict`:
     - Opens input document with `fitz.open()`.
     - Text phrase redaction: searches for `search_phrase` on each page (`page.search_for(search_phrase)`), adds redaction annotations (`page.add_redact_annot(rect, fill=(0, 0, 0))`).
     - Coordinate rect redaction: for each rect in `rects` (specifying `page_index` and `[x0, y0, x1, y1]`), adds redaction annotation.
     - Calls `page.apply_redactions(images=fitz.PDF_REDACT_IMAGE_PIXELS)`.
     - **True Cryptographic Sanitization:** Verifies underlying text glyphs and raster pixels are completely scrubbed from the PDF stream, not merely hidden behind a black box.
     - Saves document with `deflate=True, garbage=4`.
     - Returns summary dictionary with redaction count.
2. Create `src/backend/app/api/v1/endpoints/tools_redact.py`:
   - Endpoint `POST /api/v1/tools/redact`:
     - Accepts `file: UploadFile`, `search_phrase: Optional[str] = Form(None)`, `rects_json: Optional[str] = Form(None)`.
     - Validates at least one redaction target is specified.
     - Validates size limits against canonical `app_limits_config.json`.
     - Returns sanitized PDF stream (`FileResponse`).
     - Cleans up ephemeral storage in background.
3. Register router in `src/backend/app/api/v1/router.py`.

#### Step 2: Frontend Architecture & Interactive Redaction Workspace (`src/frontend/`)
1. **Tool Landing Page (`/redact` in `src/frontend/lib/pages/pdf_redact_page.dart`):**
   - Displays header, tool description, **Ad #1 (`AdSenseBanner()`)**, dropzone, dynamic limits badge.
   - Action-driven navigation: immediately routes to `/redact/process` on file selection.
   - Educational notice regarding true cryptographic redaction vs superficial black highlighter overlays.
2. **Workspace Page (`/redact/process` in `src/frontend/lib/pages/pdf_redact_progress_page.dart`):**
   - Telemetry: `TelemetryService.trackPageView('/redact/process', pageTitle: 'FreePDFToolz — Redact PDF')`.
   - Displays **Ad #2 (`AdSenseBanner()`) with GAM 60s auto-refresh**.
   - Interactive Redaction Configurator:
     - **Search & Redact Bar**: Text input to sanitize all occurrences of names, SSNs, credit card numbers, or keywords.
     - Case sensitivity toggle: Match exact case vs case-insensitive.
     - **Security Guarantee Card**: Visual shield banner verifying cryptographic glyph purge.
     - **Live Document Preview**: Page preview highlighting matching phrases with black redaction bars.
   - Primary Action: "Sanitize & Redact PDF" button with loading spinner.
   - Download Result Card with Ad #3.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/test_tools_redact.py`):
1. `test_redact_text_phrase_purges_glyphs()`:
   - Redacts "CONFIDENTIAL_KEY" from a 2-page document; asserts `page.get_text()` returns 0 matches.
2. `test_redact_preserves_unrelated_text()`:
   - Asserts non-redacted text on the same page remains intact and readable.
3. `test_redact_rect_coordinates_applies_black_box()`:
   - Redacts a specific coordinate box; asserts redaction annotation was applied and executed.
4. `test_redact_no_targets_returns_400()`:
   - Submitting without search phrase or rects returns HTTP 400 Bad Request.

### Frontend Widget Tests (`src/frontend/test/pages/pdf_redact_page_test.dart`):
1. `test_redact_page_renders_dropzone()`:
   - Verifies landing page renders with title "Redact PDF" and Ad #1.
2. `test_redact_progress_page_renders_search_bar()`:
   - Verifies search & redact input and security shield notice render.
3. `test_entering_search_phrase_updates_state()`:
   - Verifies entering a phrase enables the redact button.

---

## 5. Verification Commands
```bash
# 1. Run Backend Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_tools_redact.py -v

# 2. Run Frontend Flutter Test Suite
cd src/frontend
flutter test test/pages/pdf_redact_page_test.dart
```

---

## 6. Definition of Done (DoD)
- [ ] PyMuPDF permanent redaction engine removing glyphs and pixel streams.
- [ ] Verified zero trace of redacted text in `page.get_text()` search.
- [ ] Search & Redact text pattern matching across multi-page documents.
- [ ] 100% automated tests passing locally.
