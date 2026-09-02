# Zero-Context Ticket Dispatch Prompt: UC-009-GAM

> **Ticket ID:** `UC-009-GAM`  
> **Title:** Google Ad Manager (GAM / AdX) GPT Integration & 31s Declared Auto-Refresh  
> **Target Phase:** Stage 02 — Production Release & AdX Monetization Integration  
> **Linked Specification:** [`product-specs/06b-carry-forward-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06b-carry-forward-tickets.md)  
> **Engineering Governance:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Goal & Context
Standard Google AdSense tags prohibit custom client-side JavaScript interval timers. To support high-frequency ad revenue while remaining 100% Google policy compliant, integrate **Google Ad Manager (GAM / AdX)** using **Google Publisher Tags (GPT `gpt.js`)**. This enables declared 31-second server-side ad refresh inventory slots coupled with viewability focus listeners.

---

## 2. Key Deliverables & Code Artifacts

1. **Global Script Injection (`src/frontend/web/index.html`):**
   - Async GPT library injection: `<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>`.
   - Define slot `/1234567/freeocr_leaderboard_728x90` with `googletag.pubads().enableSingleRequest()` and `collapseEmptyDivs()`.

2. **Flutter Web Native GAM Container (`src/frontend/lib/widgets/gam_banner.dart`):**
   - Render GAM slot via Flutter `HtmlElementView`.
   - Implement `GamBannerWidget.refreshGamSlot()` to dispatch custom window event `'refresh_gam_ad'`.
   - Add browser tab viewability listener (pausing refresh when tab is hidden/inactive).

3. **Automated Unit & Widget Tests (`src/frontend/test/widgets/gam_banner_test.dart`):**
   - Test GAM container rendering and slot registration without runtime exceptions.

---

## 3. Acceptance Criteria
- [ ] GAM ad slot defined via `gpt.js` in `src/frontend/web/index.html`.
- [ ] `GamBannerWidget` created in `src/frontend/lib/widgets/gam_banner.dart`.
- [ ] Conversion stage trigger dispatches `googletag.pubads().refresh()` call.
- [ ] Viewability observer pauses ad refresh when browser window/tab is blurred or hidden.
- [ ] 100% of automated tests pass locally.

---

## 4. Execution Commands
- **Run Backend Tests:** `pytest src/tests/ -v`
- **Run Frontend Tests:** `C:\flutter\bin\flutter.bat test`
