# Community 13

> 37 nodes · cohesion 0.07

## Key Concepts

- [test_tools_extract_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L1) (12 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L18) (8 connections)
- [parse_extract_page_numbers()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py#L12) (7 connections)
- [extract_pdf_pages()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py#L109) (6 connections)
- [test_extract_endpoint_merged_produces_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L138) (4 connections)
- [test_extract_endpoint_separate_produces_zip()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L156) (4 connections)
- [test_extract_invalid_pages_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L127) (4 connections)
- [test_extract_no_pages_returns_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L172) (4 connections)
- [test_extract_pages_merged_produces_correct_page_count()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L62) (4 connections)
- [test_extract_pages_separate_produces_zip()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L87) (4 connections)
- [extract_pages_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_extract_pages.py#L45) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_extract_pages.py#L21) (4 connections)
- [tools_extract_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_extract_pages.py#L1) (3 connections)
- [test_extract_non_pdf_returns_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L183) (3 connections)
- [test_parse_extract_page_numbers_deduplicates_and_sorts()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L41) (3 connections)
- [test_parse_extract_page_numbers_empty_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L54) (3 connections)
- [test_parse_extract_page_numbers_out_of_bounds_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L46) (3 connections)
- [test_parse_extract_page_numbers_valid_cases()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L32) (3 connections)
- [pdf_extract_pages_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py#L1) (2 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_extract_pages.py#L34) (2 connections)
- [Extracts specified pages from a PDF document into a merged single PDF or separat](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py#L116) (1 connections)
- [Parses a page selection specification (comma-separated, ranges like '2-4', JSON](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py#L16) (1 connections)
- [AC: Requesting page 99 on a 3-page document returns HTTP 422.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L128) (1 connections)
- [Verifies endpoint returns merged PDF with correct content and headers.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L139) (1 connections)
- [Verifies endpoint returns ZIP archive containing separate extracted pages.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py#L157) (1 connections)
- *... and 12 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_extract_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_extract_pages.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_extract_pages_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_extract_pages_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_extract_pages.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_extract_pages.py)

## Audit Trail

- EXTRACTED: 84 (81%)
- INFERRED: 20 (19%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*