# Community 20

> 31 nodes · cohesion 0.09

## Key Concepts

- [test_tools_rotate.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L1) (10 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L14) (10 connections)
- [rotate_pdf_pages()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_rotate_service.py#L10) (7 connections)
- [test_rotate_endpoint_invalid_angle_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L125) (4 connections)
- [test_rotate_endpoint_out_of_bounds_page_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L136) (4 connections)
- [test_rotate_endpoint_single_page_90_degrees()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L90) (4 connections)
- [test_rotate_pdf_pages_service_applies_rotation()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L28) (4 connections)
- [test_rotate_pdf_pages_service_cumulative_and_negative_rotation()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L48) (4 connections)
- [test_rotate_pdf_pages_service_invalid_angle_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L65) (4 connections)
- [test_rotate_pdf_pages_service_out_of_bounds_page_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L76) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_rotate.py#L22) (4 connections)
- [rotate_pdf_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_rotate.py#L46) (4 connections)
- [tools_rotate.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_rotate.py#L1) (3 connections)
- [test_rotate_endpoint_multiple_pages()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L109) (3 connections)
- [test_rotate_endpoint_rejects_non_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L147) (3 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_rotate.py#L35) (2 connections)
- [pdf_rotate_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_rotate_service.py#L1) (1 connections)
- [Applies page-specific rotations to a PDF document and saves the result.      A](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_rotate_service.py#L15) (1 connections)
- [AC: Submitting multiple page rotations applies all specified angles.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L110) (1 connections)
- [AC: Submitting an angle of 45° returns HTTP 422 Unprocessable Entity.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L126) (1 connections)
- [AC: Submitting rotation for a page index beyond document length returns 422.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L137) (1 connections)
- [AC: Non-PDF upload returns HTTP 400 Bad Request.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L148) (1 connections)
- [Helper to generate a minimal valid in-memory PDF with specified page text.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L15) (1 connections)
- [Validates that rotate_pdf_pages applies rotation angles accurately.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L29) (1 connections)
- [Validates negative rotations (e.g. -90 -> 270) and modulo 360 arithmetic.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py#L49) (1 connections)
- *... and 6 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_rotate.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_rotate.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_rotate_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_rotate_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_rotate.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_rotate.py)

## Audit Trail

- EXTRACTED: 74 (83%)
- INFERRED: 15 (17%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*