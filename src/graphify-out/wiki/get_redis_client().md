# get_redis_client()

> God node · 24 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L108)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as get_redis_client()
    participant P1 as get_job_metadata()
    participant P2 as .get()
    participant P3 as process_ocr_job()
    participant P4 as compose_searchable_pdf()
    participant P5 as get_searchable_pdf()
    participant P6 as email_download_links()
    participant P7 as convert_document()
    participant P8 as redact_pdf()
    participant P9 as rewarded_ad_callback()
    participant P10 as send_download_links_email()
    participant P11 as analyze_pdf_bytes()
    participant P12 as test_store_and_get_pdf_bytes_24h_ttl()
    participant P13 as store_job_metadata()
    participant P14 as persist_pdf_to_redis()
    participant P15 as get_pdf_bytes()
    participant P16 as get_ad_pass_metadata()
    participant P17 as get_job_page_image()
    participant P18 as batch_download_zip()
    participant P19 as submit_contact_form()
    participant P20 as stream_job_events()
    participant P21 as get_job_preview()
    participant P22 as download_file()
    participant P23 as _get_session_keys()
    participant P24 as get_baidu_ocr_engine()
    participant P25 as parse_grounding_output()
    participant P26 as purge_ephemeral_ram_disk()
    participant P27 as test_ocr_worker_dispatches_to_baidu_gpu_service()
    participant P28 as test_get_searchable_pdf_from_redis_when_local_cache_misses()
    participant P29 as test_ocr_worker_corrupted_pdf_repair_integration()
    participant P30 as test_sign_endpoint_success()
    participant P31 as get_job_status()
    participant P32 as _get_normalized_client_ip()
    participant P33 as get_max_file_bytes()
    participant P34 as get_max_file_bytes()
    participant P35 as get_max_file_bytes()
    participant P36 as get_max_file_bytes()
    participant P37 as get_max_file_bytes()
    participant P38 as get_max_file_bytes()
    participant P39 as get_max_file_bytes()
    participant P40 as get_max_file_bytes()
    participant P41 as get_max_file_bytes()
    participant P42 as get_max_file_bytes()
    participant P43 as send_contact_inquiry_email()
    participant P44 as test_download_all_formats_from_redis_on_cold_boot()
    participant P45 as test_page_image_valid_completed_job_returns_png()
    participant P46 as test_page_image_out_of_range_page_returns_404()
    participant P47 as test_process_ocr_job_ephemeral_file_cleanup_on_exception()
    participant P48 as test_ephemeral_file_cleanup_pdf_composer()
    participant P49 as test_ocr_worker_decryption_process()
    participant P50 as test_upstash_redis_tls_client_initialization()
    participant P51 as test_crop_endpoint_success()
    participant P52 as test_delete_pages_rejects_100_percent_deletion_with_400()
    participant P53 as test_delete_pages_endpoint_removes_pages_and_streams_pdf()
    participant P54 as test_delete_pages_endpoint_out_of_bounds_returns_422()
    participant P55 as test_extract_invalid_pages_returns_422()
    participant P56 as test_extract_endpoint_merged_produces_pdf()
    participant P57 as test_extract_endpoint_separate_produces_zip()
    participant P58 as test_extract_no_pages_returns_400()
    participant P59 as test_merge_two_valid_pdfs_combines_pages_correctly()
    participant P60 as test_number_pages_endpoint_success()
    participant P61 as test_number_pages_endpoint_invalid_position()
    participant P62 as test_redact_endpoint_success()
    participant P63 as test_rotate_endpoint_single_page_90_degrees()
    participant P64 as test_rotate_endpoint_invalid_angle_returns_422()
    participant P65 as test_rotate_endpoint_out_of_bounds_page_returns_422()
    participant P66 as test_split_single_range_returns_pdf()
    participant P67 as test_split_multi_range_returns_zip_with_expected_files()
    participant P68 as test_watermark_endpoint_text_success()
    participant P69 as verify_internal_secret()
    participant P70 as test_adsense_config_api_endpoint()
    participant P71 as test_dynamic_config_file_reload()
    participant P72 as test_baidu_gpu_service_health()
    participant P73 as test_firebase_hosting_rewrites_config()
    participant P74 as test_health_probe_live_endpoint()
    participant P75 as test_cors_headers_match_freepdftoolz_domain()
    participant P76 as test_download_invalid_format_returns_400()
    participant P77 as test_download_non_existent_job_returns_410_gone()
    participant P78 as test_download_pdf_success_and_purges_ram_disk()
    participant P79 as test_download_txt_success()
    participant P80 as test_download_md_success()
    participant P81 as test_batch_download_zip_success()
    participant P82 as test_batch_download_zip_invalid_format()
    participant P83 as test_download_zip_single_job_success()
    participant P84 as test_download_expired_job_redirects_for_html_browser()
    participant P85 as test_healthz_endpoint_healthy()
    participant P86 as test_healthz_endpoint_unhealthy_redis()
    participant P87 as test_healthz_endpoint_unhealthy_database()
    participant P88 as test_page_image_non_existent_job_returns_404_or_410()
    participant P89 as test_page_image_zero_or_negative_page_returns_422_or_400()
    participant P90 as test_get_config_limits_endpoint()
    participant P91 as test_dynamic_limit_config_reload()
    participant P92 as test_download_expired_job_returns_410_gone()
    participant P93 as test_download_non_existent_job_returns_410_gone()
    participant P94 as test_preview_non_existent_job_returns_410_gone()
    participant P95 as test_preview_completed_job_returns_pages_data()
    participant P96 as test_convert_endpoint_triggers_background_ocr_worker()
    participant P97 as test_encrypted_pdf_rejected_without_password()
    participant P98 as test_encrypted_pdf_rejected_with_invalid_password()
    participant P99 as test_encrypted_pdf_accepted_with_correct_password()
    participant P100 as test_delete_pages_endpoint_rejects_non_pdf()
    participant P101 as test_extract_non_pdf_returns_400()
    participant P102 as test_get_tools_catalog()
    participant P103 as test_get_tool_categories()
    participant P104 as test_get_single_tool_detail()
    participant P105 as test_get_nonexistent_tool_returns_404()
    participant P106 as test_number_pages_endpoint_invalid_file_type()
    participant P107 as test_rotate_endpoint_rejects_non_pdf()
    participant P108 as .__init__()
    participant P109 as test_get_config_endpoint()
    participant P110 as test_health_check()
    participant P111 as test_sse_endpoint_returns_event_stream_headers()
    participant P112 as test_sse_stream_emits_page_progress_and_completed_events()
    participant P113 as test_sse_stream_emits_failed_event()
    participant P114 as test_sse_endpoint_non_existent_job_returns_404()
    participant P115 as test_sse_endpoint_non_existent_job_returns_404()
    participant P116 as test_sse_endpoint_streams_redis_events()
    participant P117 as test_job_metadata_offline_fallback_to_local_store()
    participant P118 as test_store_and_get_job_metadata_cold_boot_repopulation()
    participant P119 as check_redis_connection()
    participant P120 as store_pdf_bytes()
    participant P121 as store_ad_pass_metadata()
    participant P122 as _publish_event()
    participant P123 as _store_job()
    participant P124 as test_redis_client_configuration()
    P0->>+ P1: calls
    P1-->>- P0: return
    P1->>+ P2: calls
    P2-->>- P1: return
    P2->>+ P3: calls
    P3-->>- P2: return
    P2->>+ P1: calls
    P1-->>- P2: return
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
    P2->>+ P25: calls
    P25-->>- P2: return
    P2->>+ P26: calls
    P26-->>- P2: return
    P2->>+ P27: calls
    P27-->>- P2: return
    P2->>+ P28: calls
    P28-->>- P2: return
    P2->>+ P29: calls
    P29-->>- P2: return
    P2->>+ P30: calls
    P30-->>- P2: return
    P2->>+ P31: calls
    P31-->>- P2: return
    P2->>+ P32: calls
    P32-->>- P2: return
    P2->>+ P33: calls
    P33-->>- P2: return
    P2->>+ P34: calls
    P34-->>- P2: return
    P2->>+ P35: calls
    P35-->>- P2: return
    P2->>+ P36: calls
    P36-->>- P2: return
    P2->>+ P37: calls
    P37-->>- P2: return
    P2->>+ P38: calls
    P38-->>- P2: return
    P2->>+ P39: calls
    P39-->>- P2: return
    P2->>+ P40: calls
    P40-->>- P2: return
    P2->>+ P41: calls
    P41-->>- P2: return
    P2->>+ P42: calls
    P42-->>- P2: return
    P2->>+ P43: calls
    P43-->>- P2: return
    P2->>+ P44: calls
    P44-->>- P2: return
    P2->>+ P45: calls
    P45-->>- P2: return
    P2->>+ P46: calls
    P46-->>- P2: return
    P2->>+ P47: calls
    P47-->>- P2: return
    P2->>+ P48: calls
    P48-->>- P2: return
    P2->>+ P49: calls
    P49-->>- P2: return
    P2->>+ P50: calls
    P50-->>- P2: return
    P2->>+ P51: calls
    P51-->>- P2: return
    P2->>+ P52: calls
    P52-->>- P2: return
    P2->>+ P53: calls
    P53-->>- P2: return
    P2->>+ P54: calls
    P54-->>- P2: return
    P2->>+ P55: calls
    P55-->>- P2: return
    P2->>+ P56: calls
    P56-->>- P2: return
    P2->>+ P57: calls
    P57-->>- P2: return
    P2->>+ P58: calls
    P58-->>- P2: return
    P2->>+ P59: calls
    P59-->>- P2: return
    P2->>+ P60: calls
    P60-->>- P2: return
    P2->>+ P61: calls
    P61-->>- P2: return
    P2->>+ P62: calls
    P62-->>- P2: return
    P2->>+ P63: calls
    P63-->>- P2: return
    P2->>+ P64: calls
    P64-->>- P2: return
    P2->>+ P65: calls
    P65-->>- P2: return
    P2->>+ P66: calls
    P66-->>- P2: return
    P2->>+ P67: calls
    P67-->>- P2: return
    P2->>+ P68: calls
    P68-->>- P2: return
    P2->>+ P69: calls
    P69-->>- P2: return
    P2->>+ P70: calls
    P70-->>- P2: return
    P2->>+ P71: calls
    P71-->>- P2: return
    P2->>+ P72: calls
    P72-->>- P2: return
    P2->>+ P73: calls
    P73-->>- P2: return
    P2->>+ P74: calls
    P74-->>- P2: return
    P2->>+ P75: calls
    P75-->>- P2: return
    P2->>+ P76: calls
    P76-->>- P2: return
    P2->>+ P77: calls
    P77-->>- P2: return
    P2->>+ P78: calls
    P78-->>- P2: return
    P2->>+ P79: calls
    P79-->>- P2: return
    P2->>+ P80: calls
    P80-->>- P2: return
    P2->>+ P81: calls
    P81-->>- P2: return
    P2->>+ P82: calls
    P82-->>- P2: return
    P2->>+ P83: calls
    P83-->>- P2: return
    P2->>+ P84: calls
    P84-->>- P2: return
    P2->>+ P85: calls
    P85-->>- P2: return
    P2->>+ P86: calls
    P86-->>- P2: return
    P2->>+ P87: calls
    P87-->>- P2: return
    P2->>+ P88: calls
    P88-->>- P2: return
    P2->>+ P89: calls
    P89-->>- P2: return
    P2->>+ P90: calls
    P90-->>- P2: return
    P2->>+ P91: calls
    P91-->>- P2: return
    P2->>+ P92: calls
    P92-->>- P2: return
    P2->>+ P93: calls
    P93-->>- P2: return
    P2->>+ P94: calls
    P94-->>- P2: return
    P2->>+ P95: calls
    P95-->>- P2: return
    P2->>+ P96: calls
    P96-->>- P2: return
    P2->>+ P97: calls
    P97-->>- P2: return
    P2->>+ P98: calls
    P98-->>- P2: return
    P2->>+ P99: calls
    P99-->>- P2: return
    P2->>+ P100: calls
    P100-->>- P2: return
    P2->>+ P101: calls
    P101-->>- P2: return
    P2->>+ P102: calls
    P102-->>- P2: return
    P2->>+ P103: calls
    P103-->>- P2: return
    P2->>+ P104: calls
    P104-->>- P2: return
    P2->>+ P105: calls
    P105-->>- P2: return
    P2->>+ P106: calls
    P106-->>- P2: return
    P2->>+ P107: calls
    P107-->>- P2: return
    P2->>+ P108: calls
    P108-->>- P2: return
    P2->>+ P109: calls
    P109-->>- P2: return
    P2->>+ P110: calls
    P110-->>- P2: return
    P2->>+ P111: calls
    P111-->>- P2: return
    P2->>+ P112: calls
    P112-->>- P2: return
    P2->>+ P113: calls
    P113-->>- P2: return
    P2->>+ P114: calls
    P114-->>- P2: return
    P2->>+ P115: calls
    P115-->>- P2: return
    P2->>+ P116: calls
    P116-->>- P2: return
    P1->>+ P0: calls
    P0-->>- P1: return
    P1->>+ P6: calls
    P6-->>- P1: return
    P1->>+ P17: calls
    P17-->>- P1: return
    P1->>+ P18: calls
    P18-->>- P1: return
    P1->>+ P31: calls
    P31-->>- P1: return
    P1->>+ P20: calls
    P20-->>- P1: return
    P1->>+ P21: calls
    P21-->>- P1: return
    P1->>+ P22: calls
    P22-->>- P1: return
    P1->>+ P117: calls
    P117-->>- P1: return
    P1->>+ P118: calls
    P118-->>- P1: return
    P0->>+ P4: calls
    P4-->>- P0: return
    P0->>+ P5: calls
    P5-->>- P0: return
    P0->>+ P7: calls
    P7-->>- P0: return
    P0->>+ P6: calls
    P6-->>- P0: return
    P0->>+ P9: calls
    P9-->>- P0: return
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
    P0->>+ P119: calls
    P119-->>- P0: return
    P0->>+ P120: calls
    P120-->>- P0: return
    P0->>+ P20: calls
    P20-->>- P0: return
    P0->>+ P31: calls
    P31-->>- P0: return
    P0->>+ P21: calls
    P21-->>- P0: return
    P0->>+ P121: calls
    P121-->>- P0: return
    P0->>+ P50: calls
    P50-->>- P0: return
    P0->>+ P122: calls
    P122-->>- P0: return
    P0->>+ P123: calls
    P123-->>- P0: return
    P0->>+ P124: calls
    P124-->>- P0: return
```

## Connections by Relation

### calls
- [[get_job_metadata()]] `EXTRACTED`
- [[compose_searchable_pdf()]] `INFERRED`
- [[get_searchable_pdf()]] `INFERRED`
- [[convert_document()]] `INFERRED`
- [[email_download_links()]] `INFERRED`
- [[rewarded_ad_callback()]] `INFERRED`
- [[store_job_metadata()]] `EXTRACTED`
- [[persist_pdf_to_redis()]] `EXTRACTED`
- [[get_pdf_bytes()]] `EXTRACTED`
- [[get_ad_pass_metadata()]] `EXTRACTED`
- [[get_job_page_image()]] `INFERRED`
- [[batch_download_zip()]] `INFERRED`
- [[check_redis_connection()]] `EXTRACTED`
- [[store_pdf_bytes()]] `EXTRACTED`
- [[stream_job_events()]] `INFERRED`
- [[get_job_status()]] `INFERRED`
- [[get_job_preview()]] `INFERRED`
- [[store_ad_pass_metadata()]] `EXTRACTED`
- [[test_upstash_redis_tls_client_initialization()]] `INFERRED`
- [[_publish_event()]] `INFERRED`

### contains
- [[redis_client.py]] `EXTRACTED`

### rationale_for
- [[Initializes and returns a Redis client.     Supports both local development Red]] `EXTRACTED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*