# TASK DISPATCH: Implement UC-001 (Drag & Drop PDF Upload & File Validation)

> **Ticket:** `UC-001`  
> **Sprint:** `Sprint 01` (Core Conversion Engine)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-001-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-001-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated tests in `src/tests/` and `src/frontend/test/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-001` checked out from `dev`. NEVER push directly to `main`.

---

## 2. Master Product Spec Reference
- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)
- Stage 01 Tracker: [`trackers/stage-01/07.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/07.01-tracker.md)
- Sprint 01 Tracker: [`trackers/stage-01/sprints/07.01.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.01-tracker.md)

---

## 3. Ticket Specification — UC-001

**Ticket ID:** UC-001  
**Name:** Drag & Drop PDF Upload & File Validation  
**Epic:** Epic 1 (Zero-Friction Conversion Engine)  
**Actor:** Anonymous Web User / Flutter Web UI / FastAPI Gateway  
**Trigger:** User drops file onto landing hero zone or clicks file selector.  

### Preconditions
- [x] Sprint 0 completed and merged into `dev`.
- [ ] Active branch set to `sprint/sprint-01-uc-001` checked out from `dev` if not already checked out.
- [ ] FastAPI backend running with Redis support (`redis_client.py`).

### Main Implementation Steps

1. **FastAPI Upload Router (`src/backend/app/api/v1/endpoints/ocr.py`):**
   - Implement `POST /api/v1/ocr/convert` endpoint handling `UploadFile`.
   - Validate allowed extensions: `.pdf`, `.jpg`, `.jpeg`, `.png`.
   - Reject empty 0-byte files with HTTP 400 (`{"detail": "File is empty. Please select a valid document."}`).
   - Reject invalid extensions with HTTP 400 (`{"detail": "Unsupported file format."}`).
   - Check file size against `FREE_TIER_MAX_FILE_MB` (10MB).
   - Check/increment Redis IP rate limit counter (`ip_limit:{client_ip}`).
   - Store job metadata in Redis key `job:{job_id}` in `QUEUED` state.
   - Return HTTP 202 `{ "job_id": "<uuid>", "status": "QUEUED" }`.

2. **Frontend Drag & Drop UI Component (`src/frontend/lib/`):**
   - Create interactive hero dropzone widget with Material 3 styling, hover state micro-animations, and file picker button.
   - Implement client-side format and size validation toasts before sending HTTP requests.

3. **TDD Automated Test Suite (`src/tests/test_ocr_upload.py` & `src/frontend/test/`):**
   - Unit/Integration tests for:
     - Valid PDF upload (returns HTTP 202 + `{job_id}`)
     - Unsupported extension upload (returns HTTP 400)
     - 0-byte empty file upload (returns HTTP 400)
     - Redis job payload verification

4. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN a user drops a valid PDF under 10MB THE SYSTEM SHALL return HTTP 202 with `{job_id}` within 500ms.
- **AC-2:** WHEN a user drops an invalid file extension (e.g. `.exe`, `.docx`) THE SYSTEM SHALL reject the file client-side before sending HTTP request.
- **AC-3:** WHEN an empty 0-byte file is submitted THE SYSTEM SHALL return HTTP 400 with detail `"File is empty. Please select a valid document."`.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-01-uc-001` checked out from `dev`.
- [ ] Automated tests in `src/tests/test_ocr_upload.py` created and passing 100% green.
- [ ] FastAPI `POST /api/v1/ocr/convert` endpoint implemented and verified.
- [ ] Flutter Web drag & drop UI component implemented with Material 3 styling.
- [ ] Frontend widget test created and passing 100% green.
- [ ] Backlog trackers (`07.01.01-tracker.md`, `07.01-tracker.md`, `master-tracker.md`) updated.
- [ ] Definition of Done artifact (`definition_of_done.md`) created.
- [ ] Final execution report delivered to user.
