# process_ocr_job()

> God node · 14 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\ocr_worker.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/ocr_worker.py#L46)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as process_ocr_job()
    participant P1 as compose_searchable_pdf()
    participant P2 as test_get_searchable_pdf_retrieval()
    participant P3 as get_searchable_pdf()
    participant P4 as _create_sample_pdf_bytes()
    participant P5 as test_compose_searchable_pdf_from_pdf()
    participant P6 as test_compose_searchable_pdf_from_image()
    participant P7 as _create_sample_image_bytes()
    participant P8 as test_ephemeral_file_cleanup_pdf_composer()
    participant P9 as repair_pdf()
    participant P10 as test_ocr_worker_integrates_pdf_composer()
    participant P11 as test_ocr_worker_corrupted_pdf_repair_integration()
    participant P12 as _publish_event()
    participant P13 as _store_job()
    participant P14 as _get_tessdata_dir()
    participant P15 as test_process_ocr_job_success()
    participant P16 as test_process_ocr_job_ephemeral_file_cleanup_on_exception()
    participant P17 as test_ocr_worker_decryption_process()
    participant P18 as test_ocr_worker_unrepairable_pdf_integration()
    participant P19 as test_process_ocr_job_image_file()
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
    P1->>+ P5: calls
    P5-->>- P1: return
    P5->>+ P1: calls
    P1-->>- P5: return
    P5->>+ P4: calls
    P4-->>- P5: return
    P1->>+ P6: calls
    P6-->>- P1: return
    P6->>+ P1: calls
    P1-->>- P6: return
    P6->>+ P7: calls
    P7-->>- P6: return
    P1->>+ P8: calls
    P8-->>- P1: return
    P8->>+ P1: calls
    P1-->>- P8: return
    P8->>+ P4: calls
    P4-->>- P8: return
    P0->>+ P9: calls
    P9-->>- P0: return
    P0->>+ P10: calls
    P10-->>- P0: return
    P0->>+ P11: calls
    P11-->>- P0: return
    P0->>+ P12: calls
    P12-->>- P0: return
    P0->>+ P13: calls
    P13-->>- P0: return
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
```

## Connections by Relation

### calls
- [[compose_searchable_pdf()]] `INFERRED`
- [[repair_pdf()]] `INFERRED`
- [[test_ocr_worker_integrates_pdf_composer()]] `INFERRED`
- [[test_ocr_worker_corrupted_pdf_repair_integration()]] `INFERRED`
- [[_publish_event()]] `EXTRACTED`
- [[_store_job()]] `EXTRACTED`
- [[_get_tessdata_dir()]] `EXTRACTED`
- [[test_process_ocr_job_success()]] `INFERRED`
- [[test_process_ocr_job_ephemeral_file_cleanup_on_exception()]] `INFERRED`
- [[test_ocr_worker_decryption_process()]] `INFERRED`
- [[test_ocr_worker_unrepairable_pdf_integration()]] `INFERRED`
- [[test_process_ocr_job_image_file()]] `INFERRED`

### contains
- [[ocr_worker.py]] `EXTRACTED`

### rationale_for
- [[Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*