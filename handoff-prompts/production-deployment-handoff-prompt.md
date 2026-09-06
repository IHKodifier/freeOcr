# Production Deployment Handoff Prompt: freeOCR.me

> **Usage:** Copy and paste the text block below directly into a brand new chat session to resume work with maximum token and context efficiency.

---

```markdown
I am resuming work on the **freeOCR.me** project for the final Production Deployment phase.

### Current State Summary:
- **Git Branch:** `dev` is synchronized with `origin/dev` at commit `5c2da0c`. Working tree is clean.
- **Backlog Status:** All 20 tickets (`UC-000a` through `UC-015`, `UC-005b`, `UC-009-GAM`) are 100% complete and verified.
- **Automated Tests:** 
  - Backend: 12/12 Pytest tests PASS (`pytest src/tests/ -v`)
  - Frontend: 40/40 Flutter unit & widget tests PASS (`flutter test`)
- **Staging URL:** https://freeocr-staging-app.web.app (Firebase Hosting)
- **API URL:** https://freeocr-api-769079187163.us-central1.run.app (Cloud Run, scale-to-zero)
- **Key Architectures Confirmed:**
  1. Dual-Engine OCR: OCRmyPDF on CPU (simple layouts) + Baidu Unlimited OCR ~6GB model on GPU (complex layouts), both scaling to 0 when idle.
  2. Searchable PDF Reconstruction: PyMuPDF overlays invisible text layers (`render_mode=3`) using scaled bounding boxes directly onto original scanned bitmaps.
  3. Ad Placement: Dedicated in-app GAM slots (`div-gpt-ad-...`) governed by GAM server-side declared refresh (timeout set to 60s for higher RPM, active only when visitor stays long enough with the page in the foreground) + AdSense fallback.
  4. Stable Web App Viewport: `user-scalable=no` eliminates black voids and corner-pinning; document viewer has pivot-centered zoom.

### Relevant Governance & Architecture Files:
1. Engineering Governance: `.agents/AGENTS.md` (Strict commit/push rules, TDD, scale-to-zero mandate)
2. Master Tracker: `trackers/master-tracker.md`
3. Production Deployment Plan: `handoff-prompts/production-deployment-plan.md`

### Goal for this Session:
Execute the 6-phase production deployment outlined in `handoff-prompts/production-deployment-plan.md`:
- **Phase 1:** Verify tests locally, perform fast-forward merge from `dev` into `main`, and create release tag `v1.0.0-prod`.
- **Phase 2:** Register `freeocr.me` and configure custom domain routing on Firebase Hosting and DNS.
- **Phase 3:** Deploy production GCP Cloud Run service and GPU worker for Baidu Unlimited OCR (~6GB model, cached in Cloud Storage, scale-to-zero) with production secrets.
- **Phase 4:** Validate Searchable PDF reconstruction pipeline end-to-end (`test_complex_pdf_reconstruction.py`).
- **Phase 5:** Verify SEO pre-rendered HTML pages and deploy production `ads.txt` and GAM network slot IDs.
- **Phase 6:** Execute end-to-end smoke test on live production domain and verify GA4 telemetry dashboard.

Please read `handoff-prompts/production-deployment-plan.md` and await my confirmation before executing any production merges or deployments.
```
