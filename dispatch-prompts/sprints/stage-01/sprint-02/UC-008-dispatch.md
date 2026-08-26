# Zero-Context Ticket Dispatch Prompt: UC-008 (24-Hour Expiration TTL & Local Time Expired Link Page)

> **Sprint:** Sprint 2 (Preview, Multi-Export & Email Purge Delivery)  
> **Ticket ID:** UC-008  
> **Feature Name:** 24-Hour Expiration TTL & Local Time Expired Link Page  
> **Prerequisites Completed:** UC-005, UC-006 & UC-007 (Completed & Verified 100% Green)

---

## 1. Context & Completed Work Summary
In the previous sessions, we completed:
- **UC-005 (Interactive Side-by-Side Split Preview Viewer):** FastAPI `/jobs/{job_id}/preview` and Flutter `SplitPreviewViewer` with side-by-side layout scanning.
- **UC-006 (1-Click Multi-Format Direct Downloads):** FastAPI `GET /api/v1/jobs/{job_id}/download/{format}` (`.pdf`, `.txt`, `.md`), baseline alignment overlay, and RAM disk purging.
- **UC-007 (Email Download Link Delivery & Input Purge):** FastAPI `POST /api/v1/ocr/email-links`, Resend API & SMTP delivery, instant input file purging, and solid opaque UI dialog with privacy warning banner.
- Verified test suite: **55/55 Pytest tests PASSED** and **13/13 Flutter tests PASSED**.

---

## 2. Goals & Objectives for UC-008
Implement **UC-008 (24-Hour Expiration TTL & Local Time Expired Link Page)**:

1. **Backend 24-Hour Expiration Handler (`src/backend/app/api/v1/endpoints/jobs.py` & `redis_client.py`):**
   - Ensure Redis job keys (`job:{job_id}`) and output tokens expire after 24 hours (`86,400 seconds`).
   - In `GET /api/v1/jobs/{job_id}/download/{format}`, evaluate key TTL / expiration state. If expired, return `HTTP 410 Gone` with JSON body e.g. `{"detail": "Download link expired.", "expired_at": "2026-08-27T00:44:00Z"}`.

2. **Frontend UI Integration (`src/frontend/lib/widgets/expired_link_view.dart` & navigation):**
   - Build `ExpiredLinkView` widget to display when download API returns HTTP 410.
   - Format expiration timestamp into user's detected local time zone.
   - Render friendly message: *"This download link expired on [Date/Time in User's Local Time Zone]. Output files are purged after 24h for privacy."*

3. **Automated Verification:**
   - Create unit tests in `src/tests/test_link_expiration.py` verifying HTTP 410 Gone response on expired jobs.
   - Run `$env:PYTHONPATH="src/backend"; pytest src/tests/ -v` and `cd src/frontend; flutter test` ensuring 100% pass rates.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.02-tracker.md`, `trackers/stage-01/07.01-tracker.md`, and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-008: 24-Hour Expiration TTL & Local Time Expired Link Page.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Implement backend HTTP 410 Gone expiration handler for GET /api/v1/jobs/{job_id}/download/{format} when 24h TTL expires.
3. Build frontend ExpiredLinkView widget in src/frontend/lib/widgets/ rendering friendly local timezone expiration banner.
4. Create test_link_expiration.py in src/tests/ and ensure 100% of Pytest and Flutter tests pass.
5. Update trackers in trackers/stage-01/sprints/07.01.02-tracker.md and master-tracker.md.
```
