# convert_document()

> God node · 9 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/api/v1/endpoints/ocr.py#L140)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as convert_document()
    participant P1 as .get()
    participant P2 as rewarded_ad_callback()
    participant P3 as get_redis_client()
    participant P4 as load_canonical_config()
    participant P5 as get_ad_pass_metadata()
    participant P6 as _get_session_keys()
    participant P7 as store_ad_pass_metadata()
    participant P8 as process_ocr_job()
    participant P9 as compose_searchable_pdf()
    participant P10 as _publish_event()
    participant P11 as _store_job()
    participant P12 as _get_tessdata_dir()
    participant P13 as repair_pdf()
    participant P14 as get_searchable_pdf()
    participant P15 as email_download_links()
    participant P16 as get_job_page_image()
    participant P17 as batch_download_zip()
    participant P18 as download_job_file()
    participant P19 as get_baidu_ocr_engine()
    participant P20 as store_job_metadata()
    participant P21 as get_job_metadata()
    participant P22 as get_job_status()
    participant P23 as stream_job_events()
    participant P24 as get_job_preview()
    participant P25 as _get_normalized_client_ip()
    participant P26 as send_download_links_email()
    participant P27 as verify_internal_secret()
    participant P28 as analyze_pdf_bytes()
    participant P29 as purge_ephemeral_ram_disk()
    participant P30 as .__init__()
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
    P8->>+ P12: calls
    P12-->>- P8: return
    P8->>+ P13: calls
    P13-->>- P8: return
    P1->>+ P14: calls
    P14-->>- P1: return
    P1->>+ P5: calls
    P5-->>- P1: return
    P1->>+ P15: calls
    P15-->>- P1: return
    P1->>+ P16: calls
    P16-->>- P1: return
    P1->>+ P17: calls
    P17-->>- P1: return
    P1->>+ P18: calls
    P18-->>- P1: return
    P1->>+ P6: calls
    P6-->>- P1: return
    P1->>+ P19: calls
    P19-->>- P1: return
    P1->>+ P9: calls
    P9-->>- P1: return
    P1->>+ P20: calls
    P20-->>- P1: return
    P1->>+ P21: calls
    P21-->>- P1: return
    P1->>+ P22: calls
    P22-->>- P1: return
    P1->>+ P23: calls
    P23-->>- P1: return
    P1->>+ P24: calls
    P24-->>- P1: return
    P1->>+ P25: calls
    P25-->>- P1: return
    P1->>+ P26: calls
    P26-->>- P1: return
    P1->>+ P27: calls
    P27-->>- P1: return
    P1->>+ P28: calls
    P28-->>- P1: return
    P1->>+ P29: calls
    P29-->>- P1: return
    P1->>+ P30: calls
    P30-->>- P1: return
    P0->>+ P3: calls
    P3-->>- P0: return
    P0->>+ P4: calls
    P4-->>- P0: return
    P0->>+ P5: calls
    P5-->>- P0: return
    P0->>+ P6: calls
    P6-->>- P0: return
    P0->>+ P25: calls
    P25-->>- P0: return
    P0->>+ P28: calls
    P28-->>- P0: return
```

## Connections by Relation

### calls
- [[.get()]] `INFERRED`
- [[get_redis_client()]] `INFERRED`
- [[load_canonical_config()]] `INFERRED`
- [[get_ad_pass_metadata()]] `INFERRED`
- [[_get_session_keys()]] `EXTRACTED`
- [[_get_normalized_client_ip()]] `EXTRACTED`
- [[analyze_pdf_bytes()]] `INFERRED`

### contains
- [[ocr.py]] `EXTRACTED`

### rationale_for
- [[Endpoint for uploading PDF/image files for OCR conversion.     Validates extens]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*