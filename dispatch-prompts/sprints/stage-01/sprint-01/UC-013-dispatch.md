# TASK DISPATCH: Implement UC-013 (Corrupted PDF Automated Repair Fallback & 60s Watchdog Cleaner)

> **Ticket:** `UC-013`  
> **Sprint:** `Sprint 01` (Core Conversion Engine & Ephemeral Processing)  
> **Target File:** [`dispatch-prompts/sprints/stage-01/sprint-01/UC-013-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/sprints/stage-01/sprint-01/UC-013-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated unit & integration tests in `src/tests/` MUST be written BEFORE implementation logic.
4. **Branching:** Work on feature branch `sprint/sprint-01-uc-013` checked out from `dev`. NEVER push directly to `main`.
5. **Zero-Disk / Ephemeral Storage:** Temp files in `tmpfs` RAM disk or OS temp directory must be purged by watchdog when exceeding 60s TTL.

---

## 2. Master Product Spec Reference

- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)
- Stage 01 Tracker: [`trackers/stage-01/07.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/07.01-tracker.md)
- Sprint 01 Tracker: [`trackers/stage-01/sprints/07.01.01-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/stage-01/sprints/07.01.01-tracker.md)

---

## 3. Ticket Specification — UC-013

**Ticket ID:** UC-013  
**Name:** Corrupted PDF Automated Repair Fallback & 60s Watchdog Cleaner  
**Epic:** Epic 1 (Zero-Friction Conversion Engine & Ephemeral Processing)  
**Actor:** Celery / Worker Background Watchdog Cron & Repair Pipeline  
**Trigger:** Corrupted PDF stream parsing exception during OCR OR 30-second watchdog timer tick.  

### Preconditions
- [x] UC-001, UC-002, UC-003, and UC-004 completed and merged into `dev`.
- [ ] Active branch set to `sprint/sprint-01-uc-013` checked out from `dev`.

### Main Implementation Steps

1. **PDF Repair Fallback Service (`src/backend/app/services/pdf_repair.py`):**
   - Catch PyMuPDF parsing exception (`pymupdf.FileDataError` / corrupt stream exception) during page loading in `ocr_worker.py`.
   - Publish SSE progress update event: `"Attempting PDF repair..."`.
   - Run automated repair sequence using PyMuPDF rebuilding (`pymupdf.open(stream=...).save(..., garbage=4, deflate=True)` or `qpdf --repair` CLI fallback).
   - If repair succeeds: Resume OCR processing on repaired document bytes.
   - If repair fails: Return user-friendly error status (`CORRUPTED_PDF_UNREPAIRABLE`).

2. **Watchdog RAM Disk Cleaner (`src/backend/app/services/watchdog.py`):**
   - Implement `purge_ephemeral_ram_disk(max_age_seconds: int = 60)` background task.
   - Scan `/tmp` RAM disk (or `RAM_DISK_PATH` environment variable directory) for `ephemeral_*` files with `mtime` older than 60 seconds.
   - Execute `os.remove()` on orphan temp files to maintain RAM disk hygiene.

3. **TDD Automated Test Suite (`src/tests/test_pdf_repair.py`):**
   - Test corrupted PDF detection and repair fallback.
   - Test watchdog cleaner purging files older than 60s while keeping fresh files intact.

4. **Hierarchical Tracker Maintenance:**
   - Update Sprint 1 tracker (`07.01.01-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- **AC-1:** WHEN a corrupted PDF is uploaded THE SYSTEM SHALL execute automated repair scripts before raising an error.
- **AC-2:** WHEN an orphan file in `/tmp` RAM disk exceeds 60s `mtime` THE SYSTEM SHALL automatically purge the file via Watchdog.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-01-uc-013` checked out from `dev`.
- [ ] Automated unit tests in `src/tests/test_pdf_repair.py` created and passing 100% green.
- [ ] `pdf_repair.py` and `watchdog.py` implemented.
- [ ] RAM disk 60s cleanup verified.
- [ ] Backlog trackers (`07.01.01-tracker.md`, `07.01-tracker.md`, `master-tracker.md`) updated.
- [ ] Definition of Done artifact (`definition_of_done.md`) created.
- [ ] Final execution report delivered to user.
