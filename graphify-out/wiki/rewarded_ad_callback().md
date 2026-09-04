# rewarded_ad_callback()

> God node · 7 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/ocr.py#L301)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as rewarded_ad_callback()
    participant P1 as get_redis_client()
    participant P2 as convert_document()
    participant P3 as load_canonical_config()
    participant P4 as get_ad_pass_metadata()
    participant P5 as _get_session_keys()
    participant P6 as analyze_pdf_bytes()
    participant P7 as _get_normalized_client_ip()
    participant P8 as check_redis_connection()
    participant P9 as healthz()
    participant P10 as test_check_redis_connection_mocked_success()
    participant P11 as test_check_redis_connection_mocked_failure()
    participant P12 as email_download_links()
    participant P13 as store_ad_pass_metadata()
    participant P14 as get_job_page_image()
    participant P15 as download_job_file()
    participant P16 as store_job_metadata()
    participant P17 as get_job_metadata()
    participant P18 as stream_job_events()
    participant P19 as get_job_preview()
    participant P20 as _publish_event()
    participant P21 as _store_job()
    participant P22 as test_redis_client_configuration()
    P0->>+ P1: calls
    P1-->>- P0: return
    P1->>+ P2: calls
    P2-->>- P1: return
    P2->>+ P1: calls
    P1-->>- P2: return
    P2->>+ P3: calls
    P3-->>- P2: return
    P2->>+ P4: calls
    P4-->>- P2: return
    P2->>+ P5: calls
    P5-->>- P2: return
    P2->>+ P6: calls
    P6-->>- P2: return
    P2->>+ P7: calls
    P7-->>- P2: return
    P1->>+ P0: calls
    P0-->>- P1: return
    P1->>+ P8: calls
    P8-->>- P1: return
    P8->>+ P1: calls
    P1-->>- P8: return
    P8->>+ P9: calls
    P9-->>- P8: return
    P8->>+ P10: calls
    P10-->>- P8: return
    P8->>+ P11: calls
    P11-->>- P8: return
    P1->>+ P4: calls
    P4-->>- P1: return
    P1->>+ P12: calls
    P12-->>- P1: return
    P1->>+ P13: calls
    P13-->>- P1: return
    P1->>+ P14: calls
    P14-->>- P1: return
    P1->>+ P15: calls
    P15-->>- P1: return
    P1->>+ P16: calls
    P16-->>- P1: return
    P1->>+ P17: calls
    P17-->>- P1: return
    P1->>+ P18: calls
    P18-->>- P1: return
    P1->>+ P19: calls
    P19-->>- P1: return
    P1->>+ P20: calls
    P20-->>- P1: return
    P1->>+ P21: calls
    P21-->>- P1: return
    P1->>+ P22: calls
    P22-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P4: calls
    P4-->>- P0: return
    P0->>+ P5: calls
    P5-->>- P0: return
    P0->>+ P13: calls
    P13-->>- P0: return
```

## Connections by Relation

### calls
- [[get_redis_client()]] `INFERRED`
- [[load_canonical_config()]] `INFERRED`
- [[get_ad_pass_metadata()]] `INFERRED`
- [[_get_session_keys()]] `EXTRACTED`
- [[store_ad_pass_metadata()]] `INFERRED`

### contains
- [[ocr.py]] `EXTRACTED`

### rationale_for
- [[Validates rewarded ad view and stacks user limits (+20MB, +15 pages).     Reset]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*