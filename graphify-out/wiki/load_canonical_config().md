# load_canonical_config()

> God node · 9 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/config.py#L10)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as load_canonical_config()
    participant P1 as convert_document()
    participant P2 as get_redis_client()
    participant P3 as rewarded_ad_callback()
    participant P4 as check_redis_connection()
    participant P5 as get_ad_pass_metadata()
    participant P6 as email_download_links()
    participant P7 as store_ad_pass_metadata()
    participant P8 as download_job_file()
    participant P9 as store_job_metadata()
    participant P10 as get_job_metadata()
    participant P11 as stream_job_events()
    participant P12 as get_job_preview()
    participant P13 as _publish_event()
    participant P14 as _store_job()
    participant P15 as test_redis_client_configuration()
    participant P16 as _get_session_keys()
    participant P17 as analyze_pdf_bytes()
    participant P18 as _get_normalized_client_ip()
    participant P19 as get_runtime_config()
    participant P20 as test_adsense_config_interval_loaded()
    participant P21 as test_limit_config_values()
    participant P22 as .get_canonical_config()
    participant P23 as test_canonical_config_loader()
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
    P2->>+ P8: calls
    P8-->>- P2: return
    P2->>+ P9: calls
    P9-->>- P2: return
    P2->>+ P10: calls
    P10-->>- P2: return
    P2->>+ P11: calls
    P11-->>- P2: return
    P2->>+ P12: calls
    P12-->>- P2: return
    P2->>+ P13: calls
    P13-->>- P2: return
    P2->>+ P14: calls
    P14-->>- P2: return
    P2->>+ P15: calls
    P15-->>- P2: return
    P1->>+ P0: calls
    P0-->>- P1: return
    P1->>+ P5: calls
    P5-->>- P1: return
    P1->>+ P16: calls
    P16-->>- P1: return
    P1->>+ P17: calls
    P17-->>- P1: return
    P1->>+ P18: calls
    P18-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
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
- [[get_runtime_config()]] `INFERRED`
- [[test_adsense_config_interval_loaded()]] `INFERRED`
- [[test_limit_config_values()]] `INFERRED`
- [[.get_canonical_config()]] `EXTRACTED`
- [[test_canonical_config_loader()]] `INFERRED`

### contains
- [[config.py]] `EXTRACTED`

### rationale_for
- [[Loads the single canonical configuration file.]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*