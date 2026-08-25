# TASK DISPATCH: Implement UC-005 & UC-005b (Interactive Side-by-Side Split Preview & Apple-Grade UI Polish)

> **Ticket:** `UC-005` / `UC-005b`  
> **Sprint:** `Sprint 02` (Preview, Multi-Export & Email Purge)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-02/UC-005-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-02/UC-005-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate:** All automated unit & integration tests in `src/tests/` and Flutter widget tests in `src/frontend/test/` MUST be created BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-02-uc-005` checked out from `dev`. NEVER push directly to `main`.
5. **Zero-Cloud & Local First:** Execute frontend & backend tests locally.

---

## 2. Master Product Spec Reference

- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Active Sprint 2 Tracker: [`trackers/stage-01/sprints/07.01.02-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.02-tracker.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-005 & UC-005b

**Ticket ID:** UC-005 & UC-005b  
**Name:** Interactive Side-by-Side Split Preview Viewer & Apple-Grade UI Polish  
**Epic:** Epic 2 (Preview & Multi-Format Export)  
**Actor:** Anonymous Web User / Flutter Web UI Client  
**Trigger:** Receipt of SSE `COMPLETED` event or navigation to `/result/{job_id}`  

### Preconditions
- [x] Sprint 01 (`UC-001`, `UC-002`, `UC-003`, `UC-004`, `UC-013`) completed and merged into `dev`.
- [ ] Active branch set to `sprint/sprint-02-uc-005` checked out from `dev`.

### Main Implementation Steps

1. **FastAPI Result Preview Endpoint (`src/backend/app/api/v1/endpoints/jobs.py`):**
   - Add endpoint `GET /api/v1/jobs/{job_id}/preview` returning extracted text blocks and page layout metadata.
   - Return 404 if `job_id` is expired or invalid.

2. **Flutter Interactive Split Preview Widget (`src/frontend/lib/widgets/split_preview_viewer.dart`):**
   - Implement side-by-side split screen view with 1:1 interactive mouse/touch drag handle.
   - Left Pane: Original document page viewer.
   - Right Pane: Selectable OCR text editor with `.txt` and `.md` tab view toggles.
   - Smooth responsive layout adapting to mobile and desktop screen sizes.

3. **Apple-Grade Visual Polish (`UC-005b`):**
   - Apply translucent glassmorphic card containers (`backdrop-filter blur 20px`).
   - Electric Indigo theme gradients and JetBrains Mono / Inter typography.
   - Spring micro-animations on split handle dragging and button presses.

4. **TDD Automated Test Suites:**
   - Backend API test in `src/tests/test_ocr_preview.py`.
   - Flutter widget test in `src/frontend/test/widgets/split_preview_viewer_test.dart`.

5. **Backlog Tracker Maintenance:**
   - Update Sprint 2 tracker (`07.01.02-tracker.md`), Stage 1 tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN an OCR conversion job completes THE SYSTEM SHALL render the side-by-side split preview view within 300ms.
- **AC-2:** WHEN the user drags the middle split handle THE SYSTEM SHALL resize the left scan pane and right text pane in real-time 1:1 sync.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-02-uc-005` checked out from `dev`.
- [ ] Backend preview test `src/tests/test_ocr_preview.py` passing 100% green.
- [ ] Flutter widget test `src/frontend/test/widgets/split_preview_viewer_test.dart` passing 100% green.
- [ ] FastAPI `GET /api/v1/jobs/{job_id}/preview` endpoint implemented.
- [ ] Flutter `SplitPreviewViewer` widget implemented with Apple-grade glassmorphic polish.
- [ ] Active trackers updated (`07.01.02-tracker.md`, `07.01-tracker.md`, `master-tracker.md`).
