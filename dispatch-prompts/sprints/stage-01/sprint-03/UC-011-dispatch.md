# Zero-Context Ticket Dispatch Prompt: UC-011 (Rewarded Ad Callback & Stackable Session Limit Boost Pass)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-011  
> **Feature Name:** Rewarded Ad Callback & Stackable Session Limit Boost Pass  
> **Prerequisites Completed:** UC-010 (Passed)

---

## 1. Context & Specification Summary
In UC-011, we implement the backend ad callback endpoint and stackable boost pass issuance:
- `POST /api/v1/ad/reward-callback` validates ad completion tokens and stores a sliding 60-minute TTL boost pass in Redis (`ad_pass:{client_ip}`).
- Each ad watched stacks limit boosts (e.g. +20MB per ad up to 500MB max stack).

---

## 2. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-011: Rewarded Ad Callback & Stackable Session Limit Boost Pass.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Implement backend POST /api/v1/ad/reward-callback in ocr.py / jobs.py and Redis ad_pass tracking.
3. Wire Flutter RewardedVideoAdModal callback to refresh active user limit passes.
4. Ensure 100% of Pytest and Flutter test suites pass cleanly.
5. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
