# Community 11

> 25 nodes · cohesion 0.10

## Key Concepts

- [test_pdf_repair.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L1) (9 connections)
- [repair_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_repair.py#L8) (6 connections)
- [create_minimal_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L14) (5 connections)
- [test_ocr_worker_corrupted_pdf_repair_integration()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L112) (5 connections)
- [purge_ephemeral_ram_disk()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/watchdog.py#L6) (5 connections)
- [create_reparable_corrupted_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L24) (4 connections)
- [test_corrupted_pdf_repair_success()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L42) (4 connections)
- [test_valid_pdf_repair_noop()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L32) (4 connections)
- [test_ocr_worker_unrepairable_pdf_integration()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L149) (3 connections)
- [test_unrepairable_garbage_pdf_failure()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L54) (3 connections)
- [test_watchdog_ignores_non_ephemeral_files()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L91) (3 connections)
- [test_watchdog_purges_old_ephemeral_files()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L63) (3 connections)
- [pdf_repair.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_repair.py#L1) (1 connections)
- [watchdog.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/watchdog.py#L1) (1 connections)
- [Attempts automated repair on corrupted or damaged PDF file bytes.     1. Fixes](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_repair.py#L9) (1 connections)
- [ocr_worker process_ocr_job should attempt repair on corrupted PDF and complete O](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L113) (1 connections)
- [Helper to generate minimal valid single-page PDF bytes.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L15) (1 connections)
- [ocr_worker process_ocr_job should emit FAILED status on unrepairable PDF.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L150) (1 connections)
- [Helper to generate a PDF stream with broken startxref offset.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L25) (1 connections)
- [Valid PDF bytes should return success without error.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L33) (1 connections)
- [Corrupted PDF stream with fixable xref should be repaired successfully.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L43) (1 connections)
- [Random unrepairable garbage bytes should return failure status.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L55) (1 connections)
- [Watchdog should purge ephemeral_* files older than max_age_seconds.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L64) (1 connections)
- [Watchdog should not touch files that do not start with ephemeral_.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py#L92) (1 connections)
- [Scans RAM disk / ephemeral temp storage directory for orphan temporary files](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/watchdog.py#L7) (1 connections)

## Relationships

- [[Community 6]] (11 shared connections)

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_repair.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_repair.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\watchdog.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/watchdog.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_pdf_repair.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_repair.py)

## Audit Trail

- EXTRACTED: 52 (78%)
- INFERRED: 15 (22%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*