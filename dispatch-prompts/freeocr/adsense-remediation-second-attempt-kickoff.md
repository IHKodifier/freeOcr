# Dispatch & Kickoff Prompt — AdSense Content Remediation (Second Attempt)

> **File:** `dispatch-prompts/freeocr/adsense-remediation-second-attempt-kickoff.md`  
> **Master Spec:** `product-specs/adsense-content-remediation-second-attempt.md`  
> **Compliance Benchmark:** `scripts/Test-AdSenseCompliance.ps1` & `scripts/adsense_compliance_benchmarking_suite.py`  
> **Target Branch:** `feature/adsense-remediation-second-attempt` (checked out from `dev`)

---

## Copy-Paste Kickoff Prompt for a Brand New Chat:

```markdown
Hello! I need you to execute the AdSense Content Remediation Plan (Second Attempt) for freeOCR.me to guarantee 100% Google AdSense publisher approval on our next 7-10 day review cycle.

### Context & Current State
- Domain: https://freeocr.me | Client ID: ca-pub-6775900998665017
- Site Ownership is already 100% verified (green checkmark in AdSense).
- Rejection reason: "Low value content" on brand new domain (launched Sep 6, 2026).
- Google Analytics 4 confirms genuine engagement: 98 active users, 1m 59s avg engagement, 6.1 views/session.
- Google Search has indexed our pages (visible on `site:freeocr.me`).
- Sitemaps are processed with 33 canonical pages.
- We have 23 comprehensive technical whitepapers (>83,000 words total across the site).

### Engineering Governance & Branching Mandate
1. Read `.agents/AGENTS.md` and adhere strictly to all repository governance rules.
2. Checkout a dedicated feature branch from `dev`:
   `git checkout dev`
   `git checkout -b feature/adsense-remediation-second-attempt`
3. NEVER commit locally or push remotely without explicit user instructions.
4. When committing/pushing/merging, use the interactive deployment selection tagging `[deploy:freeocr]`.

### Implementation Requirements (Governed by product-specs/adsense-content-remediation-second-attempt.md)
1. **Phase 1: Disable Service Worker Caching During Review Mode:**
   - In `src/frontend/web/index.html`, inject a script to unregister any stale service workers and bypass CacheStorage so human reviewers and Googlebot always load 100% live network assets.
2. **Phase 2: Prominent Landing Page Knowledge Base Showcase:**
   - On the root homepage (`https://freeocr.me`), ensure that human reviewers do NOT see only an isolated upload dropzone.
   - Mount a prominent, styled "Featured Knowledge Base & Engineering Guides" section below the dropzone in both the pre-mount HTML shell (`#editorial-content`) and the Flutter landing page view, linking directly into the 23 static HTML twin whitepapers.
3. **Phase 3: Universal AdSense Script Tag Coverage:**
   - Ensure the monetization snippet `<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6775900998665017" crossorigin="anonymous"></script>` is verified in `<head>` across all pages, including `about/index.html` and `contact/index.html`.
4. **Phase 4: Automated Benchmarking & Validation:**
   - Run our native PowerShell AdSense compliance test suite:
     `powershell -ExecutionPolicy Bypass -File .\scripts\Test-AdSenseCompliance.ps1 -TargetDir "src/frontend/web"`
   - Ensure it scores >= 95% pass rate.
   - Run `flutter test` and backend pytest suites to ensure 100% pass.

Please inspect `product-specs/adsense-content-remediation-second-attempt.md`, check out the dedicated branch, and present your execution roadmap before starting code changes.
```
