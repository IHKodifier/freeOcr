# Zero-Context Ticket Dispatch Prompt: UC-006 (1-Click Multi-Format Direct Downloads)

> **Sprint:** Sprint 2 (Preview, Multi-Export & Email Purge Delivery)  
> **Ticket ID:** UC-006  
> **Feature Name:** 1-Click Multi-Format Direct Downloads (`.pdf`, `.txt`, `.md`)  
> **Prerequisites Completed:** UC-005 (Completed & Verified 100% Green)

---

## 1. Context & Completed Work Summary
In the previous session, we completed **UC-005 (Interactive Side-by-Side Split Preview Viewer)**:
- Integrated fast **OCRmyPDF / Tesseract** CPU engine for simple layout scanned PDFs (< 1 second line extraction) and isolated **Baidu Unlimited OCR** for complex layout GPU queues.
- Updated `get_job_preview` in `jobs.py` to prioritize `DEV_JOB_STORE` so completed page lines and bounding blocks are immediately returned.
- Added automatic periodic polling (3s interval) in Flutter `SplitPreviewViewer` (`split_preview_viewer.dart`) when page lines are loading, with split-block paragraph parsing into precise line-level bounding boxes.
- Verified test suite: **43/43 Pytest tests PASSED** and **11/11 Flutter tests PASSED**.

---

## 2. Goals & Objectives for UC-006
Implement **UC-006 (1-Click Multi-Format Direct Downloads)**:
1. **Backend Endpoints (`src/backend/app/api/v1/endpoints/jobs.py`):**
   - Add `GET /api/v1/jobs/{job_id}/download/{format}` (`format` in `pdf`, `txt`, `md`).
   - `.pdf`: Stream generated searchable PDF with invisible text layer overlay (`Content-Disposition: attachment; filename="{filename}_searchable.pdf"`).
   - `.txt`: Stream compiled page text as plain text file (`filename="{filename}_extracted.txt"`).
   - `.md`: Stream formatted Markdown text (`filename="{filename}_extracted.md"`).
   - Immediately unlinks and purges original input PDF from RAM disk upon download stream initiation (AC-1 / Privacy Mandate).

2. **Frontend Integration (`src/frontend/lib/widgets/split_preview_viewer.dart` & `src/frontend/lib/services/api_service.dart`):**
   - Add click handlers for **"Download Searchable PDF"**, **"Plain Text (.txt)"**, and **"Markdown (.md)"** buttons.
   - Trigger browser file save (`html.AnchorElement` / `url_launcher` download stream).

3. **Automated Verification:**
   - Create `src/tests/test_download_endpoints.py` testing `.pdf`, `.txt`, and `.md` streaming and input file unlinking.
   - Run `pytest src/tests/ -v` (43+ passing) and `cd src/frontend; flutter test` (11+ passing).

---

## 3. Dispatch Prompt (Copy & Paste to Start Fresh Conversation)

```text
Please execute ticket UC-006: 1-Click Multi-Format Direct Downloads (.pdf, .txt, .md).

1. Review governance in .agents/AGENTS.md and ticket specs in product-specs/06a-use-case-tickets.md.
2. Implement backend download endpoint GET /api/v1/jobs/{job_id}/download/{format} in src/backend/app/api/v1/endpoints/jobs.py supporting searchable .pdf, plain text .txt, and markdown .md formats, with immediate input file RAM disk purging upon download stream start.
3. Wire up frontend download buttons in src/frontend/lib/widgets/split_preview_viewer.dart.
4. Add unit/integration tests in src/tests/ and ensure 100% of Pytest and Flutter tests pass.
5. Update trackers in trackers/stage-01/sprints/07.01.02-tracker.md.
```
