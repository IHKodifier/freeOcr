# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr  (2026-08-29)

## Corpus Check
- 68 files · ~58,947 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 450 nodes · 527 edges · 35 communities detected
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 58 edges (avg confidence: 0.77)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 19 edges
2. `get_redis_client()` - 15 edges
3. `process_ocr_job()` - 14 edges
4. `load_canonical_config()` - 9 edges
5. `package:flutter_test/flutter_test.dart` - 9 edges
6. `convert_document()` - 8 edges
7. `rewarded_ad_callback()` - 7 edges
8. `compose_searchable_pdf()` - 7 edges
9. `LayoutAnalyzer` - 6 edges
10. `repair_pdf()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `test_adsense_config_interval_loaded()` --calls--> `load_canonical_config()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_adsense_config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py
- `test_canonical_config_loader()` --calls--> `load_canonical_config()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_config_and_quotas.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py
- `test_limit_config_values()` --calls--> `load_canonical_config()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_limit_evaluator.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py
- `healthz()` --calls--> `check_database_connection()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\database.py
- `stream_job_events()` --calls--> `get_redis_client()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.06
Nodes (40): BaseModel, BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings, LayoutAnalyzer (+32 more)

### Community 1 - "Community 1"

Cohesion: 0.05
Nodes (39): AppTheme, _buildTextTheme, codePreviewTextStyle, build, Container, ExpiredLinkView, _formatLocalExpirationTime, SizedBox (+31 more)

### Community 2 - "Community 2"

Cohesion: 0.06
Nodes (35): adsense_banner.dart, dart:async, dart:convert, dart:math, ApiService, BatchFileItem, formatBytes, Function (+27 more)

### Community 3 - "Community 3"

Cohesion: 0.08
Nodes (33): _get_tessdata_dir(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, _store_job(), Attempts automated repair on corrupted or damaged PDF file bytes.     1. Fixes, repair_pdf() (+25 more)

### Community 4 - "Community 4"

Cohesion: 0.06
Nodes (33): AlertDialog, build, _buildLeftScanPane, _buildRightTextPane, _buildSplitView, _buildStackedView, _buildTabOption, _buildTopHeader (+25 more)

### Community 5 - "Community 5"

Cohesion: 0.07
Nodes (30): AdSenseBanner, build, FreeOcrApp, HomePage, _HomePageState, initState, main, MaterialApp (+22 more)

### Community 6 - "Community 6"

Cohesion: 0.08
Nodes (21): dart:developer, dart:html, triggerDownload, browserConsoleLog, browserConsoleLog, AdSenseBanner, AdSenseBannerState, AnimatedBuilder (+13 more)

### Community 7 - "Community 7"

Cohesion: 0.15
Nodes (17): download_job_file(), get_job_preview(), Returns extracted text blocks and page layout metadata for an OCR job.     Retu, Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes, 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r, stream_job_events(), compose_searchable_pdf(), get_searchable_pdf() (+9 more)

### Community 8 - "Community 8"

Cohesion: 0.11
Nodes (18): build, _buildBatchProgressUI, _buildSingleProgressUI, Column, Container, dispose, ExpiredLinkView, initState (+10 more)

### Community 9 - "Community 9"

Cohesion: 0.11
Nodes (18): dart:ui, build, _buildSuccessDetailRow, CircularProgressIndicator, ClipRRect, Color, _confirmEarlyCancel, Dialog (+10 more)

### Community 10 - "Community 10"

Cohesion: 0.17
Nodes (6): Validates email format using regex., Dispatches 24-hour expiring download links to the target email.     Uses Resend, send_download_links_email(), validate_email_address(), test_send_download_links_email_formatting(), test_validate_email_address_valid_and_invalid()

### Community 11 - "Community 11"

Cohesion: 0.18
Nodes (10): Verify that requesting an unsupported format returns HTTP 400 Bad Request., Verify that requesting a download for a non-existent/expired job returns HTTP 41, Verify downloading searchable PDF streams file bytes and immediately unlinks RAM, Verify downloading plain text streams compiled pages text., Verify downloading markdown format streams formatted markdown text with page hea, test_download_invalid_format_returns_400(), test_download_md_success(), test_download_non_existent_job_returns_410_gone() (+2 more)

### Community 12 - "Community 12"

Cohesion: 0.25
Nodes (6): Verify /healthz endpoint returns HTTP 200 when DB and Redis are connected., Verify /healthz endpoint returns HTTP 503 when Redis ping fails., Verify /healthz endpoint returns HTTP 503 when Database ping fails., test_healthz_endpoint_healthy(), test_healthz_endpoint_unhealthy_database(), test_healthz_endpoint_unhealthy_redis()

### Community 13 - "Community 13"

Cohesion: 0.43
Nodes (7): _create_encrypted_pdf_bytes(), _create_normal_pdf_bytes(), test_encrypted_pdf_accepted_with_correct_password(), test_encrypted_pdf_rejected_with_invalid_password(), test_encrypted_pdf_rejected_without_password(), test_non_encrypted_pdf_unaffected(), test_ocr_worker_decryption_process()

### Community 14 - "Community 14"

Cohesion: 0.33
Nodes (5): check_database_connection(), Verify that database connection check returns True for SQLite dev.db., Verify metadata create_all executes cleanly on SQLite engine., test_database_connection(), test_database_metadata_create_all()

### Community 15 - "Community 15"

Cohesion: 0.29
Nodes (6): Verify that monetization parameters are present in backend configuration., Verify that GET /api/v1/config endpoint returns monetization configuration., Verify that modifying monetization parameters in config file is reflected dynami, test_adsense_config_api_endpoint(), test_adsense_config_interval_loaded(), test_dynamic_config_file_reload()

### Community 16 - "Community 16"

Cohesion: 0.43
Nodes (5): analyze_pdf_bytes(), Document Layout and Complexity Pre-Processing Analyzer.  Analyzes uploaded PDF, create_sample_pdf(), test_complex_layout_math_formula(), test_simple_layout_classification()

### Community 17 - "Community 17"

Cohesion: 0.29
Nodes (6): Verify that canonical limits config contains base_max_file_mb, boost_per_ad_mb,, Verify GET /api/v1/config returns canonical limit configuration., Verify that modifying limits in configuration file updates runtime config dynami, test_dynamic_limit_config_reload(), test_get_config_limits_endpoint(), test_limit_config_values()

### Community 18 - "Community 18"

Cohesion: 0.29
Nodes (6): Verify storing job metadata includes created_at and expires_at timestamps., Verify that requesting a download for an expired job returns HTTP 410 Gone with, Verify that requesting a download for a non-existent or evicted job returns HTTP, test_download_expired_job_returns_410_gone(), test_download_non_existent_job_returns_410_gone(), test_job_metadata_timestamps()

### Community 19 - "Community 19"
_Unable to determine domain due to missing code entities._
Cohesion: 0.33
Nodes (0): 

### Community 20 - "Community 20"

Cohesion: 0.4
Nodes (4): Verify that requesting a preview for a non-existent/expired job returns HTTP 410, Verify that requesting a preview for a completed job returns extracted pages & l, test_preview_completed_job_returns_pages_data(), test_preview_non_existent_job_returns_410_gone()

### Community 21 - "Community 21"
_Unable to determine domain due to missing code entities._
Cohesion: 0.4
Nodes (0): 

### Community 22 - "Community 22"

Cohesion: 0.67
Nodes (3): main(), markdown_to_simple_html(), Converts basic markdown formatting into clean semantic HTML structure.

### Community 23 - "Community 23"

Cohesion: 0.5
Nodes (3): download_helper_stub.dart, DownloadHelper, triggerDownload

### Community 24 - "Community 24"

Cohesion: 0.5
Nodes (3): evaluate, LimitEvaluationResult, LimitEvaluator

### Community 25 - "Community 25"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 26 - "Community 26"

Cohesion: 0.67
Nodes (2): logToBrowserConsole, web_console_stub.dart

### Community 27 - "Community 27"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 28 - "Community 28"

Cohesion: 1.0
Nodes (1): triggerDownload

### Community 29 - "Community 29"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 30 - "Community 30"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 31 - "Community 31"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 32 - "Community 32"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 33 - "Community 33"

Cohesion: 1.0
Nodes (1): Inspects PDF layout structure and returns complexity classification.

### Community 34 - "Community 34"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **243 isolated node(s):** `Converts basic markdown formatting into clean semantic HTML structure.`, `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `Stores job payload in Redis, with fallback to in-memory store when Redis is unav` (+238 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 28`** (2 nodes): `download_helper_stub.dart`, `triggerDownload`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.