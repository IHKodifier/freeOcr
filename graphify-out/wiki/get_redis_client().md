# get_redis_client()

> God node · 15 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L9)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as get_redis_client()
    participant P1 as convert_document()
    participant P2 as load_canonical_config()
    participant P3 as rewarded_ad_callback()
    participant P4 as get_runtime_config()
    participant P5 as test_adsense_config_interval_loaded()
    participant P6 as test_limit_config_values()
    participant P7 as .get_canonical_config()
    participant P8 as test_canonical_config_loader()
    participant P9 as get_ad_pass_metadata()
    participant P10 as _get_session_keys()
    participant P11 as analyze_pdf_bytes()
    participant P12 as _get_normalized_client_ip()
    participant P13 as check_redis_connection()
    participant P14 as email_download_links()
    participant P15 as store_ad_pass_metadata()
    participant P16 as download_job_file()
    participant P17 as store_job_metadata()
    participant P18 as get_job_metadata()
    participant P19 as stream_job_events()
    participant P20 as get_job_preview()
    participant P21 as _publish_event()
    participant P22 as _store_job()
    participant P23 as test_redis_client_configuration()
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
    P2->>+ P7: calls
    P7-->>- P2: return
    P2->>+ P8: calls
    P8-->>- P2: return
    P1->>+ P9: calls
    P9-->>- P1: return
    P9->>+ P0: calls
    P0-->>- P9: return
    P9->>+ P1: calls
    P1-->>- P9: return
    P9->>+ P3: calls
    P3-->>- P9: return
    P1->>+ P10: calls
    P10-->>- P1: return
    P1->>+ P11: calls
    P11-->>- P1: return
    P1->>+ P12: calls
    P12-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P13: calls
    P13-->>- P0: return
    P0->>+ P9: calls
    P9-->>- P0: return
    P0->>+ P14: calls
    P14-->>- P0: return
    P0->>+ P15: calls
    P15-->>- P0: return
    P0->>+ P16: calls
    P16-->>- P0: return
    P0->>+ P17: calls
    P17-->>- P0: return
    P0->>+ P18: calls
    P18-->>- P0: return
    P0->>+ P19: calls
    P19-->>- P0: return
    P0->>+ P20: calls
    P20-->>- P0: return
    P0->>+ P21: calls
    P21-->>- P0: return
    P0->>+ P22: calls
    P22-->>- P0: return
    P0->>+ P23: calls
    P23-->>- P0: return
```

## Connections by Relation

### calls
- [[convert_document()]] `INFERRED`
- [[rewarded_ad_callback()]] `INFERRED`
- [[check_redis_connection()]] `EXTRACTED`
- [[get_ad_pass_metadata()]] `EXTRACTED`
- [[email_download_links()]] `INFERRED`
- [[store_ad_pass_metadata()]] `EXTRACTED`
- [[download_job_file()]] `INFERRED`
- [[store_job_metadata()]] `EXTRACTED`
- [[get_job_metadata()]] `EXTRACTED`
- [[stream_job_events()]] `INFERRED`
- [[get_job_preview()]] `INFERRED`
- [[_publish_event()]] `INFERRED`
- [[_store_job()]] `INFERRED`
- [[test_redis_client_configuration()]] `INFERRED`

### contains
- [[redis_client.py]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*