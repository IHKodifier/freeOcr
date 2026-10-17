# TASK DISPATCH: TICKET-07 — Testing, CLS Layout Shift Audit & Deployment Governance

> **Ticket ID:** `MONETIZE-07`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 20 Minutes  
> **Actor:** Coding Agent & Publisher  
> **Target Files:**  
> - [`src/frontend/web/ads.txt`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/ads.txt)  
> - [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py)  
> - [`src/frontend/web/kb/`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/kb/)  
> **Governance Mandate:** Strictly adheres to [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) Sections 2.1 & 2.2

---

## 1. Context & Objectives

Before any code is committed or published to production, it must undergo thorough quality assurance to ensure that monetized ad units do not break user experience, degrade Core Web Vitals, or introduce layout shifts.

Once verification passes 100%, deployment to Cloud Run and Firebase Hosting must follow the **Strict Git Authorization & Dual-Domain Deployment Protocol** defined in `.agents/AGENTS.md`.

---

## 2. Quality Assurance & Verification Checkpoints

### Test 1: Cumulative Layout Shift (CLS) Audit
- Open `src/frontend/web/kb/ocr-guide/index.html` in Chrome DevTools.
- Open the **Performance** or **Lighthouse** tab and record a page load.
- **Verification Rule:** Cumulative Layout Shift (CLS) must be **< 0.05** (Good).
  - *Reason:* The `.ads-card` container has hardcoded CSS dimensions (`min-height: 250px; min-width: 300px;`), meaning space is reserved before the ad network fills the creative. Text does not jump when the ad loads.

### Test 2: Ad-Blocker Graceful Degradation
- Enable uBlock Origin or Brave Shields.
- Reload the page.
- **Verification Rule:** The page must render cleanly:
  - No broken image icons (`[x]`).
  - No empty 800px whitespace gaps.
  - Native affiliate recommendation card remains fully visible and legible.
  - OCR upload dropzone on homepage operates with zero degradation.

### Test 3: Responsive Viewport Check
- **Desktop (1920x1080 / 1440x900):** Sticky Monetag rail is visible on the right; in-content Adsterra banner renders cleanly above CTA.
- **Laptop (1280x800):** Grid collapses to 2 columns; ad rail is cleanly hidden via media query; article remains readable.
- **Mobile (375x667 iPhone SE / 412x915 Pixel):** Single-column layout; zero horizontal scrolling.

### Test 4: Automated Test Suites
Run the automated test suites from project root:

```powershell
# 1. Run Python backend test suite
pytest src/tests/ -v

# 2. Run Flutter frontend test suite
cd src/frontend
flutter test
cd ../..
```

Both test suites must return **100% green passing tests**.

---

## 3. Strict Git & Deployment Governance Protocol

Per **Section 2.1 & 2.2 of `.agents/AGENTS.md`**:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                     STRICT COMMIT & PUSH AUTHORIZATION PROTOCOL                        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 1. NO UNPROMPTED LOCAL COMMITS:                                                        │
│    The agent MUST NEVER run `git commit` without explicit user instruction.           │
│                                                                                        │
│ 2. NO UNPROMPTED REMOTE PUSHES:                                                        │
│    The agent MUST NEVER run `git push` without explicit user instruction.              │
│                                                                                        │
│ 3. MANDATORY INTERACTIVE UI MODAL:                                                     │
│    Antigravity MUST prompt the user via `ask_question` with selectable options:        │
│    • (•) freeocr.me (Only) — Tags merge/commit with [deploy:freeocr]                   │
│    • ( ) freepdftoolz.me (Only) — Tags merge/commit with [deploy:freepdftoolz]         │
│    • ( ) Both (freeocr.me + freepdftoolz.me) — Tags merge/commit with [deploy:both]     │
│    • ( ) Skip Deployment (Automated Tests Only) — Tags commit with [skip deploy]       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Final Handoff & Go-Live Checklist

- [ ] All 23 static KB guides regenerated and confirmed containing live Monetag + Adsterra + Affiliate tags.
- [ ] Root `ads.txt` contains verified publisher lines.
- [ ] `privacy/index.html` contains Section 4.5 ad disclosure.
- [ ] Pytest & Flutter tests pass 100%.
- [ ] User authorization granted for commit and push tagged with `[deploy:freeocr]`.
- [ ] First impression telemetry verified in Monetag and Adsterra portals.
- [ ] First payout recorded in `00-PROGRESS-TRACKER.md`.
