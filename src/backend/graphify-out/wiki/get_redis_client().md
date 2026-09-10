# get_redis_client()

> God node · 19 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L89)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as get_redis_client()
    participant P1 as convert_document()
    participant P2 as .get()
    participant P3 as rewarded_ad_callback()
    participant P4 as process_ocr_job()
    participant P5 as get_searchable_pdf()
    participant P6 as get_ad_pass_metadata()
    participant P7 as email_download_links()
    participant P8 as get_job_page_image()
    participant P9 as batch_download_zip()
    participant P10 as download_job_file()
    participant P11 as _get_session_keys()
    participant P12 as get_baidu_ocr_engine()
    participant P13 as compose_searchable_pdf()
    participant P14 as store_job_metadata()
    participant P15 as get_job_metadata()
    participant P16 as get_job_status()
    participant P17 as stream_job_events()
    participant P18 as get_job_preview()
    participant P19 as _get_normalized_client_ip()
    participant P20 as send_download_links_email()
    participant P21 as verify_internal_secret()
    participant P22 as analyze_pdf_bytes()
    participant P23 as purge_ephemeral_ram_disk()
    participant P24 as .__init__()
    participant P25 as load_canonical_config()
    participant P26 as store_ad_pass_metadata()
    participant P27 as check_redis_connection()
    participant P28 as _publish_event()
    participant P29 as _store_job()
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
    P2->>+ P16: calls
    P16-->>- P2: return
    P2->>+ P17: calls
    P17-->>- P2: return
    P2->>+ P18: calls
    P18-->>- P2: return
    P2->>+ P19: calls
    P19-->>- P2: return
    P2->>+ P20: calls
    P20-->>- P2: return
    P2->>+ P21: calls
    P21-->>- P2: return
    P2->>+ P22: calls
    P22-->>- P2: return
    P2->>+ P23: calls
    P23-->>- P2: return
    P2->>+ P24: calls
    P24-->>- P2: return
    P1->>+ P0: calls
    P0-->>- P1: return
    P1->>+ P25: calls
    P25-->>- P1: return
    P1->>+ P6: calls
    P6-->>- P1: return
    P1->>+ P11: calls
    P11-->>- P1: return
    P1->>+ P19: calls
    P19-->>- P1: return
    P1->>+ P22: calls
    P22-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P5: calls
    P5-->>- P0: return
    P0->>+ P6: calls
    P6-->>- P0: return
    P0->>+ P7: calls
    P7-->>- P0: return
    P0->>+ P8: calls
    P8-->>- P0: return
    P0->>+ P9: calls
    P9-->>- P0: return
    P0->>+ P10: calls
    P10-->>- P0: return
    P0->>+ P13: calls
    P13-->>- P0: return
    P0->>+ P14: calls
    P14-->>- P0: return
    P0->>+ P15: calls
    P15-->>- P0: return
    P0->>+ P26: calls
    P26-->>- P0: return
    P0->>+ P16: calls
    P16-->>- P0: return
    P0->>+ P17: calls
    P17-->>- P0: return
    P0->>+ P18: calls
    P18-->>- P0: return
    P0->>+ P27: calls
    P27-->>- P0: return
    P0->>+ P28: calls
    P28-->>- P0: return
    P0->>+ P29: calls
    P29-->>- P0: return
```

## Connections by Relation

### calls
- [[convert_document()]] `INFERRED`
- [[rewarded_ad_callback()]] `INFERRED`
- [[get_searchable_pdf()]] `INFERRED`
- [[get_ad_pass_metadata()]] `EXTRACTED`
- [[email_download_links()]] `INFERRED`
- [[get_job_page_image()]] `INFERRED`
- [[batch_download_zip()]] `INFERRED`
- [[download_job_file()]] `INFERRED`
- [[compose_searchable_pdf()]] `INFERRED`
- [[store_job_metadata()]] `EXTRACTED`
- [[get_job_metadata()]] `EXTRACTED`
- [[store_ad_pass_metadata()]] `EXTRACTED`
- [[get_job_status()]] `INFERRED`
- [[stream_job_events()]] `INFERRED`
- [[get_job_preview()]] `INFERRED`
- [[check_redis_connection()]] `EXTRACTED`
- [[_publish_event()]] `INFERRED`
- [[_store_job()]] `INFERRED`

### contains
- [[redis_client.py]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*