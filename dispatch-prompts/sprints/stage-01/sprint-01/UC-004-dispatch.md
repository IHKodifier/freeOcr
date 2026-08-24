# TASK DISPATCH: Implement UC-004 (Searchable PDF Composition Engine - Invisible Layer Overlay)

> **Ticket:** `UC-004`  
> **Sprint:** `Sprint 01` (Core Conversion Engine)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-004-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-004-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated unit & integration tests in `src/tests/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-004` checked out from `dev`. NEVER push directly to `main`.
5. **Zero-Disk / Ephemeral Storage:** Output searchable PDFs must be stored ephemerally in `tmpfs` RAM disk or OS temp directory with guaranteed cleanup.

---

## 2. Master Product Spec Reference

- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)
- Stage 01 Tracker: [`trackers/stage-01/07.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/07.01-tracker.md)
- Sprint 01 Tracker: [`trackers/stage-01/sprints/07.01.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.01-tracker.md)

---

## 3. Ticket Specification — UC-004

**Ticket ID:** UC-004  
**Name:** Searchable PDF Composition Engine (Invisible Text Layer Overlay)  
**Epic:** Epic 1 (Zero-Friction Conversion Engine)  
**Actor:** Python PDF Builder (`PyMuPDF` / `fitz`)  
**Trigger:** Bounding box and text line extraction completion from UC-003.  

### Preconditions
- [x] UC-001, UC-002, and UC-003 completed and verified.
- [ ] Active branch set to `sprint/sprint-01-uc-004` checked out from `dev`.
- [ ] PyMuPDF (`pymupdf`) package available.

### Main Implementation Steps

1. **PDF Composition Service (`src/backend/app/services/pdf_composer.py`):**
   - Implement `compose_searchable_pdf(job_id: str, pages_data: list[dict], original_file_bytes: bytes) -> bytes` function.
   - For scanned image pages: overlay background image raster and place invisible text (text render mode 3) at exact `[x0, y0, x1, y1]` bounding box coordinates.
   - For PDF documents with images: insert invisible text layer onto each corresponding page.
   - Write compiled searchable PDF to ephemeral RAM disk path (`/tmp/out_{job_id}.pdf` or OS temp path) and return generated PDF bytes or file token.

2. **Integration into OCR Worker (`src/backend/app/services/ocr_worker.py`):**
   - After extracting page text and bounding boxes in `process_ocr_job`, call `compose_searchable_pdf`.
   - Store generated output PDF in ephemeral cache / token storage associated with `output_pdf_token`.

3. **TDD Automated Test Suite (`src/tests/test_pdf_composer.py`):**
   - Write tests verifying that compiled output PDF contains searchable text elements.
   - Verify text searchability (`page.search_for(...)` or text extraction in PyMuPDF).
   - Verify visually identical output layout and zero-disk leakage.

4. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN a user opens the output searchable PDF THE SYSTEM SHALL present a document visually pixel-identical to the original scanned input.
- **AC-2:** WHEN a user performs text search (Ctrl+F) in any PDF reader on the generated document THE SYSTEM SHALL match and highlight searched text at correct bounding coordinates.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-01-uc-004` checked out from `dev`.
- [ ] Automated unit tests in `src/tests/test_pdf_composer.py` created and passing 100% green.
- [ ] `pdf_composer.py` implemented with invisible text overlay composition.
- [ ] Output PDF text searchability verified via PyMuPDF text search.
- [ ] Backlog trackers (`07.01.01-tracker.md`, `07.01-tracker.md`, `master-tracker.md`) updated.
- [ ] Definition of Done artifact (`definition_of_done.md`) created.
- [ ] Final execution report delivered to user.
