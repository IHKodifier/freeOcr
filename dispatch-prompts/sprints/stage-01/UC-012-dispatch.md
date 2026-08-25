# Zero-Context Ticket Dispatch Prompt: UC-012 (Password-in-Place Encrypted PDF Decryption)

> **Sprint:** Sprint 2 (Preview, Multi-Export & Email Purge Delivery)  
> **Ticket ID:** UC-012  
> **Feature Name:** Password-in-Place Encrypted PDF Decryption  
> **Prerequisites Completed:** UC-005, UC-006, UC-007 & UC-008 (Completed & Verified 100% Green)

---

## 1. Context & Completed Work Summary
In the previous sessions, we completed:
- **UC-005 (Interactive Side-by-Side Split Preview Viewer):** FastAPI `/jobs/{job_id}/preview` and Flutter `SplitPreviewViewer`.
- **UC-006 (1-Click Multi-Format Direct Downloads):** FastAPI `GET /api/v1/jobs/{job_id}/download/{format}` (`.pdf`, `.txt`, `.md`).
- **UC-007 (Email Download Link Delivery & Input Purge):** FastAPI `POST /api/v1/ocr/email-links` & instant RAM disk input file purging.
- **UC-008 (24-Hour Expiration TTL & Local Time Expired Link Page):** Backend HTTP 410 Gone handler & Flutter `ExpiredLinkView`.
- Verified test suite: **58/58 Pytest tests PASSED** and **15/15 Flutter tests PASSED**.

---

## 2. Goals & Objectives for UC-012
Implement **UC-012 (Password-in-Place Encrypted PDF Decryption)**:

1. **Backend Encryption Detector & Decryptor (`src/backend/app/services/ocr_worker.py` & `ocr.py`):**
   - Detect encrypted PDF upload (`doc.is_encrypted == True`).
   - Return `HTTP 422 Unprocessable Entity` with JSON body: `{"error": "PASSWORD_REQUIRED", "message": "Password Protected PDF. Please provide password to unlock."}`.
   - Accept `password` parameter in OCR conversion/retry endpoint and attempt `doc.authenticate(password)` in RAM disk.

2. **Frontend Inline Password Prompt (`src/frontend/lib/widgets/hero_dropzone.dart` / dialog):**
   - Render inline password entry field when backend returns HTTP 422 `PASSWORD_REQUIRED`.
   - Allow user to type password and click **[Unlock & Process]** to re-submit with password.

3. **Automated Verification:**
   - Create unit tests in `src/tests/test_pdf_decryption.py` verifying encrypted PDF rejection and RAM decryption.
   - Run `$env:PYTHONPATH="src/backend"; pytest src/tests/ -v` and `cd src/frontend; flutter test` ensuring 100% pass rates.

4. **Tracker Update:**
   - Update `trackers/stage-01/sprints/07.01.02-tracker.md`, `trackers/stage-01/07.01-tracker.md`, and `trackers/master-tracker.md`.

---

## 3. Dispatch Prompt (Copy & Paste to Start)

```text
Please execute ticket UC-012: Password-in-Place Encrypted PDF Decryption.

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Implement backend HTTP 422 PASSWORD_REQUIRED detection and PyMuPDF RAM decryption in ocr_worker.py and ocr.py.
3. Build Flutter inline password unlock prompt overlay in hero_dropzone.dart.
4. Create test_pdf_decryption.py in src/tests/ and ensure 100% of Pytest and Flutter tests pass.
5. Update trackers in trackers/stage-01/sprints/07.01.02-tracker.md and master-tracker.md.
```
