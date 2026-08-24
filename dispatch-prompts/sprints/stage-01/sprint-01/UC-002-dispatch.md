# TASK DISPATCH: Implement UC-002 (Real-Time SSE Progress Streaming)

> **Ticket:** `UC-002`  
> **Sprint:** `Sprint 01` (Core Conversion Engine)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-002-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-002-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated tests in `src/tests/` and `src/frontend/test/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-002` checked out from `dev`. NEVER push directly to `main`.

---

## 2. Master Product Spec Reference
- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)
- Stage 01 Tracker: [`trackers/stage-01/07.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/07.01-tracker.md)
- Sprint 01 Tracker: [`trackers/stage-01/sprints/07.01.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.01-tracker.md)

---

## 3. Ticket Specification — UC-002

**Ticket ID:** UC-002  
**Name:** Real-Time SSE Progress Streaming  
**Epic:** Epic 1 (Zero-Friction Conversion Engine)  
**Actor:** Anonymous Web User / Flutter Web UI / Server-Sent Events Gateway  
**Trigger:** Receipt of `{job_id}` from UC-001 upload endpoint.  

### Preconditions
- [x] `UC-001` completed and merged into `dev`.
- [ ] Active branch set to `sprint/sprint-01-uc-002` checked out from `dev`.
- [ ] Redis pub/sub operational (`job_events:{job_id}`).

### Main Implementation Steps

1. **FastAPI SSE Router (`src/backend/app/api/v1/endpoints/jobs.py`):**
   - Implement `GET /api/v1/jobs/{job_id}/events` streaming endpoint using FastAPI `StreamingResponse` (or `sse-starlette`).
   - Subscribe to Redis pub/sub channel `job_events:{job_id}` async event stream.
   - Stream JSON payloads: `{"current_page": X, "total_pages": Y, "status": "PROCESSING" | "COMPLETED" | "FAILED"}`.
   - When job reaches `COMPLETED`, emit final event with `output_pdf_token` and close stream cleanly.

2. **Frontend SSE Client Listener (`src/frontend/lib/services/sse_service.dart` & `widgets/progress_bar.dart`):**
   - Create Flutter SSE event stream reader subscribing to `/api/v1/jobs/{job_id}/events`.
   - Update UI progress bar dynamically based on percentage `(current_page / total_pages) * 100`.
   - Handle connection retries gracefully on network dropouts.

3. **TDD Automated Test Suite (`src/tests/test_sse_events.py` & `src/frontend/test/sse_progress_test.dart`):**
   - Unit/Integration tests for:
     - SSE stream connection establishment with valid `job_id`.
     - Redis pub/sub message propagation into SSE response stream.
     - Completion event detection and payload verification.

4. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN a page OCR task finishes THE SYSTEM SHALL emit an SSE event containing `current_page` and `total_pages` within 100ms.
- **AC-2:** WHEN job state transitions to `COMPLETED` THE SYSTEM SHALL emit final SSE event containing `output_pdf_token`.
- **AC-3:** WHEN a client connects to an invalid or expired `job_id` THE SYSTEM SHALL return HTTP 404 with detail `"Job not found or expired."`.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-01-uc-002` checked out from `dev`.
- [ ] Automated backend tests in `src/tests/test_sse_events.py` created and passing 100% green.
- [ ] FastAPI `GET /api/v1/jobs/{job_id}/events` SSE endpoint implemented and verified.
- [ ] Flutter Web progress bar widget & SSE service implemented.
- [ ] Frontend widget test created and passing 100% green.
- [ ] Backlog trackers updated.
- [ ] Definition of Done artifact (`definition_of_done.md`) created.
- [ ] Final execution report delivered to user.
