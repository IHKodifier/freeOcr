# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr  (2026-09-02)

## Corpus Check
- 90 files · ~138,520 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 633 nodes · 741 edges · 43 communities detected
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 58 edges (avg confidence: 0.77)
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
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 31 edges
2. `get_redis_client()` - 15 edges
3. `process_ocr_job()` - 14 edges
4. `package:flutter_test/flutter_test.dart` - 14 edges
5. `load_canonical_config()` - 9 edges
6. `../services/telemetry_service.dart` - 9 edges
7. `convert_document()` - 8 edges
8. `rewarded_ad_callback()` - 7 edges
9. `compose_searchable_pdf()` - 7 edges
10. `dart:async` - 7 edges

## Surprising Connections (you probably didn't know these)
- `load_canonical_config()` --calls--> `convert_document()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py
- `load_canonical_config()` --calls--> `rewarded_ad_callback()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py
- `load_canonical_config()` --calls--> `test_canonical_config_loader()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_config_and_quotas.py
- `healthz()` --calls--> `check_redis_connection()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `get_redis_client()` --calls--> `_publish_event()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\ocr_worker.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.04
Nodes (62): AdSenseBanner, AppFooter, build, _buildBentoCard, _buildCheckBullet, _buildCodeTeaserCard, _buildEarlyAccessCta, _buildHeroBadge (+54 more)

### Community 1 - "Community 1"

Cohesion: 0.04
Nodes (47): AppTheme, _buildTextTheme, codePreviewTextStyle, build, Container, ExpiredLinkView, _formatLocalExpirationTime, SizedBox (+39 more)

### Community 2 - "Community 2"

Cohesion: 0.04
Nodes (42): check_database_connection(), AlertDialog, build, _buildLeftScanPane, _buildRightTextPane, _buildSplitView, _buildStackedView, _buildTabOption (+34 more)

### Community 3 - "Community 3"

Cohesion: 0.07
Nodes (40): BaseModel, download_job_file(), get_job_preview(), Returns extracted text blocks and page layout metadata for an OCR job.     Retu, Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes, 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r, stream_job_events(), analyze_pdf_bytes() (+32 more)

### Community 4 - "Community 4"

Cohesion: 0.05
Nodes (38): dart:async, dart:convert, dart:js, dart:math, ApiService, BatchFileItem, formatBytes, Function (+30 more)

### Community 5 - "Community 5"

Cohesion: 0.08
Nodes (33): _get_tessdata_dir(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, _store_job(), Attempts automated repair on corrupted or damaged PDF file bytes.     1. Fixes, repair_pdf() (+25 more)

### Community 6 - "Community 6"

Cohesion: 0.06
Nodes (30): dart:ui, AppHeader, build, _buildThemeToggleButton, Container, IconButton, PopupMenuItem, Row (+22 more)

### Community 7 - "Community 7"

Cohesion: 0.06
Nodes (30): AdSenseBanner, AppFooter, build, _buildBreadcrumbs, _buildBulletPoint, _buildDiagramStep, _buildGitHubRepoTile, _buildH2 (+22 more)

### Community 8 - "Community 8"

Cohesion: 0.08
Nodes (19): BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings, Verify that monetization parameters are present in backend configuration., Verify that GET /api/v1/config endpoint returns monetization configuration. (+11 more)

### Community 9 - "Community 9"

Cohesion: 0.08
Nodes (23): AdSenseBanner, AppFooter, build, FreeOcrApp, HomePage, _HomePageState, initState, main (+15 more)

### Community 10 - "Community 10"

Cohesion: 0.1
Nodes (19): adsense_banner.dart, build, _buildBatchProgressUI, _buildSingleProgressUI, Column, Container, dispose, ExpiredLinkView (+11 more)

### Community 11 - "Community 11"

Cohesion: 0.11
Nodes (18): build, Container, dispose, DropTarget, Function, HeroDropzone, _HeroDropzoneState, Icon (+10 more)

### Community 12 - "Community 12"

Cohesion: 0.12
Nodes (15): AdSenseBanner, AdSenseBannerState, AnimatedBuilder, build, Center, didChangeAppLifecycleState, dispose, initState (+7 more)

### Community 13 - "Community 13"

Cohesion: 0.13
Nodes (14): ActionChip, AppFooter, build, _buildBrandColumn, _buildEngineChip, _buildEnginesColumn, _buildLegalColumn, _buildNavColumn (+6 more)

### Community 14 - "Community 14"

Cohesion: 0.17
Nodes (6): Validates email format using regex., Dispatches 24-hour expiring download links to the target email.     Uses Resend, send_download_links_email(), validate_email_address(), test_send_download_links_email_formatting(), test_validate_email_address_valid_and_invalid()

### Community 15 - "Community 15"

Cohesion: 0.28
Nodes (11): compose_searchable_pdf(), get_searchable_pdf(), Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b, Retrieves compiled searchable PDF bytes by token from ephemeral dev store., _create_sample_image_bytes(), _create_sample_pdf_bytes(), test_compose_searchable_pdf_from_image(), test_compose_searchable_pdf_from_pdf() (+3 more)

### Community 16 - "Community 16"

Cohesion: 0.18
Nodes (10): Verify that requesting an unsupported format returns HTTP 400 Bad Request., Verify that requesting a download for a non-existent/expired job returns HTTP 41, Verify downloading searchable PDF streams file bytes and immediately unlinks RAM, Verify downloading plain text streams compiled pages text., Verify downloading markdown format streams formatted markdown text with page hea, test_download_invalid_format_returns_400(), test_download_md_success(), test_download_non_existent_job_returns_410_gone() (+2 more)

### Community 17 - "Community 17"

Cohesion: 0.2
Nodes (6): dart:developer, dart:html, triggerDownload, openUrl, browserConsoleLog, browserConsoleLog

### Community 18 - "Community 18"

Cohesion: 0.22
Nodes (8): TelemetryService, trackDocumentUploaded, trackDownloadClicked, trackEmailSent, trackEvent, trackOcrCompleted, trackPageView, telemetry_helper_stub.dart

### Community 19 - "Community 19"
_Unable to determine domain due to missing code entities._
Cohesion: 0.25
Nodes (6): build, Card, _getStatusColor, _getStatusIcon, ProgressCard, SizedBox

### Community 20 - "Community 20"

Cohesion: 0.25
Nodes (6): Verify /healthz endpoint returns HTTP 200 when DB and Redis are connected., Verify /healthz endpoint returns HTTP 503 when Redis ping fails., Verify /healthz endpoint returns HTTP 503 when Database ping fails., test_healthz_endpoint_healthy(), test_healthz_endpoint_unhealthy_database(), test_healthz_endpoint_unhealthy_redis()

### Community 21 - "Community 21"
_Unable to determine domain due to missing code entities._
Cohesion: 0.43
Nodes (7): _create_encrypted_pdf_bytes(), _create_normal_pdf_bytes(), test_encrypted_pdf_accepted_with_correct_password(), test_encrypted_pdf_rejected_with_invalid_password(), test_encrypted_pdf_rejected_without_password(), test_non_encrypted_pdf_unaffected(), test_ocr_worker_decryption_process()

### Community 22 - "Community 22"

Cohesion: 0.29
Nodes (6): Verify storing job metadata includes created_at and expires_at timestamps., Verify that requesting a download for an expired job returns HTTP 410 Gone with, Verify that requesting a download for a non-existent or evicted job returns HTTP, test_download_expired_job_returns_410_gone(), test_download_non_existent_job_returns_410_gone(), test_job_metadata_timestamps()

### Community 23 - "Community 23"

Cohesion: 0.33
Nodes (0): 

### Community 24 - "Community 24"

Cohesion: 0.4
Nodes (4): Verify that requesting a preview for a non-existent/expired job returns HTTP 410, Verify that requesting a preview for a completed job returns extracted pages & l, test_preview_completed_job_returns_pages_data(), test_preview_non_existent_job_returns_410_gone()

### Community 25 - "Community 25"
_Unable to determine domain due to missing code entities._
Cohesion: 0.4
Nodes (0): 

### Community 26 - "Community 26"

Cohesion: 0.67
Nodes (3): main(), markdown_to_simple_html(), Converts basic markdown formatting into clean semantic HTML structure.

### Community 27 - "Community 27"
_Unable to determine domain due to missing code entities._
Cohesion: 0.5
Nodes (3): download_helper_stub.dart, DownloadHelper, triggerDownload

### Community 28 - "Community 28"

Cohesion: 0.5
Nodes (3): evaluate, LimitEvaluationResult, LimitEvaluator

### Community 29 - "Community 29"
_Unable to determine domain due to missing code entities._
Cohesion: 0.5
Nodes (3): openUrl, UrlHelper, url_helper_stub.dart

### Community 30 - "Community 30"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 31 - "Community 31"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (2): logToBrowserConsole, web_console_stub.dart

### Community 32 - "Community 32"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 33 - "Community 33"

Cohesion: 1.0
Nodes (1): triggerDownload

### Community 34 - "Community 34"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): openUrl

### Community 35 - "Community 35"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): triggerGamAdSlotRefresh

### Community 36 - "Community 36"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 37 - "Community 37"

Cohesion: 1.0
Nodes (0): 

### Community 38 - "Community 38"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 39 - "Community 39"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 40 - "Community 40"

Cohesion: 1.0
Nodes (1): Inspects PDF layout structure and returns complexity classification.

### Community 41 - "Community 41"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 42 - "Community 42"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **396 isolated node(s):** `Converts basic markdown formatting into clean semantic HTML structure.`, `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `Stores job payload in Redis, with fallback to in-memory store when Redis is unav` (+391 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 33`** (2 nodes): `download_helper_stub.dart`, `triggerDownload`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (2 nodes): `url_helper_stub.dart`, `openUrl`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (2 nodes): `gam_js_interop_stub.dart`, `triggerGamAdSlotRefresh`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (1 nodes): `gam_js_interop.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.