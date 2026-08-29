# compose_searchable_pdf()

> God node · 7 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_composer.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/pdf_composer.py#L9)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as compose_searchable_pdf()
    participant P1 as process_ocr_job()
    participant P2 as repair_pdf()
    participant P3 as test_valid_pdf_repair_noop()
    participant P4 as test_corrupted_pdf_repair_success()
    participant P5 as test_unrepairable_garbage_pdf_failure()
    participant P6 as test_ocr_worker_integrates_pdf_composer()
    participant P7 as _create_sample_pdf_bytes()
    participant P8 as get_searchable_pdf()
    participant P9 as test_ocr_worker_corrupted_pdf_repair_integration()
    participant P10 as create_minimal_pdf_bytes()
    participant P11 as _publish_event()
    participant P12 as _store_job()
    participant P13 as _get_tessdata_dir()
    participant P14 as test_process_ocr_job_success()
    participant P15 as test_process_ocr_job_ephemeral_file_cleanup_on_exception()
    participant P16 as test_ocr_worker_decryption_process()
    participant P17 as test_ocr_worker_unrepairable_pdf_integration()
    participant P18 as test_process_ocr_job_image_file()
    participant P19 as test_get_searchable_pdf_retrieval()
    participant P20 as test_compose_searchable_pdf_from_pdf()
    participant P21 as test_compose_searchable_pdf_from_image()
    participant P22 as test_ephemeral_file_cleanup_pdf_composer()
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
    P1->>+ P6: calls
    P6-->>- P1: return
    P6->>+ P1: calls
    P1-->>- P6: return
    P6->>+ P7: calls
    P7-->>- P6: return
    P6->>+ P8: calls
    P8-->>- P6: return
    P1->>+ P9: calls
    P9-->>- P1: return
    P9->>+ P1: calls
    P1-->>- P9: return
    P9->>+ P10: calls
    P10-->>- P9: return
    P1->>+ P11: calls
    P11-->>- P1: return
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
    P0->>+ P19: calls
    P19-->>- P0: return
    P0->>+ P20: calls
    P20-->>- P0: return
    P0->>+ P21: calls
    P21-->>- P0: return
    P0->>+ P22: calls
    P22-->>- P0: return
```

## Connections by Relation

### calls
- [[process_ocr_job()]] `INFERRED`
- [[test_get_searchable_pdf_retrieval()]] `INFERRED`
- [[test_compose_searchable_pdf_from_pdf()]] `INFERRED`
- [[test_compose_searchable_pdf_from_image()]] `INFERRED`
- [[test_ephemeral_file_cleanup_pdf_composer()]] `INFERRED`

### contains
- [[pdf_composer.py]] `EXTRACTED`

### rationale_for
- [[Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*