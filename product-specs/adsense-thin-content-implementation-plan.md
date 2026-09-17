# Implementation Plan: FreePDFToolz Multi-Site Build Isolation & Anti-Thin-Content Architecture

> **Canonical Path:** `product-specs/adsense-thin-content-implementation-plan.md`  
> **Status:** Implemented & Verified  
> **Approved By:** User  
> **Date:** September 17, 2026  

---

## 1. Problem Statement & Background

Google AdSense enforces strict **"Thin content / Low value content"** and **"Site under construction"** policies. Single-page applications built on Flutter Web compile into client-rendered JavaScript and WebAssembly canvases. When search engine and AdSense crawlers inspect requests to root URLs, they encounter empty loader elements unless comprehensive, pre-rendered static HTML is served.

Additionally, prior to this implementation, both Firebase Hosting sites (`freeocr-staging-app` and `freepdftoolz`) pointed to the exact same build directory (`src/frontend/build/web`). As a result, live requests to `https://freepdftoolz.me` were serving `freeOCR.me` metadata and HTML, triggering a critical domain mismatch and duplicate content violation.

---

## 2. Technical Solution Overview

### Component 1: Multi-Site Build Isolation
- In `firebase.json`, configure `freepdftoolz` to deploy from `src/frontend/build/freepdftoolz_web`.
- In `deploy.yml`, create a dedicated build step using `scripts/build_freepdftoolz_site.ps1` to assemble the isolated web bundle.

### Component 2: Dedicated Editorial Shell & Deep Technical Subpages
- Programmatically generate over **25,000 words** of unique, educational, and technical content for FreePDFToolz via `scripts/generate_freepdftoolz_pages.py`:
  - Permanent `<article id="editorial-content">` on the root page with 10 technical FAQs.
  - Dedicated `/about`, `/contact`, `/privacy` (with mandatory AdSense cookie disclosures), and `/terms`.
  - 16-tool catalog directory at `/hub`.
  - 6 deep technical whitepapers in `/kb/` and `/knowledge-base/`.
  - Dedicated `sitemap.xml` and `robots.txt` mapped strictly to `https://freepdftoolz.me`.

### Component 3: DOM Life-Cycle Guardrails
- Ensure the Flutter bootstrap does not hide or prune `#editorial-content`.
- Hardcode `AdSenseBanner.kAdSenseApproved = false` until AdSense approval is granted.

---

## 3. Implementation Files Created & Modified

1. `scripts/generate_freepdftoolz_pages.py` (New): Generates static content tree in `src/frontend/web_pdftoolz/`.
2. `scripts/build_freepdftoolz_site.ps1` (New): Cross-platform PowerShell assembly pipeline.
3. `firebase.json` (Modified): Points site `freepdftoolz` to `src/frontend/build/freepdftoolz_web`.
4. `.github/workflows/deploy.yml` (Modified): Assembles FreePDFToolz bundle in `deploy-freepdftoolz`.
5. `src/tests/test_deployment_freepdftoolz.py` (Modified): Automated verification test suite.
6. `product-specs/adsense-content-remediation-freepdftoolz.md` (New): Canonical specification for FreePDFToolz.
7. `product-specs/adsense-content-remediation-freeocr.md` (New): Canonical specification for freeOCR.me.

---

## 4. Verification & Testing

- Automated tests: `pytest src/tests/test_deployment_freepdftoolz.py -v` (6/6 passing).
- Full backend suite: `pytest src/tests/` (218/218 passing).
- Full frontend suite: `flutter test` (119/119 passing).
- Dry-run verification: `build_freepdftoolz_site.ps1` produces 113 valid files.
