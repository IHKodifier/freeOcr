# Zero-Context Ticket Dispatch Prompt: UC-014 (Google Analytics 4 (GA4) Telemetry & SEO Meta-Tags)

> **Sprint:** Sprint 3 (Ad Monetization, Telemetry & SEO Content)  
> **Ticket ID:** UC-014  
> **Feature Name:** Google Analytics 4 (GA4) Telemetry & SEO Meta-Tags  
> **Prerequisites Completed:** UC-011 (Passed)

---

## 1. Context & Specification Summary
In UC-014, we implement GA4 telemetry tracking and SEO meta-tags:
- `gtag.js` script tag in Web `index.html` head (`G-XXXXXXXXXX`).
- Dispatches pageview and conversion events (`upload_start`, `ocr_complete`, `download_file`, `email_sent`).
- Canonical SEO OpenGraph and Twitter meta-tags for search engine indexing.

---

## 2. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-014: Google Analytics 4 (GA4) Telemetry & SEO Meta-Tags.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Inject GA4 script tag and OpenGraph SEO meta-tags in index.html and dispatch custom events in Flutter UI.
3. Ensure 100% of Pytest and Flutter test suites pass cleanly.
4. Update trackers in trackers/stage-01/sprints/07.01.03-tracker.md and master-tracker.md.
```
