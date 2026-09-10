# get_ad_pass_metadata()

> God node · 6 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L142)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as get_ad_pass_metadata()
    participant P1 as .get()
    participant P2 as convert_document()
    participant P3 as get_redis_client()
    participant P4 as load_canonical_config()
    participant P5 as _get_session_keys()
    participant P6 as _get_normalized_client_ip()
    participant P7 as analyze_pdf_bytes()
    participant P8 as rewarded_ad_callback()
    participant P9 as store_ad_pass_metadata()
    participant P10 as process_ocr_job()
    participant P11 as get_searchable_pdf()
    participant P12 as email_download_links()
    participant P13 as get_job_page_image()
    participant P14 as batch_download_zip()
    participant P15 as download_job_file()
    participant P16 as get_baidu_ocr_engine()
    participant P17 as compose_searchable_pdf()
    participant P18 as store_job_metadata()
    participant P19 as get_job_metadata()
    participant P20 as get_job_status()
    participant P21 as stream_job_events()
    participant P22 as get_job_preview()
    participant P23 as send_download_links_email()
    participant P24 as verify_internal_secret()
    participant P25 as purge_ephemeral_ram_disk()
    participant P26 as .__init__()
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
    P2->>+ P0: calls
    P0-->>- P2: return
    P2->>+ P5: calls
    P5-->>- P2: return
    P2->>+ P6: calls
    P6-->>- P2: return
    P2->>+ P7: calls
    P7-->>- P2: return
    P1->>+ P8: calls
    P8-->>- P1: return
    P8->>+ P1: calls
    P1-->>- P8: return
    P8->>+ P3: calls
    P3-->>- P8: return
    P8->>+ P4: calls
    P4-->>- P8: return
    P8->>+ P0: calls
    P0-->>- P8: return
    P8->>+ P5: calls
    P5-->>- P8: return
    P8->>+ P9: calls
    P9-->>- P8: return
    P1->>+ P10: calls
    P10-->>- P1: return
    P1->>+ P11: calls
    P11-->>- P1: return
    P1->>+ P0: calls
    P0-->>- P1: return
    P1->>+ P12: calls
    P12-->>- P1: return
    P1->>+ P13: calls
    P13-->>- P1: return
    P1->>+ P14: calls
    P14-->>- P1: return
    P1->>+ P15: calls
    P15-->>- P1: return
    P1->>+ P5: calls
    P5-->>- P1: return
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
    P1->>+ P6: calls
    P6-->>- P1: return
    P1->>+ P23: calls
    P23-->>- P1: return
    P1->>+ P24: calls
    P24-->>- P1: return
    P1->>+ P7: calls
    P7-->>- P1: return
    P1->>+ P25: calls
    P25-->>- P1: return
    P1->>+ P26: calls
    P26-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P2: calls
    P2-->>- P0: return
    P0->>+ P8: calls
    P8-->>- P0: return
```

## Connections by Relation

### calls
- [[.get()]] `EXTRACTED`
- [[get_redis_client()]] `EXTRACTED`
- [[convert_document()]] `INFERRED`
- [[rewarded_ad_callback()]] `INFERRED`

### contains
- [[redis_client.py]] `EXTRACTED`

### rationale_for
- [[Retrieves ad pass payload dict from Redis, falling back to in-memory store.]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*