# Dispatch Prompt: AdSense Content Depth, Anti-Cloaking & E-E-A-T Overhaul

> **Task ID:** `PROD-04-ADSENSE-CONTENT-OVERHAUL`  
> **Target Branch:** `main` (or active feature branch)  
> **Target Environment:** `src/frontend` (Flutter & Static HTML) + `src/backend` (Contact API)  
> **Goal:** Eliminate AdSense "Low Value Content" hazard and search engine cloaking penalties by expanding site-wide editorial reading depth to 1,250+ words on Home, 5 full guides on Knowledge Base, enhanced About Us authority, and active Contact Us form.

---

## 1. Objective & Problem Statement

An evaluation of `freeOCR.me` flagged a critical **"Content Depth & Value ⚠️ High Risk: Low Value Content"** hazard.
1. The root cause: In [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html), the raw HTML text read by crawlers was only **~194 words**.
2. Worse, that text was placed inside `style="position: absolute; left: -9999px; opacity: 0;"`, which Googlebot and AdSense bots classify as **off-screen cloaked text** (a direct Google Webmaster guideline violation).
3. Google AdSense requires real, publisher-grade reading material, clear site authority (E-E-A-T), and working communication channels.

---

## 2. Step-by-Step Execution Plan

### Step 1: Home Page Anti-Cloaking & Semantic Editorial Expansion
- **File:** `src/frontend/web/index.html`
- **Actions:**
  1. Remove `position: absolute; left: -9999px; opacity: 0; pointer-events: none;`.
  2. Implement an accessible, naturally flowing semantic `<article>` container that provides **1,250+ words** of crawlable technical content directly in the initial HTML response:
     - Section 1: *Dual-Layer Searchable PDF Architecture (ISO 32000-1 Standard)*
     - Section 2: *Dual-Engine Neural Routing: CPU (OCRmyPDF/Tesseract) vs. GPU (Baidu Unlimited OCR)*
     - Section 3: *Step-by-Step Conversion Guide for Scanned Books, Receipts, and Legal Documents*
     - Section 4: *Ephemeral RAM-Disk Security Guarantee (Linux `tmpfs` Zero-Retention)*
     - Section 5: *8-Question Technical FAQ* with `Schema.org/FAQPage` structured data.
  3. Mirror this rich editorial content in Flutter's [`landing_faq_section.dart`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/lib/widgets/landing_faq_section.dart) for human reviewers scrolling the page.

### Step 2: Expand Knowledge Base to 5 Complete Technical Guides
- **Files:** `src/frontend/web/knowledge-base/index.html`, `src/frontend/web/kb/index.html`, and `src/frontend/lib/pages/kb_page.dart`
- **Actions:**
  Expand from 3 articles to 5 comprehensive, practical guides:
  1. *Dual-Layer Searchable PDF Architecture (ISO 32000-1 & Invisible Font Render Mode 3)*
  2. *How to Extract Clean Text from Low-Resolution Scans, Faded Receipts & Distorted Documents* (Radon deskewing, adaptive Otsu binarization, DPI upscaling).
  3. *Why Structured Markdown (.md) is Superior to Plain Text (.txt) for OCR Output* (heading hierarchy, tables, code blocks, LLM ingestion).
  4. *The Evolution of Document Interchange: PostScript, PDF 1.0, and Long-Term PDF/A Archiving*
  5. *Kernel-Level Zero-Retention Security: Operating Ephemeral AI Workloads in Linux tmpfs RAM Disks*

### Step 3: Flesh Out About Us Page for E-E-A-T Authority
- **Files:** `src/frontend/web/about/index.html` and `src/frontend/lib/pages/about_page.dart`
- **Actions:**
  Expand the narrative to 800+ words:
  - Explain the founding mission: why `freeOCR.me` is committed to being permanently free without subscriptions or paywalls.
  - Transparent technology stack attribution: deep learning models (PaddleOCR, Tesseract, OCRmyPDF, MuPDF).
  - Monetization transparency: explaining how non-intrusive AdSense ads and rewarded videos sustain cloud GPU/CPU compute without selling or retaining user data.
  - Ephemeral privacy guarantees and automated RAM-disk janitor protocols.

### Step 4: Activate Contact Us Form & Communication Channels
- **Files:** `src/frontend/web/contact/index.html`, `src/frontend/lib/pages/contact_page.dart`, and `src/backend/app/api/v1/endpoints/contact.py`
- **Actions:**
  1. Add `POST /api/v1/contact` endpoint to `src/backend` validating name, email, category, subject, and message.
  2. Connect the static HTML form and Flutter form to this endpoint with immediate user feedback.
  3. Prominently display direct support channels: `support@freeocr.me` and `privacy@freeocr.me` with a clear 24–48 hour response SLA.

### Step 5: Verification, Building & Deployment
1. Run Flutter unit & widget tests: `cd src/frontend; flutter test`.
2. Run backend tests: `pytest src/tests/ -v`.
3. Audit word count and cloaking: ensure `index.html` contains >1,200 words and 0 off-screen CSS hacks.
4. Compile production web bundle: `flutter build web --release --no-wasm-dry-run`.
5. Sync updated static pages into `src/frontend/build/web/`.
6. Deploy to Firebase Hosting: `firebase deploy --only hosting --non-interactive`.
7. Verify live pages with curl on `https://freeocr.me`, `/kb`, `/about`, and `/contact`.

---

## 3. Definition of Done (DoD)
- [ ] Home page (`index.html`) contains 1,250+ words of pre-rendered, crawlable semantic HTML copy.
- [ ] Off-screen cloaking CSS (`left: -9999px; opacity: 0`) is completely eliminated.
- [ ] Knowledge Base has 5 distinct, informative guides live on both web and Flutter.
- [ ] About Us page contains 800+ words of publisher authority and E-E-A-T content.
- [ ] Contact Us page features a working contact form and verified email channels (`support@freeocr.me`, `privacy@freeocr.me`).
- [ ] All automated tests pass 100%.
- [ ] Successfully deployed to Firebase Hosting and confirmed live.
- [ ] No unprompted local commits or remote git pushes without explicit user instruction.
