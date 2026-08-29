# convert_document()

> God node · 8 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/ocr.py#L140)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as convert_document()
    participant P1 as get_redis_client()
    participant P2 as rewarded_ad_callback()
    participant P3 as load_canonical_config()
    participant P4 as get_ad_pass_metadata()
    participant P5 as _get_session_keys()
    participant P6 as store_ad_pass_metadata()
    participant P7 as check_redis_connection()
    participant P8 as healthz()
    participant P9 as test_check_redis_connection_mocked_success()
    participant P10 as test_check_redis_connection_mocked_failure()
    participant P11 as email_download_links()
    participant P12 as download_job_file()
    participant P13 as store_job_metadata()
    participant P14 as get_job_metadata()
    participant P15 as stream_job_events()
    participant P16 as get_job_preview()
    participant P17 as _publish_event()
    participant P18 as _store_job()
    participant P19 as test_redis_client_configuration()
    participant P20 as analyze_pdf_bytes()
    participant P21 as _get_normalized_client_ip()
    P0->>+ P1: calls
    P1-->>- P0: return
    P1->>+ P0: calls
    P0-->>- P1: return
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
    P1->>+ P7: calls
    P7-->>- P1: return
    P7->>+ P1: calls
    P1-->>- P7: return
    P7->>+ P8: calls
    P8-->>- P7: return
    P7->>+ P9: calls
    P9-->>- P7: return
    P7->>+ P10: calls
    P10-->>- P7: return
    P1->>+ P4: calls
    P4-->>- P1: return
    P4->>+ P1: calls
    P1-->>- P4: return
    P4->>+ P0: calls
    P0-->>- P4: return
    P4->>+ P2: calls
    P2-->>- P4: return
    P1->>+ P11: calls
    P11-->>- P1: return
    P1->>+ P6: calls
    P6-->>- P1: return
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
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P4: calls
    P4-->>- P0: return
    P0->>+ P5: calls
    P5-->>- P0: return
    P0->>+ P20: calls
    P20-->>- P0: return
    P0->>+ P21: calls
    P21-->>- P0: return
```

## Connections by Relation

### calls
- [[get_redis_client()]] `INFERRED`
- [[load_canonical_config()]] `INFERRED`
- [[get_ad_pass_metadata()]] `INFERRED`
- [[_get_session_keys()]] `EXTRACTED`
- [[analyze_pdf_bytes()]] `INFERRED`
- [[_get_normalized_client_ip()]] `EXTRACTED`

### contains
- [[ocr.py]] `EXTRACTED`

### rationale_for
- [[Endpoint for uploading PDF/image files for OCR conversion.     Validates extens]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*