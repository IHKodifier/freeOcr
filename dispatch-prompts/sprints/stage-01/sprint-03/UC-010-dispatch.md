# Zero-Context Ticket Dispatch Prompt: UC-010 (Limit Exceeded Detection & Rewarded Video Ad Modal)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-010  
> **Feature Name:** Limit Exceeded Detection & Rewarded Video Ad Modal  
> **Prerequisites Completed:** UC-009 (Passed)

---

## 1. Context & Specification Summary
In UC-010, we implement limit exceeded detection when users attempt to upload files exceeding session quotas or file size caps (`base_max_file_mb` in `app_limits_config.json`):
- When a file exceeds the session limit (e.g. 15MB file vs 10MB limit), the frontend displays a frosted glass Rewarded Video Ad Modal.
- The modal invites the user to watch a short video ad to unlock a stackable limit boost pass.

---

## 2. Goals & Objectives for UC-010
1. **Branch Workflow:**
   - Checkout dedicated feature branch from `dev`: `git checkout -b feature/UC-010` (or `sprint/sprint-03-uc-010`).

2. **Frontend Limit Evaluator & Rewarded Modal:**
   - Build client-side limit evaluator comparing upload file size against `base_max_file_mb`.
   - Build frosted glass `RewardedVideoAdModal` inviting user to watch a 15s video ad.

3. **Automated Verification:**
   - Add test coverage in Pytest and Flutter test suite ensuring 100% pass rates.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.03-tracker.md` and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-010: Limit Exceeded Detection & Rewarded Video Ad Modal.

1. Checkout dedicated feature branch from dev: `git checkout -b feature/UC-010` (or `sprint/sprint-03-uc-010`).
2. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
3. Build client-side limit exceeded evaluator and frosted glass RewardedVideoAdModal component.
4. Ensure 100% of Pytest and Flutter test suites pass cleanly.
5. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
