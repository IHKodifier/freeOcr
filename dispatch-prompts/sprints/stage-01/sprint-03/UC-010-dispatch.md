# Zero-Context Ticket Dispatch Prompt: UC-010 (Limit Exceeded Detection & Rewarded Video Ad Modal)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-010  
> **Feature Name:** Limit Exceeded Detection & Rewarded Video Ad Modal  
> **Prerequisites Completed:** UC-009 (Passed)

---

## 1. Context & Specification Summary
In UC-010, we implement limit exceeded detection when users attempt to upload files exceeding session quotas or file size caps (`BASE_MAX_FILE_MB` in `app_limits_config.json`):
- When a file exceeds the session limit (e.g. 15MB file vs 10MB limit), the frontend displays a frosted glass Rewarded Video Ad Modal.
- The modal invites the user to watch a short video ad to unlock a stackable limit boost pass.

---

## 2. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-010: Limit Exceeded Detection & Rewarded Video Ad Modal.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Build client-side limit exceeded evaluator and frosted glass RewardedVideoAdModal component.
3. Ensure 100% of Pytest and Flutter test suites pass cleanly.
4. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
