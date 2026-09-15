# TASK DISPATCH: Implement UC-034 (FreePDFToolz Google Analytics 4 Telemetry & Domain-Aware Tracking)

> **Ticket:** `UC-034`  
> **Sprint:** `Sprint F3` (FreePDFToolz AI, Conversions, Custom Domain & Live Launch)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 03/UC-034-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2003/UC-034-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated verification tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-034-ga4-telemetry` checked out from `dev`. NEVER push directly to `main`.
5. **Zero Data Cross-Contamination:** Traffic to `freepdftoolz.me` MUST NOT be mixed into `freeocr.me` GA4 property (`G-E852V95BXB`). The two domains must track analytics into separate, isolated measurement containers.

---

## 2. Ticket Specification — UC-034

**Ticket ID:** UC-034  
**Name:** FreePDFToolz Google Analytics 4 (GA4) Telemetry & Domain-Aware Tracking  
**Epic:** Epic 8 (FreePDFToolz AI, Conversions, Custom Domain & Live Launch)  
**Actor:** Anonymous Web Visitor / GA4 Measurement Engine  
**Trigger:** User visits any FreePDFToolz route or interacts with conversion tools on `freepdftoolz.me`.  

### Preconditions
- [x] Domain `freepdftoolz.me` registered and mapped to Firebase Hosting / Cloud Run.
- [ ] Active branch set to `freepdftoolz/UC-034-ga4-telemetry` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-034-ga4-telemetry
  ```

---

## 3. Main Implementation Steps

#### Step 1: Host-Aware GA4 Initialization in `src/frontend/web/index.html`
1. Update `src/frontend/web/index.html`:
   - Implement dynamic measurement ID resolution based on `window.location.hostname`:
     - If hostname matches `*freepdftoolz*`: Load FreePDFToolz GA4 tag (configurable via environment/meta tag or default property `G-PDFTOOLZ_ID`).
     - If hostname matches `*freeocr*`: Load `G-E852V95BXB`.
     - In local development (`localhost` / `127.0.0.1`): Log analytics dispatch cleanly to console in debug mode without emitting false production metrics.
   - Ensure JS interop bridge (`window.trackGa4PageView` and `window.trackGa4Event`) sends data to the active property.

#### Step 2: Full Audit & Telemetry Injection Across All FreePDFToolz Pages
1. Audit all 15 FreePDFToolz pages and ensure 100% coverage:
   - **Hub & Info**:
     - `/pdf-tools` (`pdf_tools_hub_page.dart`): `TelemetryService.trackPageView('/pdf-tools', pageTitle: 'FreePDFToolz — All PDF Tools')`.
   - **Page Operations**:
     - `/merge` & `/merge/process`
     - `/split` & `/split/process`
     - `/rotate` & `/rotate/process`
     - `/delete-pages` & `/delete-pages/process`
     - `/extract-pages` & `/extract-pages/process`
     - `/number-pages` & `/number-pages/process`
   - **Transformation & Security**:
     - `/compress` & `/compress/process`
     - `/watermark` & `/watermark/process`
     - `/crop` & `/crop/process`
     - `/redact` & `/redact/process`
     - `/sign` & `/sign/process`
   - **AI & Conversions**:
     - `/annotate` & `/annotate/process`
     - `/edit-text` & `/edit-text/process`
     - `/pdf-to-word` & `/pdf-to-word/process`
2. Standardize custom conversion events in `TelemetryService`:
   - `tool_upload_started`: `{ tool: String, file_size_kb: double }`
   - `tool_process_completed`: `{ tool: String, duration_ms: int, pages: int }`
   - `tool_download_clicked`: `{ tool: String, file_size_kb: double }`
   - `rewarded_ad_watched`: `{ tool: String, boost_mb: double }`

#### Step 3: SEO Compiler Static HTML Injection (`scripts/build_seo_pages.py`)
1. Update static SEO compiler to inject the host-aware GA4 snippet on all generated pre-rendered static HTML files for `freepdftoolz.me`.

---

## 4. TDD Test Plan (Write First!)

### Frontend Telemetry Tests (`src/frontend/test/services/telemetry_service_test.dart`):
1. `test_track_page_view_dispatches_for_freepdftoolz_routes()`: Verifies calling `trackPageView('/sign/process')` invokes interop with expected route and title.
2. `test_tool_conversion_events_format()`: Verifies `tool_process_completed` dispatches with proper parameters.
3. `test_all_tool_landing_pages_invoke_telemetry()`: Verifies widget tests check `TelemetryService.trackPageView` was called on initialization.

### Backend SEO Integration Tests (`src/tests/test_seo_pages.py`):
1. `test_seo_pages_inject_domain_aware_ga4_tag()`: Validates compiled static HTML files contain correct GA4 container script for their respective domains.

---

## 5. Verification Commands
```powershell
# 1. Run Telemetry Tests
cd src/frontend
flutter test test/services/telemetry_service_test.dart

# 2. Run Static SEO Generator & Pytest
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_seo_pages.py -v
```
