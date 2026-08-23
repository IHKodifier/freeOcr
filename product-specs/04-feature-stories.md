# Feature Stories: freeOCR.me

> **Stage:** 4 — Feature Stories & Epics  
> **Persona:** SaaS Founder × Product Designer  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`02-architecture.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/02-architecture.md), [`03-user-journeys.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/03-user-journeys.md)  
> **Last Updated:** 2026-08-23  

---

## Epic Overview

| # | Epic Name | Business & User Goal | MVP? | Complexity | Priority |
|---|-----------|----------------------|------|-----------|---------|
| **E1** | **Zero-Friction Conversion Engine** | Instant drag-and-drop file upload, SSE progress streaming, PaddleOCR-VL 1.6 execution | ✅ | High | P0 |
| **E2** | **Preview & Multi-Format Export** | Interactive split viewer, 3-format downloads (`.pdf`, `.txt`, `.md`), email link delivery & purge | ✅ | Medium | P0 |
| **E3** | **Ad Monetization & Rewarded Boosts** | 35-second ad rotation timer, limit detection, rewarded ad 60-minute session pass | ✅ | Medium | P0 |
| **E4** | **PDF Error Handling & Auto-Repair** | Password-in-place decryption, corrupted scan repair, 60s `tmpfs` watchdog cleaner | ✅ | Medium | P1 |
| **E5** | **Firebase Auth & Paid Subscriptions** | User accounts, Stripe billing, ad-free experience, opt-in GCS user vault | ❌ | High | P2 (Post-MVP) |
| **E6** | **Developer API & Native App Compilations** | API keys, usage metered rate-limits, native iOS/Android/Desktop Flutter builds | ❌ | High | P3 (At Scale) |

---

## Epic 1: Zero-Friction Conversion Engine

**Goal:** Allow users to upload scanned PDFs/images on the landing hero and convert them using Baidu PaddleOCR-VL 1.6 (0.9B) without account registration.  
**Traces to:** `01-product-brief.md` — Core problem (inaccurate OCR, paywalls, untrusted servers).

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-101** | As an anonymous user, I want to drag & drop a PDF/image onto the hero zone so that my file is validated instantly. | - [ ] Dropzone highlights on file drag hover.<br>- [ ] Validates format (`.pdf`, `.png`, `.jpg`, `.jpeg`).<br>- [ ] Checks page cap & file size against `config.py` defaults.<br>- [ ] Displays instant error toast if format invalid. | ✅ | P0 |
| **US-102** | As an uploading user, I want real-time conversion progress so that I know the system is actively processing my pages. | - [ ] Initiates Server-Sent Events (SSE) stream (`GET /api/v1/jobs/{job_id}/events`).<br>- [ ] Displays progress bar with page indicator (`Page 3 of 8 converted... 37%`).<br>- [ ] Displays subtle micro-animation during processing. | ✅ | P0 |
| **US-103** | As the backend OCR engine, I want to process files in a Linux `tmpfs` RAM disk so that zero customer data touches persistent disk storage. | - [ ] Incoming PDF written to RAM disk (`/tmp/ephemeral_<job_id>.pdf`).<br>- [ ] PaddleOCR-VL 1.6 executes PyTorch/Paddle vision-language inference.<br>- [ ] Input file unlinked from RAM disk instantly upon job completion via Python context manager. | ✅ | P0 |
| **US-104** | As a user downloading a searchable PDF, I want 100% original visual layout preservation so that the output matches my scan perfectly. | - [ ] Original scan embedded as high-res 300 DPI background.<br>- [ ] Bounding polygon coordinates `[x_min, y_min, x_max, y_max]` map text precisely.<br>- [ ] Transparent (invisible) text layer overlaid over matching coordinates via PyMuPDF/fitz.<br>- [ ] `Ctrl+F` search & text copy-paste functional across entire PDF. | ✅ | P0 |

---

## Epic 2: Preview & Multi-Format Export

**Goal:** Provide an interactive split-screen preview and instant download options for Searchable PDF, Plain Text, and Markdown, plus optional email delivery.  
**Traces to:** `03-user-journeys.md` — Journey 1 (10-second Aha moment & download choices).

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-201** | As a user previewing conversion results, I want a side-by-side split viewer so I can compare original scan vs OCR text. | - [ ] Left pane renders original scan image.<br>- [ ] Right pane renders selectable OCR text with syntax/formatting.<br>- [ ] Responsive split-slider allows dragging to adjust pane ratio on Desktop & Mobile. | ✅ | P0 |
| **US-202** | As a user, I want 1-click download buttons for `.pdf`, `.txt`, and `.md` formats so I can get the exact format I need. | - [ ] Button 1: Download Searchable PDF (`.pdf`).<br>- [ ] Button 2: Download Plain Text (`.txt`).<br>- [ ] Button 3: Download Formatted Markdown (`.md`).<br>- [ ] Triggers direct browser download stream instantly. | ✅ | P0 |
| **US-203** | As a user, I want to email myself the download links so that I can access output files from another device within 24 hours. | - [ ] Email input field rendered on download page.<br>- [ ] Warning displayed: *"Input file is permanently purged as soon as 'Send Email' is clicked."*<br>- [ ] Dispatches email with 24h expiration links.<br>- [ ] Triggers immediate `os.remove()` purging of original input file in RAM. | ✅ | P1 |
| **US-204** | As an email recipient accessing an expired link, I want a clear message stating the link has expired so I understand why it is unavailable. | - [ ] Links set to 24-hour TTL in storage.<br>- [ ] If accessed after 24h, displays friendly page: *"This download link expired on [Date/Time in User's Local Time Zone]."* | ✅ | P1 |

---

## Epic 3: Ad Monetization & Rewarded Boosts

**Goal:** Monetize free traffic with 35-second rotating ad banners and offer a 60-minute rewarded ad session pass for high-volume files.  
**Traces to:** `01-product-brief.md` — Ad-supported freemium monetization strategy.

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-301** | As the website publisher, I want display ads to refresh every 35 seconds so that ad revenue is maximized while users stay on the page. | - [ ] Top leaderboard banner rendered above fold on Landing & Download pages.<br>- [ ] Automated 35-second timer script (`setInterval(refreshAds, 35000)`) refreshes ad slot when page tab is active. | ✅ | P0 |
| **US-302** | As a user uploading a file exceeding default limits, I want a clear modal offering a rewarded ad pass so I can process large files for free. | - [ ] Triggers when uploaded file exceeds `FREE_TIER_PAGE_LIMIT` or `FREE_TIER_MAX_FILE_MB`.<br>- [ ] Displays clean modal: *"Unlock 60-Minute Session Pass (Up to 50 Pages & 30MB)"* with **[Watch 15s Ad]** CTA. | ✅ | P0 |
| **US-303** | As a user who watched a rewarded ad, I want my temporary limit boost activated automatically so my conversion starts without delay. | - [ ] Rewarded ad completion callback fires from Google Mobile Ads SDK.<br>- [ ] Sets Redis key `ad_pass:{client_id}` with 3600-second TTL.<br>- [ ] Automatically initiates conversion job with elevated limit settings. | ✅ | P0 |

---

## Epic 4: PDF Error Handling & Auto-Repair

**Goal:** Gracefully handle encrypted, password-protected, or corrupted scanned PDFs.  
**Traces to:** `03-user-journeys.md` — Journey 4 (Encrypted & Corrupted PDF recovery).

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-401** | As a user with an encrypted PDF, I want an in-place password prompt so I can decrypt and convert my file directly. | - [ ] Detects PDF encryption flag upon upload.<br>- [ ] Displays inline password input dialog over dropzone.<br>- [ ] Passes password to backend decryptor; resumes OCR without requiring re-upload. | ✅ | P1 |
| **US-402** | As a user uploading a corrupted PDF, I want the system to attempt auto-repair so I don't lose my file. | - [ ] Catches PDF stream parsing exceptions in backend worker.<br>- [ ] Displays status toast: *"Your file has structural errors. Attempting PDF repair..."*<br>- [ ] Runs automated repair pipeline (`pdfcpu repair` / `qpdf` / `ghostscript`).<br>- [ ] Resumes OCR if repair succeeds. | ✅ | P1 |
| **US-403** | As the system administrator, I want a background watchdog cleaner process so that orphaned RAM files are guaranteed to be purged. | - [ ] Watchdog process runs every 30 seconds on worker node.<br>- [ ] Checks `/tmp` RAM disk for any file with `mtime` older than 60 seconds.<br>- [ ] Permanently unlinks orphan files to enforce zero-retention guarantee and prevent RAM exhaustion. | ✅ | P0 |

---

## Epic 5: Firebase Auth & Paid Subscriptions (Post-MVP)

**Goal:** Allow users to register accounts, subscribe to paid ad-free plans, and save non-sensitive PDFs to an opt-in GCP Cloud Storage vault.  
**Traces to:** `01b-tech-stack.md` — Post-MVP SaaS expansion.

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-501** | As a user, I want to create an account via Firebase Auth so I can manage my paid subscription. | - [ ] Firebase Auth integration (Google OAuth, Email/Password).<br>- [ ] User session token passed via `Authorization: Bearer` headers. | ❌ | P2 (Post-MVP) |
| **US-502** | As a user, I want to subscribe to a Paid Tier via Stripe so I can enjoy an ad-free experience with unlimited page limits. | - [ ] Stripe Checkout & Customer Portal integration.<br>- [ ] Suppresses display ads & rewarded ad prompts for active subscribers.<br>- [ ] Grants unlimited page & file size limits. | ❌ | P2 (Post-MVP) |
| **US-503** | As a paid subscriber, I want an opt-in GCP Cloud Storage vault so I can securely save output PDFs for long-term access. | - [ ] Toggle switch in account settings: *"Enable Secure GCS Output Vault"*.<br>- [ ] Encrypts and stores output PDFs in GCP Cloud Storage bucket.<br>- [ ] Provides user-managed file management dashboard. | ❌ | P2 (Post-MVP) |

---

## Epic 6: Developer API & Scale Integrations (At Scale)

**Goal:** Offer developer API keys and native cross-platform mobile/desktop apps at scale.  
**Traces to:** `01b-tech-stack.md` — Platform roadmap at scale.

### User Stories

| ID | Story | Acceptance Criteria | MVP? | Priority |
|----|-------|---------------------|------|---------|
| **US-601** | As a developer, I want API key authentication so I can integrate freeOCR.me OCR into my own applications. | - [ ] Developer portal for generating API keys.<br>- [ ] Rate-limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`).<br>- [ ] Metered usage tracking against Stripe Billing API. | ❌ | P3 (At Scale) |
| **US-602** | As a mobile user, I want native iOS and Android apps compiled from the shared Flutter codebase. | - [ ] Flutter mobile app compilation.<br>- [ ] Mobile camera document scanner integration. | ❌ | P3 (At Scale) |

---

## Out of Scope — v1 (MVP)

| Feature | Reason Deferred | Target Version |
|---------|----------------|----------------|
| **User Signups / Firebase Auth** | Zero signup barrier required for maximum MVP utility & traffic growth | v1.1 (Post-MVP) |
| **Stripe Paid Subscriptions** | MVP is 100% ad-supported freemium to validate usage demand first | v1.1 (Post-MVP) |
| **GCP Cloud Storage Output Vault** | Free MVP is strictly 100% ephemeral zero-retention (24h output link TTL) | v1.1 (Post-MVP) |
| **Developer API Portal** | Requires user accounts and metered billing infrastructure | v2.0 (At Scale) |
| **Native iOS / Android Apps** | Flutter Web handles Desktop & Mobile Web for MVP launch | v1.2 (Post-MVP) |
