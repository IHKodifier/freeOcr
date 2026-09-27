# Community 19

> 31 nodes · cohesion 0.09

## Key Concepts

- [test_tools_redact.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L1) (10 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L14) (10 connections)
- [redact_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_redact_service.py#L10) (9 connections)
- [test_redact_case_sensitivity()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L86) (4 connections)
- [test_redact_endpoint_success()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L184) (4 connections)
- [test_redact_missing_parameters_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L163) (4 connections)
- [test_redact_preserves_unrelated_text()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L62) (4 connections)
- [test_redact_rect_coordinates()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L125) (4 connections)
- [test_redact_text_phrase_purges_glyphs()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L28) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_redact.py#L21) (4 connections)
- [redact_pdf_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_redact.py#L45) (4 connections)
- [tools_redact.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_redact.py#L1) (3 connections)
- [test_redact_endpoint_no_targets_returns_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L234) (3 connections)
- [test_redact_endpoint_rects_success()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L210) (3 connections)
- [test_redact_endpoint_non_pdf_returns_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L248) (2 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_redact.py#L34) (2 connections)
- [pdf_redact_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_redact_service.py#L1) (1 connections)
- [Permanently redacts sensitive text glyphs, vector shapes, and raster pixel strea](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_redact_service.py#L17) (1 connections)
- [AC: Verifies coordinate-based redaction removes glyphs under specified bounding](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L126) (1 connections)
- [Helper to generate a minimal valid in-memory PDF with specified page text.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L15) (1 connections)
- [AC: Verifies ValueError when neither search_phrase nor rects are specified.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L164) (1 connections)
- [AC: POST /api/v1/tools/redact returns HTTP 200 with sanitized PDF stream.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L185) (1 connections)
- [AC: POST /api/v1/tools/redact accepts rects_json and applies redactions.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L211) (1 connections)
- [AC: POST /api/v1/tools/redact returns HTTP 400 Bad Request when no targets provi](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L235) (1 connections)
- [AC: POST /api/v1/tools/redact returns HTTP 400 when non-pdf is uploaded.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py#L249) (1 connections)
- *... and 6 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_redact.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_redact.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_redact_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_redact_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_redact.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_redact.py)

## Audit Trail

- EXTRACTED: 74 (83%)
- INFERRED: 15 (17%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*