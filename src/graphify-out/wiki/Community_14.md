# Community 14

> 37 nodes · cohesion 0.07

## Key Concepts

- [test_tools_split.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L1) (11 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L13) (8 connections)
- [parse_page_ranges()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L7) (6 connections)
- [split_pdf_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_split.py#L46) (5 connections)
- [split_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L78) (4 connections)
- [test_split_multi_range_returns_zip_with_expected_files()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L91) (4 connections)
- [test_split_single_range_returns_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L72) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_split.py#L22) (4 connections)
- [tools_split.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_split.py#L1) (3 connections)
- [pdf_split_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L1) (3 connections)
- [create_zip_archive()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L69) (3 connections)
- [test_parse_page_ranges_invalid_syntax_raises_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L54) (3 connections)
- [test_parse_page_ranges_out_of_bounds_raises_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L42) (3 connections)
- [test_parse_page_ranges_valid_syntax()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L27) (3 connections)
- [test_split_all_mode_returns_zip()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L136) (3 connections)
- [test_split_fixed_mode_returns_zip()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L122) (3 connections)
- [test_split_invalid_syntax_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L150) (3 connections)
- [test_split_out_of_bounds_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L161) (3 connections)
- [test_split_rejects_non_pdf_file()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L172) (2 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_split.py#L35) (2 connections)
- [Creates a clean zip archive containing the provided files.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L70) (1 connections)
- [Parses a page range string (e.g. '1-3, 5, 8-10') into a list of 0-indexed page n](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L8) (1 connections)
- [Splits a PDF into separate files according to the provided 0-indexed page ranges](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py#L84) (1 connections)
- [AC: Splitting every N pages produces a ZIP archive of chunked PDFs.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L123) (1 connections)
- [AC: Extracting all pages produces a ZIP with each individual page as a separate](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py#L137) (1 connections)
- *... and 12 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_split.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_split.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_split_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_split_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_split.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_split.py)

## Audit Trail

- EXTRACTED: 84 (87%)
- INFERRED: 13 (13%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*