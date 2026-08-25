# Zero-Context Ticket Dispatch Prompt: UC-007 (Email Download Link Delivery & Input Purge)

> **Sprint:** Sprint 2 (Preview, Multi-Export & Email Purge Delivery)  
> **Ticket ID:** UC-007  
> **Feature Name:** Email Download Link Delivery & Immediate Input File Purging  
> **Prerequisites Completed:** UC-005 & UC-006 (Completed & Verified 100% Green)

---

## 1. Context & Completed Work Summary
In the previous sessions, we completed:
- **UC-005 (Interactive Side-by-Side Split Preview Viewer):** FastAPI `/jobs/{job_id}/preview` and Flutter `SplitPreviewViewer` with side-by-side layout scanning.
- **UC-006 (1-Click Multi-Format Direct Downloads):** FastAPI `GET /api/v1/jobs/{job_id}/download/{format}` (`.pdf`, `.txt`, `.md`), precise line-level baseline overlay positioning (`extractDICT()`), and instant RAM disk purging.
- Verified test suite: **48/48 Pytest tests PASSED** and **12/12 Flutter tests PASSED**.

---

## 2. Goals & Objectives for UC-007
Implement **UC-007 (Email Download Link Delivery & Immediate Input File Purging)**:

1. **Backend Endpoint (`src/backend/app/api/v1/endpoints/ocr.py` or `jobs.py`):**
   - Implement `POST /api/v1/ocr/email-links` taking JSON body `{"job_id": "...", "email": "user@example.com"}`.
   - Validate email format and check job completion status.
   - Dispatch email via Resend API (or mock email service in dev/test) containing 24-hour expiring download links for `.pdf`, `.txt`, and `.md`.
   - **Privacy Mandate:** Immediately trigger `os.remove()` to purge any remaining original input file from RAM disk upon endpoint invocation, regardless of email delivery status (AC-1 / Privacy Mandate).

2. **Frontend UI Integration (`src/frontend/lib/widgets/split_preview_viewer.dart` & `src/frontend/lib/services/api_service.dart`):**
   - Add an Email Link Delivery card/dialog with email input field and **[Send Download Links]** button.
   - Display explicit user warning: *"Input file is deleted immediately. Ensure email address is correct."*
   - Wire API service call to `POST /api/v1/ocr/email-links`.

3. **Automated Verification:**
   - Create unit/integration tests in `src/tests/test_email_delivery.py`.
   - Run `pytest src/tests/ -v` and `cd src/frontend; flutter test` ensuring 100% pass rates.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.02-tracker.md`, `trackers/stage-01/07.01-tracker.md`, and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-007: Email Download Link Delivery & Immediate Input File Purging.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Implement backend endpoint POST /api/v1/ocr/email-links in src/backend/app/api/v1/endpoints/ocr.py or jobs.py, with email link dispatch and instant RAM disk input file purging.
3. Wire up frontend email delivery input & warning banner in src/frontend/lib/widgets/split_preview_viewer.dart.
4. Create test_email_delivery.py in src/tests/ and ensure 100% of Pytest and Flutter tests pass.
5. Update trackers in trackers/stage-01/sprints/07.01.02-tracker.md and master-tracker.md.
```
