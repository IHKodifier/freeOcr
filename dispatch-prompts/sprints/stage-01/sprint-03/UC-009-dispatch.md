# Zero-Context Ticket Dispatch Prompt: UC-009 (Configurable AdSense Display Ad Banner Auto-Rotation Timer)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-009  
> **Feature Name:** Configurable AdSense Display Ad Banner Auto-Rotation Timer  
> **Prerequisites Completed:** Sprint 0, Sprint 1 & Sprint 2 (100% Passed)

---

## 1. Context & Specification Summary
In Sprint 3, we implement display ad monetization and configurable rotation:
- The rotation duration is **runtime configurable** via `ad_rotation_interval_seconds` in `src/backend/app/app_limits_config.json` (served by `GET /api/v1/config`).
- Changing `ad_rotation_interval_seconds` in `app_limits_config.json` updates rotation timing dynamically for all users without requiring a rebuild or redeployment of the Flutter frontend application.
- The Flutter `AdSenseBanner` widget renders a leaderboard/card ad container on Landing (`/`) and Download Preview (`/result/{job_id}`).
- The rotation timer automatically pauses when the user switches tabs or blurs the window.

---

## 2. Goals & Objectives for UC-009
1. **Backend Config Provider (`src/backend/app/app_limits_config.json` & `config.py`):**
   - Ensure `ad_rotation_interval_seconds` is present in `app_limits_config.json` (default `35`).
   - Verify `GET /api/v1/config` returns `monetization.ad_rotation_interval_seconds`.

2. **Flutter AdSense Banner Component (`src/frontend/lib/widgets/adsense_banner.dart`):**
   - Build `AdSenseBanner` widget fetching rotation interval from `ApiService`.
   - Implement dynamic auto-rotation timer refreshing ad units every `ad_rotation_interval_seconds` seconds.
   - Pause timer on window blur / tab switch and resume on focus.

3. **Automated Verification:**
   - Create unit tests in `src/tests/test_adsense_config.py` verifying dynamic configuration loading.
   - Create Flutter test in `src/frontend/test/widgets/adsense_banner_test.dart` verifying ad banner rendering and timer lifecycle.
   - Run `$env:PYTHONPATH="src/backend"; .\.venv\Scripts\python.exe -m pytest src/tests/ -v` and `C:\flutter\bin\flutter.bat test`.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.03-tracker.md`, `trackers/stage-01/07.01-tracker.md`, and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-009: Configurable AdSense Display Ad Banner Auto-Rotation Timer.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Verify GET /api/v1/config returns ad_rotation_interval_seconds from app_limits_config.json.
3. Build Flutter AdSenseBanner widget in src/frontend/lib/widgets/adsense_banner.dart with dynamic auto-rotation interval and tab blur pause.
4. Add automated test coverage and ensure 100% of Pytest and Flutter tests pass.
5. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
