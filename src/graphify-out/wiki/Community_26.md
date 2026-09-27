# Community 26

> 29 nodes · cohesion 0.09

## Key Concepts

- [test_tools_compress.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L1) (9 connections)
- [compress_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_compress_service.py#L13) (8 connections)
- [create_test_pdf_with_image()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L16) (7 connections)
- [test_compress_pdf_extreme_preset()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L70) (4 connections)
- [test_compress_pdf_lossless_preset()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L95) (4 connections)
- [test_compress_pdf_recommended_reduces_or_maintains_size()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L40) (4 connections)
- [compress_pdf_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_compress.py#L44) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_compress.py#L20) (4 connections)
- [tools_compress.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_compress.py#L1) (3 connections)
- [test_compress_endpoint_invalid_level()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L205) (3 connections)
- [test_compress_endpoint_success()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L166) (3 connections)
- [test_compress_invalid_level_raises_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L147) (3 connections)
- [test_compress_pdf_byte_size_guard()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L121) (3 connections)
- [test_compress_endpoint_invalid_file_type()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L195) (2 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_compress.py#L33) (2 connections)
- [pdf_compress_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_compress_service.py#L1) (1 connections)
- [Compresses an input PDF document using stream optimization, object deduplication](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_compress_service.py#L18) (1 connections)
- [AC: For a minimal PDF that cannot be further compressed, the output     must NE](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L122) (1 connections)
- [AC: Providing an unapproved compression preset raises ValueError.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L148) (1 connections)
- [AC: POST /api/v1/tools/compress with valid PDF and level returns     HTTP 200,](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L167) (1 connections)
- [Helper to generate a PDF containing raster image content and text.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L17) (1 connections)
- [AC: Uploading a non-PDF file returns HTTP 400.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L196) (1 connections)
- [AC: Specifying an invalid compression level returns HTTP 422.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L206) (1 connections)
- [AC: Compresses PDF with 'recommended' preset.     Asserts returned metrics stru](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L41) (1 connections)
- [AC: Compresses PDF with 'extreme' preset.     Asserts valid document output and](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py#L71) (1 connections)
- *... and 4 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_compress.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_compress.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_compress_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_compress_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_compress.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_compress.py)

## Audit Trail

- EXTRACTED: 64 (83%)
- INFERRED: 13 (17%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*