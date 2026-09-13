# Community 4

> 65 nodes · cohesion 0.05

## Key Concepts

- [get_redis_client()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L89) (20 connections)
- [EphemeralRamStore](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L9) (19 connections)
- [compose_searchable_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_composer.py#L12) (12 connections)
- [get_searchable_pdf()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_composer.py#L130) (10 connections)
- [redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L1) (9 connections)
- [test_pdf_composer.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_composer.py#L1) (9 connections)
- [jobs.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L1) (6 connections)
- [get_ad_pass_metadata()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L142) (6 connections)
- [_create_sample_pdf_bytes()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_composer.py#L9) (6 connections)
- [main.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/main.py#L1) (5 connections)
- [batch_download_zip()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L344) (5 connections)
- [download_job_file()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L456) (5 connections)
- [get_job_page_image()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L227) (5 connections)
- [check_redis_connection()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L93) (5 connections)
- [._file_path()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L20) (5 connections)
- [get_job_preview()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L179) (4 connections)
- [get_job_status()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L22) (4 connections)
- [stream_job_events()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py#L56) (4 connections)
- [healthz()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/main.py#L39) (4 connections)
- [.__getitem__()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L25) (4 connections)
- [get_job_metadata()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L115) (4 connections)
- [store_ad_pass_metadata()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L129) (4 connections)
- [store_job_metadata()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L101) (4 connections)
- [test_ephemeral_file_cleanup_pdf_composer()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_composer.py#L105) (4 connections)
- [test_get_searchable_pdf_from_redis_when_local_cache_misses()](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_composer.py#L141) (4 connections)
- *... and 40 more nodes in this community*

## Class Diagram

```mermaid
classDiagram
    class EphemeralRamStore {
        +redis_client.py()
        +.__init__()
        +._file_path()
        +.__getitem__()
        +.__setitem__()
        +.__contains__()
        +.get()
        +.clear()
    }
```

## Relationships

- [[Community 3]] (29 shared connections)

## Source Files

- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/jobs.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\router.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/router.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/main.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_composer.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_composer.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_complex_pdf_reconstruction.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_complex_pdf_reconstruction.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_pdf_composer.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_pdf_composer.py)
- [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_redis.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/tests/test_redis.py)

## Audit Trail

- EXTRACTED: 157 (63%)
- INFERRED: 91 (37%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*