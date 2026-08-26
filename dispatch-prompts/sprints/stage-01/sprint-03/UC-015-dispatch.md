# Zero-Context Ticket Dispatch Prompt: UC-015 (AdSense-Qualifying Content KB, Docs & GitHub Footer)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-015  
> **Feature Name:** AdSense-Qualifying Content KB, Docs & GitHub Footer  
> **Prerequisites Completed:** UC-014 (Passed)

---

## 1. Context & Specification Summary
In UC-015, we implement educational knowledgebase and API documentation content to pass Google AdSense publisher site quality reviews:
- `/kb` route: Knowledge Base (OCR guide, scanned PDF troubleshooting, privacy security).
- `/docs` route: API Documentation & architectural specifications.
- Global footer with GitHub repository link and open-source attribution.

---

## 2. Goals & Objectives for UC-015
1. **Branch Workflow:**
   - Checkout dedicated feature branch from `dev`: `git checkout -b feature/UC-015` (or `sprint/sprint-03-uc-015`).

2. **AdSense Content & Footer:**
   - Build `/kb` Knowledge Base and `/docs` API Documentation routes in Flutter.
   - Build global footer component with GitHub link and open-source attribution.

3. **Automated Verification:**
   - Ensure 100% of Pytest and Flutter test suites pass cleanly.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.03-tracker.md` and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-015: AdSense-Qualifying Content KB, Docs & GitHub Footer.

1. Checkout dedicated feature branch from dev: `git checkout -b feature/UC-015` (or `sprint/sprint-03-uc-015`).
2. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
3. Build /kb Knowledge Base, /docs API Documentation routes, and GitHub repository footer component in Flutter.
4. Ensure 100% of Pytest and Flutter test suites pass cleanly.
5. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
