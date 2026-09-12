# Use Case & Implementation Tickets: freeOCR.me

> **Stage:** ★ Use Case & Implementation Tickets  
> **Persona:** Staff Engineer Writing Tickets  
> **Approved:** [x] approved  
> **Reads from:** [`04-feature-stories.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04-feature-stories.md), [`04b-mvp-scope.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04b-mvp-scope.md), [`06-data-model.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06-data-model.md)  
> **Governance:** **Test-Driven Development (TDD) Mandate** — Automated unit/integration tests must be created BEFORE writing implementation code for any ticket. Acceptance criteria map 1:1 to test assertions. **Graphify MCP** is incrementally updated to maintain the code graph and reduce cognitive load for AI agents.  
> **Scope:** MVP Implementation Backlog & FreePDFToolz Suite Expansion  
> **Ticket Count:** 33 Tickets (UC-000a, UC-000b, UC-000c, UC-001 through UC-015, UC-016 through UC-032)  
> **Last Updated:** 2026-09-13  

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

### UC-000c: GitHub Actions CI/CD Pipeline, Firebase Hosting & Graphify MCP Integration

**Linked Story:** Technical Foundation  
**Actor:** CI/CD Automation Runner  
**Trigger:** Pull Request opened or updated into `dev` branch or merge to `main`.  

**Preconditions**
- [ ] GitHub repository configured with `dev` and `main` branch protection.

**Main Flow**
1. Create `.github/workflows/ci.yml` defining automated test workflows.
2. Step 1: Checkout code & setup Python 3.13.5 and Flutter.
3. Step 2: Run `pytest src/tests/ -v`.
4. Step 3: Run `cd src/frontend; flutter test`.
5. Step 4: Build static Flutter Web bundle (`flutter build web --release`) and deploy to **Firebase Hosting** global CDN (`firebase.json` configuration).
6. Initialize `graphify` knowledge graph for code structure tracking.

**Acceptance Criteria (Testable)**
- WHEN a PR is opened targeting `dev` THE SYSTEM SHALL execute GitHub Actions CI pipeline and block merge if any test fails.
- WHEN merged to `main` THE SYSTEM SHALL deploy Flutter Web static assets to Firebase Hosting global CDN.

**Estimate:** S | **Depends on:** UC-000a, UC-000b

---

## Epic 1: Zero-Friction Conversion Engine

### UC-001: Drag & Drop PDF Upload & File Validation

**Linked Story:** US-101  
**Actor:** Anonymous Web User  
**Trigger:** User drops file onto landing hero zone or clicks file selector.  

**Preconditions**
- [ ] Landing page loaded in Flutter Web UI (`/`) served instantly from **Firebase Hosting** CDN (0s cold start).

**Main Flow**
1. Upon web app launch from Firebase Hosting, Flutter UI sends an optimistic background `GET /api/v1/config` ping to pre-warm scale-to-zero GCP Cloud Run backend containers.
2. User drags `.pdf`, `.jpg`, `.png`, or `.jpeg` file onto hero dropzone.
3. Flutter UI validates file extension and size against limits fetched from `GET /api/v1/config` (backed by `src/backend/app/app_limits_config.json`).
4. System checks Redis 5-hour quota counters (`rate_limit:simple:{client_ip}` / `rate_limit:complex:{client_ip}`) and active session token (`ad_pass:{client_ip}`).
5. If file is within limits, HTTP `POST /api/v1/ocr/convert` payload is sent to FastAPI Gateway.
6. FastAPI Gateway invokes **UC-001a Layout Analyzer**, creates Redis job key `job:{job_id}`, and enqueues to `ocr:queue:cpu` (for simple) or `ocr:queue:gpu` (for complex).


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

### UC-009: Runtime Configurable AdSense Display Ad Banner Auto-Rotation Timer

**Linked Story:** US-301  
**Actor:** Google Mobile Ads SDK for Flutter / JS Script  
**Trigger:** Page load of Landing (`/`) or Download (`/result/{job_id}`).  

**Main Flow**
1. 728x90 leaderboard ad banner container rendered above fold.
2. Flutter Web UI fetches `ad_rotation_interval_seconds` (default 35s) dynamically from `GET /api/v1/config` (backed by `src/backend/app/app_limits_config.json`).
3. Auto-rotation timer initialized using the runtime interval (`setInterval(refreshAds, intervalSeconds * 1000)`).
4. Updating `ad_rotation_interval_seconds` in `app_limits_config.json` changes rotation speed instantly for all users without requiring a rebuild or redeployment of the Flutter app.
5. If page tab is active, ad container re-fetches ad unit every `intervalSeconds` seconds.

**Acceptance Criteria (Testable)**
- WHEN page is loaded THE SYSTEM SHALL fetch `ad_rotation_interval_seconds` from `GET /api/v1/config` and initialize the timer dynamically.
- WHEN user switches to another browser tab THE SYSTEM SHALL pause rotation timer.
- WHEN `ad_rotation_interval_seconds` is updated in `app_limits_config.json` THE SYSTEM SHALL reflect the new timer duration on subsequent config fetches without requiring a frontend app build/redeploy.

**Estimate:** S | **Depends on:** None


---

### UC-010: Limit Exceeded Detection & Rewarded Video Ad Modal Trigger

**Linked Story:** US-302  
**Actor:** Flutter Web UI Validation Engine  
**Trigger:** User drops file exceeding current session file size limit (`base_max_file_mb`).  

**Main Flow**
1. Client-side validation evaluates uploaded file size in MB.
2. File size exceeds current active session limit (e.g. file size > `base_max_file_mb` of 10MB).
3. System checks Redis for active `ad_pass:{client_ip}` boost counters.
4. UI displays Rewarded Ad Modal: *"Unlock Stackable Limit Boost (+20MB per ad watched)"* with **[Watch 15s Ad to Stack Boost]** button.
5. Modal informs user that watching additional ads will continuously stack file size limits up to `max_stack_file_mb` (500 MB).

**Acceptance Criteria (Testable)**
- WHEN uploaded PDF exceeds active session file size cap THE SYSTEM SHALL display Rewarded Ad Modal with stackable limit options.
- THE SYSTEM SHALL load base limit (`base_max_file_mb`) dynamically from runtime configuration.

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
   - Increments allowed file size limit by `boost_per_ad_mb` (default +20 MB, runtime configurable).
   - Extends Redis session TTL (`ad_boost_ttl_seconds`, default 3600s).
5. User can choose to watch another ad to stack file size limits further up to `max_stack_file_mb`, or initiate conversion immediately.

**Acceptance Criteria (Testable)**
- WHEN rewarded ad completes THE SYSTEM SHALL atomically increment `ad_pass:{client_ip}` file size cap by `boost_per_ad_mb` in Redis within 200ms.
- WHEN multiple ads are watched back-to-back THE SYSTEM SHALL stack file size limit boosts up to `max_stack_file_mb`.
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

---

### UC-014: Google Analytics 4 (GA4) Telemetry & SEO Meta-Tag Injection

**Linked Story:** US-501  
**Actor:** Google Analytics 4 SDK / Web Shell  
**Trigger:** Web app page load or key conversion user event.  

**Main Flow**
1. GA4 `gtag.js` script tag injected into Web `index.html` head (`G-XXXXXXXXXX`).
2. Web app dispatches pageview events on route navigation (`/`, `/result/{job_id}`, `/kb`).
3. Custom telemetry events tracked: `document_uploaded`, `ocr_completed`, `download_clicked`, `email_sent`.
4. SEO title, description meta tags, OpenGraph images, and canonical URL header tags injected for search indexation.

**Acceptance Criteria (Testable)**
- WHEN web app initializes THE SYSTEM SHALL load GA4 script and log pageview telemetry without blocking UI thread.
- WHEN user completes OCR download THE SYSTEM SHALL emit custom `download_clicked` GA4 telemetry event.

**Estimate:** S | **Depends on:** UC-001

---

### UC-015: AdSense-Qualifying Original Content Knowledge Base, Educational Docs & Embedded GitHub References

**Linked Story:** US-502  
**Actor:** Google AdSense Site Inspector / Web Visitor  
**Trigger:** Visitor clicks Knowledge Base or Educational Documentation articles.  

**Main Flow**
1. Generate comprehensive Google Stitch ready prompts covering screen-by-screen UI designs for both core conversion views and full Knowledge Base / Wiki / Educational article pages.
2. Build static Knowledge Base & Educational pages (`/kb/ocr-guide`, `/kb/pdf-standards`, `/docs`, `/privacy`, `/terms`).
3. Author original, high-value educational content explaining PDF text layers, OCR technology, ephemeral security, and OCRmyPDF / Baidu engine mechanics to satisfy Google AdSense publisher requirements.
4. Embed authoritative GitHub reference links (e.g., Tesseract OCR, PyMuPDF, OCRmyPDF, open-source PDF specification repositories) directly within educational articles to demonstrate editorial depth and domain authority.
5. Implement Stitch-guided designs in Flutter with full header/footer linking, `sitemap.xml`, and `robots.txt` indexation.

**Acceptance Criteria (Testable)**
- THE SYSTEM SHALL generate Google Stitch prompts for KB/Wiki article pages alongside core application screens.
- WHEN visitor navigates to `/kb` THE SYSTEM SHALL render original educational content pages containing embedded GitHub resource links.
- WHEN search engines index `/kb` pages THE SYSTEM SHALL provide valid OpenGraph and structured schema markup.

**Estimate:** M | **Depends on:** UC-001

---

## Epic 6: FreePDFToolz Core Foundation & Page Operations (Sprint F1)

### UC-016: Multi-Tool Routing Hub & Host-Aware Navigation Shell

**Linked Story:** FreePDFToolz Foundation  
**Actor:** Anonymous Web Visitor / Flutter Web Shell  
**Trigger:** Visitor navigates to root domain (`freeocr.me` or `freepdftoolz.me`) or tool deep-link.  

**Preconditions**
- [ ] Staging and production deployment pointing to unified Cloud Run container.

**Main Flow**
1. Flutter Web inspects `window.location.hostname`.
2. If hostname contains `freeocr.me`: Root route `/` renders dedicated `freeOCR.me` interface directly.
3. If hostname contains `freepdftoolz.me`: Root route `/` renders the `FreePDFToolz` Hub — responsive Material 3 card grid featuring all 15 tools categorized into Page Ops, Security & Transformation, and AI/Conversions, with a featured badge for Free OCR.
4. Top Navigation Bar provides brand switcher, tool search modal/palette, dark/light theme toggle, and fast category filter tabs.
5. All direct deep links (`/merge`, `/split`, `/rotate`, `/delete-pages`, `/extract-pages`, `/number-pages`, `/compress`, `/watermark`, `/crop`, `/redact`, `/sign`, `/annotate`, `/edit-text`, `/pdf-to-word`, `/summarize`, `/ocr`) function identically across both domains.

**Acceptance Criteria (Testable)**
- WHEN hostname matches `freeocr.me` THE SYSTEM SHALL mount the dedicated OCR dropzone at root path `/`.
- WHEN hostname matches `freepdftoolz.me` THE SYSTEM SHALL mount the multi-tool hub grid at root path `/`.
- WHEN navigating to any direct tool route (e.g. `/merge`) THE SYSTEM SHALL load the requested tool regardless of host domain.

**Estimate:** M | **Depends on:** UC-000a

---

### UC-017: Merge PDF Engine & Multi-File Drag-and-Drop Reorder UI

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads 2 or more PDF files to `/merge`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-017-pdf-merge`.
- [ ] PyMuPDF (`fitz`) installed in backend environment.

**Main Flow**
1. User drops 2+ PDF files onto the Merge dropzone.
2. Flutter UI renders a visual reorderable card list displaying filename, file size, page count, and drag handles, with options to add more files or remove items.
3. User clicks "Merge PDFs".
4. Flutter dispatches `POST /api/v1/tools/merge` with `multipart/form-data` files ordered by user's list.
5. FastAPI verifies file formats, checks size against free tier (100MB cumulative) or session boost passes, streams files into `tmpfs` RAM disk.
6. PyMuPDF instantiates output document, appends each document with `doc.insert_pdf()`, and writes merged stream with deflate compression and garbage collection.
7. Backend returns one-click direct download link and purges input temp files.

**Acceptance Criteria (Testable)**
- WHEN uploading fewer than 2 PDF files THE SYSTEM SHALL reject merge with HTTP 400 error.
- WHEN uploading 2+ valid PDF files in a specific order THE SYSTEM SHALL output a single valid PDF preserving the exact page order.
- WHEN merged PDF is created THE SYSTEM SHALL purge all input files from RAM disk within 60 seconds.

**Estimate:** M | **Depends on:** UC-016

---

### UC-018: Split PDF Engine & Page Range Selector UI

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads a PDF to `/split`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-018-pdf-split`.

**Main Flow**
1. User drops a multi-page PDF onto `/split`.
2. UI displays total detected page count and mode selector:
   - Mode A: Custom Ranges (e.g. `1-3, 5, 8-12`).
   - Mode B: Split every N pages.
   - Mode C: Extract each page as an individual PDF.
3. User submits split parameters; UI sends `POST /api/v1/tools/split`.
4. Backend parses range strings, creates split PDFs via PyMuPDF in `tmpfs`.
5. If split results in a single PDF, returns `.pdf`; if multiple files, packages into a clean `.zip` archive.

**Acceptance Criteria (Testable)**
- WHEN splitting a 10-page document with range `1-2, 5` THE SYSTEM SHALL generate a ZIP containing Document_1-2.pdf and Document_5.pdf.
- WHEN invalid or out-of-bounds page range is requested THE SYSTEM SHALL return HTTP 422 with descriptive error.

**Estimate:** M | **Depends on:** UC-016

---

### UC-019: Rotate PDF Engine & Visual Page Rotation Grid

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads a PDF to `/rotate`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-019-pdf-rotate`.

**Main Flow**
1. User uploads PDF; UI generates/displays page preview thumbnails in a responsive grid.
2. User can click individual page rotate icons (90° CW / 90° CCW) or global action "Rotate All Right / Left".
3. User clicks "Apply Rotation"; sends `POST /api/v1/tools/rotate` with rotation mapping `{page_index: angle_deg}`.
4. PyMuPDF applies `page.set_rotation((page.rotation + angle) % 360)` on target pages.
5. Returns rotated PDF for instant download.

**Acceptance Criteria (Testable)**
- WHEN rotating page 1 by 90° CW and page 2 by 180° THE SYSTEM SHALL update PDF dictionary rotation properties accurately.
- WHEN downloading rotated PDF THE SYSTEM SHALL verify output PDF opens without visual distortion.

**Estimate:** S | **Depends on:** UC-016

---

### UC-020: Delete Pages Engine & Visual Page Deletion Grid

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/delete-pages`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-020-delete-pages`.

**Main Flow**
1. User uploads PDF; UI renders page thumbnail grid with selection toggles.
2. Clicking a page marks it with a red "Delete" badge and strikethrough.
3. User confirms deletion; UI calls `POST /api/v1/tools/delete-pages` with `pages_to_delete: [int]`.
4. PyMuPDF executes `doc.delete_pages(pages_to_delete)` in reverse order.
5. Returns pruned PDF for download.

**Acceptance Criteria (Testable)**
- WHEN user attempts to delete 100% of pages in a PDF THE SYSTEM SHALL return HTTP 400 preventing empty document generation.
- WHEN deleting specified pages THE SYSTEM SHALL verify remaining pages match exact sequence without index shift errors.

**Estimate:** S | **Depends on:** UC-016

---

### UC-021: Extract Pages Engine & Multi-Page Extractor UI

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/extract-pages`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-021-extract-pages`.

**Main Flow**
1. User uploads PDF; selects pages to extract via checkbox grid or comma-separated range input.
2. Selects output format: Single Merged PDF or Separate PDFs (ZIP).
3. Backend invokes PyMuPDF `doc.select(pages_to_extract)` and saves output in `tmpfs`.
4. Returns download payload.

**Acceptance Criteria (Testable)**
- WHEN extracting pages 2 and 4 to a single PDF THE SYSTEM SHALL produce a 2-page document containing only original pages 2 and 4.
- WHEN extracting pages to separate files THE SYSTEM SHALL package outputs into a `.zip` archive.

**Estimate:** S | **Depends on:** UC-016

---

### UC-022: Number Pages Engine & Position/Format Selector UI

**Linked Story:** Page Operations  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/number-pages`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-022-number-pages`.

**Main Flow**
1. User uploads PDF; configures page number overlay:
   - Position: 3x3 alignment matrix (Top-Left, Top-Center, Top-Right, Bottom-Left, Bottom-Center, Bottom-Right).
   - Format: `"Page {n} of {total}"`, `"{n}"`, `"Page {n}"`.
   - Margin offset, font size, font color.
   - Page range filter (e.g. skip cover page / start from page 2).
2. Sends `POST /api/v1/tools/number-pages`.
3. PyMuPDF calculates bounding rect based on page dimensions, inserts formatted text overlay on requested pages.
4. Returns numbered PDF.

**Acceptance Criteria (Testable)**
- WHEN numbering pages with skip cover enabled THE SYSTEM SHALL leave page 1 unaltered and begin numbering on page 2.
- WHEN applying bottom-center numbering THE SYSTEM SHALL center text horizontally at specified bottom margin across all page sizes (Letter/A4).

**Estimate:** S | **Depends on:** UC-016

---

## Epic 7: FreePDFToolz Transformation, Optimization & Security (Sprint F2)

### UC-023: Compress PDF Engine (Stream Optimization & DPI Downsampling)

**Linked Story:** Optimization  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/compress`.  

**Preconditions**
- [ ] `pikepdf` and `PyMuPDF` available in backend.

**Main Flow**
1. User uploads PDF and selects compression level:
   - Recommended (150 DPI downsampling + deflate stream compression).
   - Extreme (72 DPI downsampling + aggressive font deduplication).
   - Low / Lossless (Deflate streams, remove duplicate objects, zero image downsampling).
2. Backend processes document in `tmpfs` using `pikepdf` object stream compression and PyMuPDF image stream optimization.
3. UI displays comparison banner: Original Size, New Compressed Size, and Percentage Saved (e.g. *"Compressed from 24.2 MB to 3.8 MB (-84%)"*).

**Acceptance Criteria (Testable)**
- WHEN compressed file is produced THE SYSTEM SHALL verify byte size is less than or equal to original size.
- WHEN compression level is Extreme THE SYSTEM SHALL downsample high-res embedded raster images to 72 DPI.

**Estimate:** M | **Depends on:** UC-016

---

### UC-024: Watermark PDF Engine (Text Angle/Opacity & Image Logo Overlay)

**Linked Story:** Transformation  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/watermark`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-024-watermark`.

**Main Flow**
1. User uploads PDF; selects Watermark Type (Text or Image).
2. For Text: Configures text string (e.g. "CONFIDENTIAL"), rotation angle (-45°, 0°, 45°), opacity (10% - 100%), font size, color.
3. For Image: Uploads logo PNG/JPG, sets scale and opacity.
4. Sends `POST /api/v1/tools/watermark`.
5. PyMuPDF draws watermark overlay stream on all pages with specified alpha transparency.
6. Returns watermarked PDF.

**Acceptance Criteria (Testable)**
- WHEN applying text watermark at 30% opacity THE SYSTEM SHALL render semi-transparent text overlay without corrupting existing text layers.
- WHEN applying image logo watermark THE SYSTEM SHALL preserve PNG alpha transparency over background content.

**Estimate:** M | **Depends on:** UC-016

---

### UC-025: Crop PDF Engine & Visual Bounding Box Trimmer

**Linked Story:** Transformation  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/crop`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-025-crop`.

**Main Flow**
1. User uploads PDF; UI renders interactive first-page preview with draggable crop bounding handles.
2. User adjusts crop box (Left, Top, Right, Bottom margins).
3. Chooses whether to apply crop to current page or all pages.
4. PyMuPDF updates `page.set_cropbox(fitz.Rect(x0, y0, x1, y1))`.
5. Returns cropped document.

**Acceptance Criteria (Testable)**
- WHEN crop box is applied THE SYSTEM SHALL update PDF `/CropBox` attributes without deleting underlying vectors.
- WHEN viewing cropped PDF in viewer THE SYSTEM SHALL display viewport bounded strictly by requested coordinates.

**Estimate:** M | **Depends on:** UC-016

---

### UC-026: Redact PDF Engine (True Cryptographic Glyph Sanitization)

**Linked Story:** Security & Privacy  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/redact`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-026-redact`.

**Main Flow**
1. User uploads PDF; selects text or draws black bounding boxes over sensitive areas (SSN, names, numbers) on page preview.
2. User clicks "Apply Redactions"; sends coordinate array to `POST /api/v1/tools/redact`.
3. PyMuPDF creates redaction annotations (`page.add_redact_annot()`) and applies permanent redactions (`page.apply_redactions()`).
4. Underlying glyphs, vector text, and raster pixel data beneath redaction rects are permanently sanitized and scrubbed from PDF binary stream.
5. Returns cryptographically redacted PDF.

**Acceptance Criteria (Testable)**
- WHEN redactions are applied THE SYSTEM SHALL ensure extracted text search (`pdftotext` / `get_text()`) returns 0 matches for redacted content.
- THE SYSTEM SHALL permanently remove raster pixels beneath redaction areas rather than drawing superficial black boxes.

**Estimate:** M | **Depends on:** UC-016

---

### UC-027: Sign PDF Engine & Flutter Signature Canvas Pad

**Linked Story:** Security & Workflow  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/sign`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-027-sign`.

**Main Flow**
1. User uploads PDF; clicks "Add Signature".
2. Signature Modal offers 3 input methods: Draw (finger/mouse canvas pad), Type (signature script fonts), or Upload (PNG image).
3. User places signature on document preview, drags to desired position, and resizes.
4. Sends `POST /api/v1/tools/sign` with signature PNG data and page coordinates `(page, x, y, width, height)`.
5. PyMuPDF stamps transparent signature image at target rect.
6. Returns signed PDF for instant download.

**Acceptance Criteria (Testable)**
- WHEN signature is placed on page 3 THE SYSTEM SHALL insert signature stream strictly on page 3 without altering other pages.
- WHEN signature PNG is drawn on transparent canvas THE SYSTEM SHALL stamp image with transparent background.

**Estimate:** M | **Depends on:** UC-016

---

## Epic 8: FreePDFToolz Advanced Conversions, AI & AdSense Launch (Sprint F3)

### UC-028: Annotate PDF Engine (Highlights, Rectangles, Sticky Notes)

**Linked Story:** Document Collaboration  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/annotate`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-028-annotate`.

**Main Flow**
1. User selects annotation tool: Text Highlight, Freehand Drawing, Rectangular Border, or Sticky Note.
2. Annotates page on interactive Flutter canvas.
3. Sends annotation payload to `POST /api/v1/tools/annotate`.
4. PyMuPDF creates standard PDF annotation dictionaries (`Highlight`, `Square`, `Text`, `Ink`).
5. Returns standard-compliant annotated PDF.

**Acceptance Criteria (Testable)**
- WHEN annotations are added THE SYSTEM SHALL write standard ISO 32000 PDF annotation objects compatible with Adobe Acrobat and Apple Preview.

**Estimate:** M | **Depends on:** UC-016

---

### UC-029: Edit Text in PDF Engine (Visual Redact-and-Replace & Overlays)

**Linked Story:** Document Editing  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/edit-text`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-029-edit-text`.

**Main Flow**
1. User uploads PDF; clicks on an existing text block to edit or clicks to insert new text block.
2. UI presents font size, color, and alignment controls.
3. On save, backend applies background match redaction to previous text and renders new text string with matching typography.
4. Returns edited PDF.

**Acceptance Criteria (Testable)**
- WHEN editing existing text block THE SYSTEM SHALL cleanly redact target bounding box and insert replacement string.

**Estimate:** M | **Depends on:** UC-016

---

### UC-030: Convert PDF to Word (.docx) via `pdf2docx` Engine

**Linked Story:** Conversion Engine  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/pdf-to-word`.  

**Preconditions**
- [ ] `pdf2docx` and `python-docx` installed in backend.

**Main Flow**
1. User drops PDF onto `/pdf-to-word`.
2. Backend streams file into `tmpfs` RAM disk.
3. Invokes `pdf2docx.Converter(input_pdf)` to extract paragraphs, font styles, tables, and embedded images.
4. Reconstructs and writes native `.docx` document in `tmpfs`.
5. Returns download link for `.docx` Word document and purges temp files.

**Acceptance Criteria (Testable)**
- WHEN converting a multi-page table and text PDF THE SYSTEM SHALL output a valid `.docx` file containing structured editable tables and text paragraphs.
- WHEN conversion finishes THE SYSTEM SHALL remove input PDF and output DOCX from RAM disk within 60 seconds.

**Estimate:** M | **Depends on:** UC-016

---

### UC-031: Summarize PDF Engine (Dual: Local TextRank CPU + Gemini Flash API)

**Linked Story:** AI Intelligence  
**Actor:** Anonymous Web Visitor / FastAPI Engine  
**Trigger:** User uploads PDF to `/summarize`.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-031-summarize`.
- [ ] Local extractive engine (`sumy` / `nltk` / `ONNX`) configured for zero-cloud local testing.

**Main Flow**
1. User uploads PDF to `/summarize`; selects summary depth (Executive Brief, Key Takeaways, Bullet Points, or Chapter Breakdown).
2. Backend uses PyMuPDF to extract text stream, cleaning headers/footers.
3. Engine Router selects summarization mode:
   - Mode 1 (Local Zero-Cloud / Default): Extractive TextRank algorithm identifies top informative sentences and scores key bullet points with zero external API calls.
   - Mode 2 (Production AI): If `GEMINI_API_KEY` is present, dispatches text to Gemini 2.0 / 1.5 Flash for deep abstractive synthesis.
4. UI renders clean Apple-style summary card view with copy-to-clipboard, export to Markdown/TXT, and page reference chips.

**Acceptance Criteria (Testable)**
- WHEN running locally without external API keys THE SYSTEM SHALL execute local extractive summarization and pass automated tests with 0 cloud dependencies.
- WHEN provided with a 20-page document THE SYSTEM SHALL produce structured Executive Summary and bulleted Takeaways.

**Estimate:** M | **Depends on:** UC-016

---

### UC-032: Original Educational SEO Content Hub & AdSense Indexation

**Linked Story:** AdSense & SEO  
**Actor:** Google AdSense Crawler / Web Visitor  
**Trigger:** Visitor navigates to `/kb/pdf-tools` or search engine crawls site.  

**Preconditions**
- [ ] Active branch `freepdftoolz/UC-032-adsense-hub`.

**Main Flow**
1. Author comprehensive, high-value educational guides for each of the 15 PDF tools under `/kb/pdf-tools/*` (e.g. *“PDF Merging: Object Streams & Cross-Reference Tables”*, *“True Cryptographic Redaction vs Black Box Overlays”*, *“Lossless vs Lossy PDF Compression”*).
2. Embed authoritative GitHub reference links (PyMuPDF, pdf2docx, qpdf) and ISO 32000 specification diagrams.
3. Generate valid Schema.org `SoftwareApplication` and `FAQPage` JSON-LD markup.
4. Update `sitemap.xml` and `robots.txt` ensuring full search engine discovery and Google AdSense site approval qualification.

**Acceptance Criteria (Testable)**
- WHEN crawler requests `/kb/pdf-tools` THE SYSTEM SHALL return original educational articles containing valid schema markup and external open-source references.
- WHEN sitemap.xml is parsed THE SYSTEM SHALL list canonical URLs for all 15 tool landing pages.

**Estimate:** M | **Depends on:** UC-016


