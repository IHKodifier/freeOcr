# Community 17

> 33 nodes · cohesion 0.09

## Key Concepts

- [test_tools_delete_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L1) (10 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L14) (10 connections)
- [delete_pdf_pages()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_delete_pages_service.py#L10) (7 connections)
- [delete_pages_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py#L69) (5 connections)
- [tools_delete_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py#L1) (4 connections)
- [test_delete_pages_endpoint_out_of_bounds_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L142) (4 connections)
- [test_delete_pages_endpoint_removes_pages_and_streams_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L109) (4 connections)
- [test_delete_pages_handles_duplicate_indices_gracefully()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L52) (4 connections)
- [test_delete_pages_rejects_100_percent_deletion_with_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L98) (4 connections)
- [test_delete_pages_removes_specified_pages_accurately()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L28) (4 connections)
- [test_delete_pages_service_out_of_bounds_page_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L84) (4 connections)
- [test_delete_pages_service_rejects_100_percent_deletion()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L73) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py#L21) (4 connections)
- [test_delete_pages_endpoint_comma_separated_format()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L127) (3 connections)
- [test_delete_pages_endpoint_rejects_non_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L153) (3 connections)
- [parse_page_indices()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py#L44) (3 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py#L34) (2 connections)
- [pdf_delete_pages_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_delete_pages_service.py#L1) (1 connections)
- [Deletes specified 0-indexed pages from a PDF document and saves the pruned resul](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_delete_pages_service.py#L15) (1 connections)
- [AC: Successfully deletes pages and returns pruned PDF with attachment header.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L110) (1 connections)
- [AC: Supports comma-separated string for page indices.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L128) (1 connections)
- [AC: Submitting page index outside document range returns HTTP 422.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L143) (1 connections)
- [Helper to generate a minimal valid in-memory PDF with specified page text.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L15) (1 connections)
- [AC: Non-PDF upload returns HTTP 400 Bad Request.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L154) (1 connections)
- [AC: Creates a 5-page document, deletes pages [1, 3], verifies output has exactly](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py#L29) (1 connections)
- *... and 8 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_delete_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_delete_pages.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_delete_pages_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_delete_pages_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_delete_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_delete_pages.py)

## Audit Trail

- EXTRACTED: 80 (84%)
- INFERRED: 15 (16%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*