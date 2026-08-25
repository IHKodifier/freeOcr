# Use Case & Implementation Tickets: freeOCR.me

> **Stage:** ★ Use Case & Implementation Tickets  
> **Persona:** Staff Engineer Writing Tickets  
> **Approved:** [x] approved  
> **Reads from:** [`04-feature-stories.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04-feature-stories.md), [`04b-mvp-scope.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04b-mvp-scope.md), [`06-data-model.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06-data-model.md)  
> **Governance:** **Test-Driven Development (TDD) Mandate** — Automated unit/integration tests must be created BEFORE writing implementation code for any ticket. Acceptance criteria map 1:1 to test assertions. **Graphify MCP** is incrementally updated to maintain the code graph and reduce cognitive load for AI agents.  
> **Scope:** MVP Implementation Backlog  
> **Ticket Count:** 16 Tickets (UC-000a, UC-000b, UC-000c, UC-001 through UC-013)  
> **Last Updated:** 2026-08-23  

---

## Epic 0: Project Infrastructure & Environment Foundation

### UC-000a: Monorepo Project Structure & Dependency Initialization

**Linked Story:** Technical Foundation  
**Actor:** Lead Engineer / Developer  
**Trigger:** Initial project bootstrapping.  

**Preconditions**
- [ ] Git repository initialized on branch `dev`.
- [ ] Python 3.13.5 installed locally; Flutter SDK installed.

**Main Flow**
1. Initialize monorepo directory layout: `./src/frontend` (Flutter), `./src/backend` (FastAPI), `./src/tests` (Unit/Integration).
2. Create `./src/backend/pyproject.toml` or `requirements.txt` with dependencies (`fastapi`, `uvicorn`, `redis`, `sqlalchemy`, `alembic`, `pymupdf`, `pytest`, `celery`).
3. Initialize `./src/frontend` Flutter Web project using `flutter create --platforms web ./src/frontend`.
4. Configure Flutter Material 3 `ColorScheme` theme tokens in `./src/frontend/lib/theme/app_theme.dart`.

**Acceptance Criteria (Testable)**
- WHEN running `cd src/frontend; flutter analyze` THE SYSTEM SHALL exit with 0 errors.
- WHEN running `pytest src/tests/` THE SYSTEM SHALL discover and execute test suite successfully.

**Estimate:** S | **Depends on:** None

---

### UC-000b: Local Development Pipeline, Redis & Dev Database Setup

**Linked Story:** Technical Foundation  
**Actor:** Developer  
**Trigger:** Running local development environment.  

**Preconditions**
- [ ] Docker / Docker Desktop installed locally.

**Main Flow**
1. Create `./scripts/start_backend.ps1` PowerShell script to spin up Redis container (`redis:7-alpine` on port `6379`).
2. Configure FastAPI `config.py` settings to load environment variables from `.env.example` (SQLite `sqlite:///./dev.db` for local ORM testing, Redis URL `redis://localhost:6379/0`).
3. Apply initial SQLAlchemy migrations via Alembic.

**Acceptance Criteria (Testable)**
- WHEN executing `.\scripts\start_backend.ps1` THE SYSTEM SHALL verify Redis connectivity and launch FastAPI server at `http://127.0.0.1:8000/healthz`.

**Estimate:** S | **Depends on:** UC-000a

---

### UC-000c: GitHub Actions CI/CD Pipeline & Graphify MCP Integration

**Linked Story:** Technical Foundation  
**Actor:** CI/CD Automation Runner  
**Trigger:** Pull Request opened or updated into `dev` branch.  

**Preconditions**
- [ ] GitHub repository configured with `dev` and `main` branch protection.

**Main Flow**
1. Create `.github/workflows/ci.yml` defining automated test workflows.
2. Step 1: Checkout code & setup Python 3.13.5 and Flutter.
3. Step 2: Run `pytest src/tests/ -v`.
4. Step 3: Run `cd src/frontend; flutter test`.
5. Initialize `graphify` knowledge graph for code structure tracking.

**Acceptance Criteria (Testable)**
- WHEN a PR is opened targeting `dev` THE SYSTEM SHALL execute GitHub Actions CI pipeline and block merge if any test fails.

**Estimate:** S | **Depends on:** UC-000a, UC-000b

---

## Epic 1: Zero-Friction Conversion Engine

### UC-001: Drag & Drop PDF Upload & File Validation

**Linked Story:** US-101  
**Actor:** Anonymous Web User  
**Trigger:** User drops file onto landing hero zone or clicks file selector.  

**Preconditions**
- [ ] Landing page loaded in Flutter Web UI (`/`).

**Main Flow**
1. User drags `.pdf`, `.jpg`, `.png`, or `.jpeg` file onto hero dropzone.
2. Flutter UI validates file extension and size against limits fetched from `GET /api/v1/config` (backed by `src/backend/app/app_limits_config.json`).
3. System checks Redis 5-hour quota counters (`rate_limit:simple:{client_ip}` / `rate_limit:complex:{client_ip}`) and active session token (`ad_pass:{client_ip}`).
4. If file is within limits, HTTP `POST /api/v1/ocr/convert` payload is sent to FastAPI Gateway.
5. FastAPI Gateway invokes **UC-001a Layout Analyzer**, creates Redis job key `job:{job_id}`, and enqueues to `ocr:queue:cpu` (for simple) or `ocr:queue:gpu` (for complex).

**Alternate Flows**
- **A1 — Over Limit:** File exceeds free cap → Triggers **UC-010 (Rewarded Ad Modal)**.
- **A2 — Quota Exhausted:** 5-hour simple or complex quota reached → Displays toast: *"Quota reached for this 5-hour window. Watch a video ad or return later."*

**Edge Cases & Error Handling**
- [ ] Unsupported file format (e.g. `.exe`, `.docx`) → System shall display instant validation error toast and reject upload.
- [ ] 0-byte file dropped → System shall display: *"File is empty. Please select a valid document."*

**Postconditions**
- Job metadata created in Redis in `QUEUED` state; target queue (`ocr:queue:cpu` / `ocr:queue:gpu`) receives task; client receives `{job_id}`.

**Data & API Touchpoints**
- Config File: `src/backend/app/app_limits_config.json`
- Redis Model: `job:{job_id}`, `rate_limit:simple:{client_ip}`, `rate_limit:complex:{client_ip}`, `ad_pass:{client_ip}`
- Endpoint: `POST /api/v1/ocr/convert`

**Acceptance Criteria (Testable)**
- WHEN a user drops a valid PDF under 10MB THE SYSTEM SHALL return HTTP 202 with `{job_id}` within 500ms.
- WHEN a user drops an invalid file extension THE SYSTEM SHALL reject the file client-side before sending HTTP request.

**Estimate:** S | **Depends on:** None

---

### UC-001a: Document Layout & Complexity Pre-Processing Analyzer

**Linked Story:** US-101a  
**Actor:** FastAPI Backend Services  
**Trigger:** Receipt of uploaded PDF in `POST /api/v1/ocr/convert`.  

**Preconditions**
- [ ] Valid PDF file bytes received by FastAPI handler.

**Main Flow**
1. FastAPI handler passes PDF stream to `LayoutAnalyzer` service.
2. `LayoutAnalyzer` inspects page structure using PyMuPDF (`fitz`) to detect text block density, column alignment, tabular line grids, and math formula symbols.
3. If layout is single-column without complex tables or formulas, classify as `SIMPLE`.
4. If layout contains multi-column text, complex tables, or math formulas, classify as `COMPLEX`.
5. Return complexity classification (`SIMPLE` / `COMPLEX`) to conversion router.

**Acceptance Criteria (Testable)**
- WHEN a single-column text PDF is analyzed THE SYSTEM SHALL classify it as `SIMPLE` and target `OCRmyPDF` on `ocr:queue:cpu`.
- WHEN a multi-column or table-heavy PDF is analyzed THE SYSTEM SHALL classify it as `COMPLEX` and target `Baidu_Unlimited_OCR` on `ocr:queue:gpu`.

**Estimate:** M | **Depends on:** UC-001

---

### UC-002: Real-Time SSE Progress Streaming

**Linked Story:** US-102  
**Actor:** Flutter Web UI / Server-Sent Events Gateway  
**Trigger:** Receipt of `{job_id}` from UC-001.  

**Preconditions**
- [ ] `{job_id}` in `QUEUED` or `PROCESSING` state in Redis.

**Main Flow**
1. Flutter Web UI opens SSE connection `GET /api/v1/jobs/{job_id}/events`.
2. FastAPI SSE handler subscribes to Redis pub/sub channel `job_events:{job_id}`.
3. As worker converts each page, worker emits JSON event: `{"current_page": 3, "total_pages": 8, "status": "PROCESSING", "target_engine": "CPU - OCRmyPDF"}`.
4. SSE stream pushes payload to Flutter client.
5. Flutter progress bar updates smoothly with progress percentage and engine badge.

**Edge Cases & Error Handling**
- [ ] Network disconnect mid-stream → Flutter EventSource client automatically retries connection with `Last-Event-ID`.

**Postconditions**
- Client notified of `COMPLETED` or `FAILED` status in real-time.

**Data & API Touchpoints**
- Redis Pub/Sub: `job_events:{job_id}`
- Endpoint: `GET /api/v1/jobs/{job_id}/events`

**Acceptance Criteria (Testable)**
- WHEN a page OCR task finishes THE SYSTEM SHALL emit an SSE event containing `current_page`, `total_pages`, and `target_engine` within 100ms.
- WHEN job state transitions to `COMPLETED` THE SYSTEM SHALL emit final SSE event with `output_pdf_token`.

**Estimate:** M | **Depends on:** UC-001

---

### UC-003: Baidu Unlimited OCR & OCRmyPDF Worker Execution & Scale-to-Zero `tmpfs` RAM Disk Management

**Linked Story:** US-103  
**Actor:** Celery CPU / GPU Worker Processes  
**Trigger:** Worker pops job task from `ocr:queue:cpu` or `ocr:queue:gpu`.  

**Preconditions**
- [ ] CPU worker running OCRmyPDF (or GPU worker running Baidu Unlimited OCR ~6 GB AI Model).
- [ ] Cold-start trigger automatically executed if worker instance was scaled to 0.

**Main Flow**
1. Worker reads PDF stream from Redis task payload.
2. Worker writes PDF payload to Linux `tmpfs` RAM disk (`/tmp/ephemeral_<job_id>.pdf`).
3. Python `try ... finally` context manager initialized.
4. If `ocr:queue:cpu`, execute `OCRmyPDF` subprocess. If `ocr:queue:gpu`, invoke Baidu Unlimited OCR AI Model (~6 GB) inference page-by-page.
5. Output recognized text and 2D bounding polygon coordinates returned in memory.

**Postconditions & Cleanup**
- Python context manager `finally:` block executes `os.remove('/tmp/ephemeral_<job_id>.pdf')` immediately. 0 bytes remain on disk.

**Data & API Touchpoints**
- Storage: Linux `tmpfs` RAM disk (`/tmp`)

**Acceptance Criteria (Testable)**
- WHEN OCR inference finishes or raises an exception THE SYSTEM SHALL execute `os.remove()` on the input file in `finally:` block.
- WHEN worker processes a page THE SYSTEM SHALL execute zero-disk persistence in RAM.

**Estimate:** L | **Depends on:** UC-001, UC-001a

---

### UC-004: Searchable PDF Composition Engine (Invisible Layer Overlay)

**Linked Story:** US-104  
**Actor:** Python PDF Builder (`PyMuPDF` / `fitz`)  
**Trigger:** Completion of bounding box extraction in UC-003.  

**Preconditions**
- [ ] Original high-res page image raster available in RAM.
- [ ] Bounding polygon coordinates extracted for all recognized text strings.

**Main Flow**
1. PyMuPDF engine initializes page with original scan raster as background image (`300 DPI`).
2. Engine iterates over text blocks and bounding boxes `[x_min, y_min, x_max, y_max]`.
3. Engine injects transparent text layer (text render mode 3 = invisible) at exact `(x, y)` coordinates.
4. Output Searchable PDF written to `tmpfs` RAM disk (`/tmp/out_<job_id>.pdf`).

**Acceptance Criteria (Testable)**
- WHEN a user opens the output PDF THE SYSTEM SHALL present a document visually pixel-identical to original scan.
- WHEN a user performs `Ctrl+F` text search in PDF reader THE SYSTEM SHALL match and highlight searched text.

**Estimate:** H | **Depends on:** UC-003


---

## Epic 2: Preview & Multi-Format Export

### UC-005: Interactive Side-by-Side Split Preview Viewer

**Linked Story:** US-201  
**Actor:** Flutter Web UI  
**Trigger:** SSE `COMPLETED` event received.  

**Main Flow**
1. Flutter Web UI renders split-screen layout (`/result/{job_id}`).
2. Left Pane: Original scan image renderer.
3. Right Pane: Selectable OCR text editor/viewer with `.txt` / `.md` tab toggles.
4. Middle Divider: Interactive drag handle allowing 1:1 mouse/touch drag ratio to adjust split width.

**Acceptance Criteria (Testable)**
- WHEN job completes THE SYSTEM SHALL render side-by-side split view within 300ms.
- WHEN user drags split handle THE SYSTEM SHALL resize left and right panes in 1:1 real-time sync.

**Estimate:** M | **Depends on:** UC-002, UC-004

---

### UC-005b: Premium Apple-Grade UI Generation & All-Screen Visual Polish

**Linked Story:** US-201 / Modern Web Design Mandate  
**Actor:** Lead UI/UX Engineer & Flutter Web Client  
**Trigger:** UI component construction during Sprint 2.  

**Main Flow**
1. Engineer generates premium UI mockups and design token assets using AI design tools (`generate_image`, Stitch, modern Web guidance).
2. Implement Apple-inspired glassmorphism, translucent backdrop blurs (`backdrop-filter blur 20px`), Electric Indigo (`#4F46E5` / `#818CF8`) gradients, and Inter & JetBrains Mono typography across all project screens.
3. Add fluid spring micro-animations (`CurvedAnimation` with damping `1.0` / response `0.4s`) for button presses (`transform: scale(0.97)` on pointer-down), hero dropzone hover states, and modal transitions.
4. Apply consistent visual polish to:
   - **Hero Landing Page & Interactive Dropzone** (`/`)
   - **Real-Time SSE Progress Bar Component**
   - **Interactive Side-by-Side Split Preview Viewer** (`/result/{job_id}`)
   - **Frosted Glass Rewarded Video Ad Modal**
   - **Password-in-Place Encrypted PDF Decryption Modal**
   - **Local Time Expired Download Link Page** (`/expired`)

**Acceptance Criteria (Testable)**
- WHEN any page or modal renders THE SYSTEM SHALL apply Material 3 design system tokens and glassmorphism styling without plain default browser controls.
- WHEN an interactive element is pressed THE SYSTEM SHALL execute an instant pointer-down spring physics scale response within 100ms.

---

### UC-006: 1-Click Multi-Format Direct Download (`.pdf`, `.txt`, `.md`)

**Linked Story:** US-202  
**Actor:** Anonymous Web User  
**Trigger:** User clicks "Download Searchable PDF", "Download Text", or "Download Markdown".  

**Main Flow**
1. User clicks selected format download button on result page.
2. Browser sends request `GET /api/v1/jobs/{job_id}/download/{format}`.
3. Gateway streams file bytes from RAM disk with header `Content-Disposition: attachment`.
4. Immediately upon direct download stream initiation, Gateway triggers `os.remove()` to unlinks original input file from RAM disk.

**Acceptance Criteria (Testable)**
- WHEN user clicks download THE SYSTEM SHALL initiate browser file download immediately.
- WHEN direct download starts THE SYSTEM SHALL purge original input file from RAM disk.

**Estimate:** S | **Depends on:** UC-004, UC-005

---

### UC-007: Email Download Link Delivery & Immediate Input File Purging

**Linked Story:** US-203  
**Actor:** Anonymous Web User / Resend Email API  
**Trigger:** User enters email and clicks "Send Download Links".  

**Main Flow**
1. User enters email in Email Delivery box.
2. User clicks **[Send Download Links]**.
3. UI displays explicit warning: *"Input file is deleted immediately. Ensure email is correct."*
4. Client calls `POST /api/v1/ocr/email-links` with `{job_id, email}`.
5. Resend API dispatches email with 24-hour download links for `.pdf`, `.txt`, and `.md`.
6. Gateway immediately triggers `os.remove()` on original input file in RAM disk.

**Acceptance Criteria (Testable)**
- WHEN user clicks "Send Email" THE SYSTEM SHALL queue email delivery and execute instant `os.remove()` on input file regardless of email delivery status.
- WHEN email is delivered THE SYSTEM SHALL include valid download URLs expiring in 24 hours.

**Estimate:** M | **Depends on:** UC-006

---

### UC-008: 24-Hour Expiration TTL & Local Time Expired Link Handler

**Linked Story:** US-204  
**Actor:** Web Visitor / Gateway Expiration Handler  
**Trigger:** User clicks an emailed download link after 24 hours.  

**Main Flow**
1. Visitor opens emailed download link `GET /api/v1/jobs/{job_id}/download/{format}` after 24 hours.
2. Gateway checks Redis key expiration `expires_at`.
3. Key has expired (or output file unlinked after 24h TTL).
4. Gateway returns HTTP 410 Gone payload with local time expiration timestamp.
5. UI renders friendly page: *"This download link expired on [Date/Time in User's Local Time Zone]. Output files are purged after 24h for privacy."*

**Acceptance Criteria (Testable)**
- WHEN a user clicks a download link after 24h TTL THE SYSTEM SHALL return HTTP 410 Gone.
- WHEN 410 page renders THE SYSTEM SHALL format expiration date in user's detected local time zone.

**Estimate:** S | **Depends on:** UC-007

---

## Epic 3: Ad Monetization & Rewarded Boosts

### UC-009: 35-Second AdSense Display Ad Banner Auto-Rotation Timer

**Linked Story:** US-301  
**Actor:** Google Mobile Ads SDK for Flutter / JS Script  
**Trigger:** Page load of Landing (`/`) or Download (`/result/{job_id}`).  

**Main Flow**
1. 728x90 leaderboard ad banner container rendered above fold.
2. 35-second JavaScript timer initialized (`setInterval(refreshAds, 35000)`).
3. If page tab is active, ad container re-fetches ad unit every 35 seconds.

**Acceptance Criteria (Testable)**
- WHEN page is loaded and tab remains active THE SYSTEM SHALL trigger ad refresh every 35 seconds.
- WHEN user switches to another browser tab THE SYSTEM SHALL pause 35s rotation timer.

**Estimate:** S | **Depends on:** None

---

### UC-010: Limit Exceeded Detection & Rewarded Video Ad Modal Trigger

**Linked Story:** US-302  
**Actor:** Flutter Web UI Validation Engine  
**Trigger:** User drops file exceeding current session limits (`BASE_MAX_PAGES` or `BASE_MAX_FILE_MB`).  

**Main Flow**
1. Client-side PDF parser counts pages (e.g. 22 pages) and evaluates file size.
2. Page count or file size exceeds current active limit (e.g. `BASE_MAX_PAGES = 10`, `BASE_MAX_FILE_MB = 10MB`).
3. System checks Redis for active `ad_pass:{client_ip}` boost counters.
4. UI displays Rewarded Ad Modal: *"Unlock Stackable Limit Boost (+15 Pages & +20MB per ad watched)"* with **[Watch 15s Ad to Stack Boost]** button.
5. Modal informs user that watching additional ads will continuously stack limits indefinitely (e.g. up to 500 MB / 500 pages).

**Acceptance Criteria (Testable)**
- WHEN uploaded PDF exceeds active session cap THE SYSTEM SHALL display Rewarded Ad Modal with stackable limit options.
- THE SYSTEM SHALL load base limits (`BASE_MAX_PAGES`, `BASE_MAX_FILE_MB`) dynamically from runtime environment configuration.

**Estimate:** M | **Depends on:** UC-001

---

### UC-011: Rewarded Ad Callback & Stackable Session Limit Boost Pass

**Linked Story:** US-303  
**Actor:** Google Mobile Ads SDK / FastAPI Gateway  
**Trigger:** User finishes watching a 15-second rewarded video ad.  

**Main Flow**
1. User watches a 15-second rewarded video ad to completion.
2. Google Ads SDK triggers `onUserEarnedReward` callback with signed reward token.
3. Flutter client calls `POST /api/v1/ads/rewarded-callback` with token.
4. FastAPI Gateway validates reward token and increments Redis session key `ad_pass:{client_ip}`:
   - Increments allowed page limit by `BOOST_PER_AD_PAGES` (default +15 pages, runtime configurable).
   - Increments allowed file size limit by `BOOST_PER_AD_MB` (default +20 MB, runtime configurable).
   - Extends Redis session TTL (default 3600s, runtime configurable).
5. User can choose to watch another ad to stack limits further, or initiate conversion immediately if file requirements are satisfied.

**Acceptance Criteria (Testable)**
- WHEN rewarded ad completes THE SYSTEM SHALL atomically increment `ad_pass:{client_ip}` page cap by `BOOST_PER_AD_PAGES` and file cap by `BOOST_PER_AD_MB` in Redis within 200ms.
- WHEN multiple ads are watched back-to-back THE SYSTEM SHALL stack limit boosts indefinitely without hardcoded ceilings.
- ALL limit thresholds and boost step sizes SHALL be loaded from runtime configuration (never hardcoded in application logic).

**Estimate:** M | **Depends on:** UC-010

---

## Epic 4: PDF Error Handling & Auto-Repair

### UC-012: Password-in-Place Encrypted PDF Decryption

**Linked Story:** US-401  
**Actor:** Anonymous Web User / PyMuPDF Decryptor  
**Trigger:** Upload of encrypted PDF.  

**Main Flow**
1. PyMuPDF identifies PDF encryption flag (`doc.is_encrypted == True`).
2. Gateway returns HTTP 422 with `{"error": "PASSWORD_REQUIRED"}`.
3. Flutter UI renders inline password prompt over dropzone: *"Password Protected PDF. Enter password:"*.
4. User enters password and clicks **[Unlock & Process]**.
5. Password passed to backend worker; worker decrypts PDF stream in RAM and resumes OCR.

**Acceptance Criteria (Testable)**
- WHEN encrypted PDF is uploaded THE SYSTEM SHALL prompt user for password in-place.
- WHEN correct password is provided THE SYSTEM SHALL decrypt in RAM and execute OCR without re-uploading file.

**Estimate:** S | **Depends on:** UC-001, UC-003

---

### UC-013: Corrupted PDF Automated Repair Fallback & 60s Watchdog Cleaner

**Linked Story:** US-402, US-403  
**Actor:** Celery Worker / Watchdog Background Cron  
**Trigger:** PDF stream parsing exception OR 30-second watchdog timer tick.  

**Main Flow (Repair Fallback)**
1. Worker catches corrupted PDF exception during page extraction.
2. Worker emits SSE progress update: *"Attempting PDF repair..."*.
3. Worker runs automated repair pipeline (`qpdf --repair` / `pdfcpu repair`).
4. If repair succeeds: Resumes OCR. If repair fails: Returns user-friendly error toast.

**Main Flow (Watchdog RAM Cleaner)**
1. Independent background process runs every 30 seconds on worker node.
2. Scans `/tmp` RAM disk for files with `mtime` older than 60 seconds.
3. Executes `os.remove()` on any orphan files to guarantee RAM disk hygiene.

**Acceptance Criteria (Testable)**
- WHEN a corrupted PDF is uploaded THE SYSTEM SHALL execute automated repair scripts before raising error.
- WHEN an orphan file in `/tmp` RAM disk exceeds 60s `mtime` THE SYSTEM SHALL automatically purge file via Watchdog.

**Estimate:** M | **Depends on:** UC-003
