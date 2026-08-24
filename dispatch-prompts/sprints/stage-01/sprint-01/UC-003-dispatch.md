# TASK DISPATCH: Implement UC-003 (Baidu PaddleOCR-VL 1.6 Worker & tmpfs RAM Disk)

> **Ticket:** `UC-003`  
> **Sprint:** `Sprint 01` (Core Conversion Engine)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-003-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-003-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated tests in `src/tests/` and `src/frontend/test/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-003` checked out from `dev`. NEVER push directly to `main`.

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
**Name:** Baidu PaddleOCR-VL 1.6 Worker Execution & `tmpfs` RAM Disk Management  
**Epic:** Epic 1 (Zero-Friction Conversion Engine)  
**Actor:** Celery GPU/CPU Worker Process  
**Trigger:** Celery worker pops job task from Redis queue.  

### Preconditions
- [x] `UC-001` and `UC-002` completed and merged into `dev`.
- [ ] Active branch set to `sprint/sprint-01-uc-003` checked out from `dev`.
- [ ] Redis broker running (`redis://localhost:6379/0`).

### Main Implementation Steps

1. **Celery Worker App & Hardware Detection (`src/backend/app/worker.py` & `app/core/ocr_engine.py`):**
   - Initialize Celery worker application with Redis broker & result backend.
   - Implement hardware GPU/CPU auto-detection logic (`use_gpu=True` if CUDA is available, fallback `use_gpu=False` on CPU).
   - Load local PaddleOCR / PyMuPDF OCR extraction engine instance.

2. **Ephemeral `tmpfs` RAM Disk Manager (`src/backend/app/core/ram_disk.py`):**
   - Create RAM disk manager handling temporary document writes in Linux `/dev/shm` (or OS RAM temp directory).
   - Guarantee instant file unlinking and memory purge immediately upon page processing completion or failure.

3. **Page-by-Page OCR Loop & Redis Progress Publisher:**
   - Iterate through document pages extracting text content, layout bounding boxes, and confidence metrics.
   - Publish real-time JSON events to Redis channel `job_events:{job_id}`:
     `{"current_page": X, "total_pages": Y, "status": "PROCESSING"}`.
   - Upon completion, store result payload in Redis key `job:{job_id}` and emit `COMPLETED` event with `output_pdf_token`.

4. **TDD Automated Test Suite (`src/tests/test_ocr_worker.py`):**
   - Unit/Integration tests for:
     - GPU/CPU auto-detection fallback logic.
     - RAM disk file creation, isolation, and immediate unlinking/purging.
     - Page processing loop & Redis Pub/Sub message publication.

5. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN a worker pops a job THE SYSTEM SHALL auto-detect hardware and run OCR in GPU mode if CUDA is present or CPU mode if CUDA is absent.
- **AC-2:** WHEN raw file bytes are written for processing THE SYSTEM SHALL store them in RAM disk (`tmpfs`) and purge them immediately upon job completion or error.
- **AC-3:** AS each page OCR task finishes THE SYSTEM SHALL publish a JSON progress event to `job_events:{job_id}` within 100ms.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-01-uc-003` checked out from `dev`.
- [ ] Automated backend tests in `src/tests/test_ocr_worker.py` created and passing 100% green.
- [ ] Celery worker task & CPU/GPU fallback OCR engine implemented.
- [ ] Ephemeral `tmpfs` RAM disk manager created with auto-purge guarantee.
- [ ] Page-by-page Redis Pub/Sub progress publisher verified.
- [ ] Backlog trackers updated.
- [ ] Definition of Done artifact (`definition_of_done.md`) created.
- [ ] Final execution report delivered to user.
