# process_ocr_job()

> God node · 19 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\ocr_worker.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/ocr_worker.py#L134)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as process_ocr_job()
    participant P1 as .get()
    participant P2 as compose_searchable_pdf()
    participant P3 as get_redis_client()
    participant P4 as test_get_searchable_pdf_retrieval()
    participant P5 as test_ephemeral_file_cleanup_pdf_composer()
    participant P6 as test_complex_two_column_pdf_reconstruction()
    participant P7 as test_word_level_highlight_alignment_and_space_distribution()
    participant P8 as test_compose_searchable_pdf_from_pdf()
    participant P9 as test_compose_searchable_pdf_from_image()
    participant P10 as test_compose_searchable_pdf_with_rotation_and_morph_scaling()
    participant P11 as get_searchable_pdf()
    participant P12 as get_job_page_image()
    participant P13 as batch_download_zip()
    participant P14 as download_job_file()
    participant P15 as test_ocr_worker_integrates_pdf_composer()
    participant P16 as test_get_searchable_pdf_from_redis_when_local_cache_misses()
    participant P17 as convert_document()
    participant P18 as rewarded_ad_callback()
    participant P19 as send_download_links_email()
    participant P20 as analyze_pdf_bytes()
    participant P21 as get_ad_pass_metadata()
    participant P22 as email_download_links()
    participant P23 as submit_contact_form()
    participant P24 as _get_session_keys()
    participant P25 as get_baidu_ocr_engine()
    participant P26 as parse_grounding_output()
    participant P27 as purge_ephemeral_ram_disk()
    participant P28 as test_ocr_worker_dispatches_to_baidu_gpu_service()
    participant P29 as test_ocr_worker_corrupted_pdf_repair_integration()
    participant P30 as store_job_metadata()
    participant P31 as get_job_metadata()
    participant P32 as get_job_status()
    participant P33 as stream_job_events()
    participant P34 as get_job_preview()
    participant P35 as _get_normalized_client_ip()
    participant P36 as send_contact_inquiry_email()
    participant P37 as test_page_image_valid_completed_job_returns_png()
    participant P38 as test_page_image_out_of_range_page_returns_404()
    participant P39 as test_process_ocr_job_ephemeral_file_cleanup_on_exception()
    participant P40 as test_ocr_worker_decryption_process()
    participant P41 as verify_internal_secret()
    participant P42 as test_adsense_config_api_endpoint()
    participant P43 as test_dynamic_config_file_reload()
    participant P44 as test_baidu_gpu_service_health()
    participant P45 as test_download_invalid_format_returns_400()
    participant P46 as test_download_non_existent_job_returns_410_gone()
    participant P47 as test_download_pdf_success_and_purges_ram_disk()
    participant P48 as test_download_txt_success()
    participant P49 as test_download_md_success()
    participant P50 as test_batch_download_zip_success()
    participant P51 as test_batch_download_zip_invalid_format()
    participant P52 as test_download_all_formats_from_redis_on_cold_boot()
    participant P53 as test_download_zip_single_job_success()
    participant P54 as test_healthz_endpoint_healthy()
    participant P55 as test_healthz_endpoint_unhealthy_redis()
    participant P56 as test_healthz_endpoint_unhealthy_database()
    participant P57 as test_page_image_non_existent_job_returns_404_or_410()
    participant P58 as test_page_image_zero_or_negative_page_returns_422_or_400()
    participant P59 as test_get_config_limits_endpoint()
    participant P60 as test_dynamic_limit_config_reload()
    participant P61 as test_download_expired_job_returns_410_gone()
    participant P62 as test_download_non_existent_job_returns_410_gone()
    participant P63 as test_preview_non_existent_job_returns_410_gone()
    participant P64 as test_preview_completed_job_returns_pages_data()
    participant P65 as test_convert_endpoint_triggers_background_ocr_worker()
    participant P66 as test_encrypted_pdf_rejected_without_password()
    participant P67 as test_encrypted_pdf_rejected_with_invalid_password()
    participant P68 as test_encrypted_pdf_accepted_with_correct_password()
    participant P69 as .__init__()
    participant P70 as test_get_config_endpoint()
    participant P71 as test_health_check()
    participant P72 as test_sse_endpoint_returns_event_stream_headers()
    participant P73 as test_sse_stream_emits_page_progress_and_completed_events()
    participant P74 as test_sse_stream_emits_failed_event()
    participant P75 as test_sse_endpoint_non_existent_job_returns_404()
    participant P76 as test_sse_endpoint_non_existent_job_returns_404()
    participant P77 as test_sse_endpoint_streams_redis_events()
    participant P78 as repair_pdf()
    participant P79 as _get_tessdata_dir()
    participant P80 as detect_page_orientation()
    participant P81 as parse_html_table_to_lines()
    participant P82 as test_ocr_worker_resilient_cpu_fallback_on_gpu_timeout_or_error()
    participant P83 as _publish_event()
    participant P84 as _store_job()
    participant P85 as test_process_ocr_job_success()
    participant P86 as test_ocr_worker_unrepairable_pdf_integration()
    participant P87 as test_process_ocr_job_image_file()
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
    P2->>+ P0: calls
    P0-->>- P2: return
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
    P1->>+ P11: calls
    P11-->>- P1: return
    P11->>+ P1: calls
    P1-->>- P11: return
    P11->>+ P3: calls
    P3-->>- P11: return
    P11->>+ P12: calls
    P12-->>- P11: return
    P11->>+ P13: calls
    P13-->>- P11: return
    P11->>+ P14: calls
    P14-->>- P11: return
    P11->>+ P4: calls
    P4-->>- P11: return
    P11->>+ P15: calls
    P15-->>- P11: return
    P11->>+ P16: calls
    P16-->>- P11: return
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
    P1->>+ P23: calls
    P23-->>- P1: return
    P1->>+ P12: calls
    P12-->>- P1: return
    P1->>+ P13: calls
    P13-->>- P1: return
    P1->>+ P14: calls
    P14-->>- P1: return
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
    P1->>+ P31: calls
    P31-->>- P1: return
    P1->>+ P32: calls
    P32-->>- P1: return
    P1->>+ P33: calls
    P33-->>- P1: return
    P1->>+ P34: calls
    P34-->>- P1: return
    P1->>+ P35: calls
    P35-->>- P1: return
    P1->>+ P36: calls
    P36-->>- P1: return
    P1->>+ P37: calls
    P37-->>- P1: return
    P1->>+ P38: calls
    P38-->>- P1: return
    P1->>+ P39: calls
    P39-->>- P1: return
    P1->>+ P5: calls
    P5-->>- P1: return
    P1->>+ P16: calls
    P16-->>- P1: return
    P1->>+ P40: calls
    P40-->>- P1: return
    P1->>+ P41: calls
    P41-->>- P1: return
    P1->>+ P42: calls
    P42-->>- P1: return
    P1->>+ P43: calls
    P43-->>- P1: return
    P1->>+ P44: calls
    P44-->>- P1: return
    P1->>+ P45: calls
    P45-->>- P1: return
    P1->>+ P46: calls
    P46-->>- P1: return
    P1->>+ P47: calls
    P47-->>- P1: return
    P1->>+ P48: calls
    P48-->>- P1: return
    P1->>+ P49: calls
    P49-->>- P1: return
    P1->>+ P50: calls
    P50-->>- P1: return
    P1->>+ P51: calls
    P51-->>- P1: return
    P1->>+ P52: calls
    P52-->>- P1: return
    P1->>+ P53: calls
    P53-->>- P1: return
    P1->>+ P54: calls
    P54-->>- P1: return
    P1->>+ P55: calls
    P55-->>- P1: return
    P1->>+ P56: calls
    P56-->>- P1: return
    P1->>+ P57: calls
    P57-->>- P1: return
    P1->>+ P58: calls
    P58-->>- P1: return
    P1->>+ P59: calls
    P59-->>- P1: return
    P1->>+ P60: calls
    P60-->>- P1: return
    P1->>+ P61: calls
    P61-->>- P1: return
    P1->>+ P62: calls
    P62-->>- P1: return
    P1->>+ P63: calls
    P63-->>- P1: return
    P1->>+ P64: calls
    P64-->>- P1: return
    P1->>+ P65: calls
    P65-->>- P1: return
    P1->>+ P66: calls
    P66-->>- P1: return
    P1->>+ P67: calls
    P67-->>- P1: return
    P1->>+ P68: calls
    P68-->>- P1: return
    P1->>+ P69: calls
    P69-->>- P1: return
    P1->>+ P70: calls
    P70-->>- P1: return
    P1->>+ P71: calls
    P71-->>- P1: return
    P1->>+ P72: calls
    P72-->>- P1: return
    P1->>+ P73: calls
    P73-->>- P1: return
    P1->>+ P74: calls
    P74-->>- P1: return
    P1->>+ P75: calls
    P75-->>- P1: return
    P1->>+ P76: calls
    P76-->>- P1: return
    P1->>+ P77: calls
    P77-->>- P1: return
    P0->>+ P2: calls
    P2-->>- P0: return
    P0->>+ P78: calls
    P78-->>- P0: return
    P0->>+ P28: calls
    P28-->>- P0: return
    P0->>+ P29: calls
    P29-->>- P0: return
    P0->>+ P79: calls
    P79-->>- P0: return
    P0->>+ P80: calls
    P80-->>- P0: return
    P0->>+ P81: calls
    P81-->>- P0: return
    P0->>+ P82: calls
    P82-->>- P0: return
    P0->>+ P39: calls
    P39-->>- P0: return
    P0->>+ P15: calls
    P15-->>- P0: return
    P0->>+ P40: calls
    P40-->>- P0: return
    P0->>+ P83: calls
    P83-->>- P0: return
    P0->>+ P84: calls
    P84-->>- P0: return
    P0->>+ P85: calls
    P85-->>- P0: return
    P0->>+ P86: calls
    P86-->>- P0: return
    P0->>+ P87: calls
    P87-->>- P0: return
```

## Connections by Relation

### calls
- [[.get()]] `INFERRED`
- [[compose_searchable_pdf()]] `INFERRED`
- [[repair_pdf()]] `INFERRED`
- [[test_ocr_worker_dispatches_to_baidu_gpu_service()]] `INFERRED`
- [[test_ocr_worker_corrupted_pdf_repair_integration()]] `INFERRED`
- [[_get_tessdata_dir()]] `EXTRACTED`
- [[detect_page_orientation()]] `EXTRACTED`
- [[parse_html_table_to_lines()]] `EXTRACTED`
- [[test_ocr_worker_resilient_cpu_fallback_on_gpu_timeout_or_error()]] `INFERRED`
- [[test_process_ocr_job_ephemeral_file_cleanup_on_exception()]] `INFERRED`
- [[test_ocr_worker_integrates_pdf_composer()]] `INFERRED`
- [[test_ocr_worker_decryption_process()]] `INFERRED`
- [[_publish_event()]] `EXTRACTED`
- [[_store_job()]] `EXTRACTED`
- [[test_process_ocr_job_success()]] `INFERRED`
- [[test_ocr_worker_unrepairable_pdf_integration()]] `INFERRED`
- [[test_process_ocr_job_image_file()]] `INFERRED`

### contains
- [[ocr_worker.py]] `EXTRACTED`

### rationale_for
- [[Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*