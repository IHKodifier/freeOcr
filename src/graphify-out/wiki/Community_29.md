# Community 29

> 27 nodes · cohesion 0.10

## Key Concepts

- [test_tools_crop.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L1) (8 connections)
- [create_mock_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L13) (8 connections)
- [crop_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_crop_service.py#L10) (7 connections)
- [test_crop_endpoint_success()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L148) (4 connections)
- [test_crop_pdf_applies_new_cropbox_dimensions()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L27) (4 connections)
- [test_crop_pdf_excessive_margins_raises_value_error()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L86) (4 connections)
- [test_crop_pdf_preserves_vector_and_text()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L61) (4 connections)
- [test_crop_pdf_single_page_vs_all_pages()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L115) (4 connections)
- [crop_pdf_endpoint()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py#L45) (4 connections)
- [get_max_file_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py#L21) (4 connections)
- [tools_crop.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py#L1) (3 connections)
- [test_crop_endpoint_excessive_margins_returns_422()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L187) (3 connections)
- [test_crop_endpoint_non_pdf_returns_400()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L175) (2 connections)
- [cleanup_directory()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py#L34) (2 connections)
- [pdf_crop_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_crop_service.py#L1) (1 connections)
- [Applies margin cropping by updating page /CropBox dimensions without deleting](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_crop_service.py#L20) (1 connections)
- [AC: Cropping target_page=0 modifies page 0 while leaving page 1 unchanged when a](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L116) (1 connections)
- [Helper to generate a minimal valid in-memory PDF with specified page text.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L14) (1 connections)
- [AC: POST /api/v1/tools/crop returns HTTP 200 and a valid cropped PDF stream.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L149) (1 connections)
- [AC: Uploading non-PDF file returns HTTP 400 Bad Request.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L176) (1 connections)
- [AC: Margins exceeding PDF boundaries return HTTP 422 Unprocessable Entity.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L188) (1 connections)
- [AC: Asserts cropped document has its /CropBox updated according to margins.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L28) (1 connections)
- [AC: Verifies underlying text and paths remain intact inside the document.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L62) (1 connections)
- [AC: Verifies margins equal to or greater than page width/height raise ValueError](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py#L87) (1 connections)
- [Reads base limit from app_limits_config.json or falls back to 100MB.](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py#L22) (1 connections)
- *... and 2 more nodes in this community*

## Relationships

- No strong cross-community connections detected

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\tools_crop.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/tools_crop.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_crop_service.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_crop_service.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_tools_crop.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_tools_crop.py)

## Audit Trail

- EXTRACTED: 62 (84%)
- INFERRED: 12 (16%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*