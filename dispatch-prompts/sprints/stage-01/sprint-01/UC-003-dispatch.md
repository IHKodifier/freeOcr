# TASK DISPATCH: Implement UC-003 (Baidu PaddleOCR-VL 1.6 Worker & Ephemeral RAM Disk Management)

> **Ticket:** `UC-003`  
> **Sprint:** `Sprint 01` (Core Conversion Engine)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-003-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-003-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated unit & integration tests in `src/tests/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-003` checked out from `dev`. NEVER push directly to `main`.
5. **Privacy & RAM Disk Lifecycle:** Uploaded files MUST be processed in `tmpfs` RAM disk (or OS temp directory) with `try ... finally` context manager guaranteeing file deletion immediately after processing.

---

## 2. Master Product Spec Reference

- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)
- Stage 01 Tracker: [`trackers/stage-01/07.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/07.01-tracker.md)
- Sprint 01 Tracker: [`trackers/stage-01/sprints/07.01.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.01-tracker.md)

---

## 3. Ticket Specification — UC-003

**Ticket ID:** UC-003  
**Name:** Baidu PaddleOCR-VL 1.6 Worker Execution & Ephemeral RAM Disk Management  
**Epic:** Epic 1 (Zero-Friction Conversion Engine)  
**Actor:** Local OCR Worker Process / FastAPI Task Runner  
**Trigger:** Receipt of `{job_id}` and uploaded file from UC-001.  

### Preconditions
- [x] UC-001 and UC-002 completed and verified.
- [ ] Active branch set to `sprint/sprint-01-uc-003` checked out from `dev`.
- [ ] PyMuPDF (`fitz`), Pillow, PyTesseract / PaddleOCR Python packages available in environment.

### Main Implementation Steps

1. **OCR Worker Engine (`src/backend/app/services/ocr_worker.py`):**
   - Implement `process_ocr_job(job_id: str, file_bytes: bytes, filename: str)` function.
   - Use `try ... finally` block to write `file_bytes` to ephemeral temp path (`/tmp/ephemeral_<job_id>.pdf` or OS RAM temp) and guarantee `os.remove()` in `finally:`.
   - Render PDF pages to images using PyMuPDF (`fitz`) or Pillow.
   - Run page-by-page OCR extraction to obtain recognized text lines and bounding polygon coordinates `[x_min, y_min, x_max, y_max]`.
   - As each page completes, publish real-time JSON event payload to Redis channel `job_events:{job_id}` (`{"job_id": job_id, "status": "PROCESSING", "current_page": N, "total_pages": M}`).
   - Upon completing all pages, publish final `COMPLETED` payload (`{"job_id": job_id, "status": "COMPLETED", "output_pdf_token": "<token>"}`) and store OCR result structured dict in memory/cache.

2. **Backend API Integration (`src/backend/app/api/v1/endpoints/ocr.py`):**
   - Trigger `process_ocr_job` asynchronously (or via background task) upon receiving upload in `POST /api/v1/ocr/convert`.

3. **TDD Automated Test Suite (`src/tests/test_ocr_worker.py`):**
   - Test `process_ocr_job` with sample PDF & image fixtures.
   - Verify `finally:` block executes `os.remove()` even if an exception occurs during OCR inference.
   - Verify Redis Pub/Sub events are published for each processed page.
   - Verify final state transition to `COMPLETED`.

4. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN OCR worker processes a document or encounters an exception THE SYSTEM SHALL execute `os.remove()` on the input file in `finally:` block ensuring 0 bytes remain on disk.
- **AC-2:** WHEN each page finishes OCR recognition THE SYSTEM SHALL emit an SSE event containing `current_page` and `total_pages` within 100ms.
- **AC-3:** WHEN all pages finish processing THE SYSTEM SHALL transition job status to `COMPLETED` and emit `output_pdf_token`.

---

## 5. Definition of Done Checklist for Agent

- [x] Feature branch `sprint/sprint-01-uc-003` checked out from `dev`.
- [x] Automated unit tests in `src/tests/test_ocr_worker.py` created and passing 100% green.
- [x] `ocr_worker.py` implemented with `try ... finally` RAM disk file cleanup.
- [x] Page-by-page OCR extraction and Redis Pub/Sub progress event publishing verified.
- [x] Backlog trackers (`07.01.01-tracker.md`, `07.01-tracker.md`, `master-tracker.md`) updated.
- [x] Definition of Done artifact (`definition_of_done.md`) created.
- [x] Final execution report delivered to user.
