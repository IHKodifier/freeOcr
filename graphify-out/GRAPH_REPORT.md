# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr  (2026-09-10)

## Corpus Check
- 115 files · ~229,772 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 874 nodes · 1103 edges · 58 communities detected
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 153 edges (avg confidence: 0.77)
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
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 42 edges
2. `get_redis_client()` - 20 edges
3. `EphemeralRamStore` - 18 edges
4. `process_ocr_job()` - 17 edges
5. `package:flutter_test/flutter_test.dart` - 16 edges
6. `package:flutter/foundation.dart` - 12 edges
7. `compose_searchable_pdf()` - 11 edges
8. `../services/telemetry_service.dart` - 11 edges
9. `get_searchable_pdf()` - 10 edges
10. `dart:async` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Validates email, checks job completion, instantly purges original input file` --uses--> `LayoutAnalyzer`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\layout_analyzer.py
- `load_canonical_config()` --calls--> `test_canonical_config_loader()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_config_and_quotas.py
- `healthz()` --calls--> `check_redis_connection()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `Returns job status and progress for polling or verification.` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.03
Nodes (90): batch_download_zip(), download_job_file(), get_job_page_image(), get_job_preview(), get_job_status(), Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j, Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j, Returns job status and progress for polling or verification. (+82 more)

### Community 1 - "Community 1"

Cohesion: 0.02
Nodes (80): AppTheme, _buildTextTheme, codePreviewTextStyle, loadTheme, saveTheme, ThemeStorageHelper, loadTheme, saveTheme (+72 more)

### Community 2 - "Community 2"

Cohesion: 0.03
Nodes (86): AboutPage, _AboutPageState, AdSenseBanner, AppFooter, build, _buildCard, Container, initState (+78 more)

### Community 3 - "Community 3"

Cohesion: 0.03
Nodes (55): BaseSettings, Settings, check_database_connection(), AlertDialog, BackdropFilter, build, _buildDocumentPreviewPane, _buildMobileBody (+47 more)

### Community 4 - "Community 4"

Cohesion: 0.04
Nodes (44): adsense_banner.dart, build, Container, dispose, DropTarget, Function, HeroDropzone, _HeroDropzoneState (+36 more)

### Community 5 - "Community 5"

Cohesion: 0.06
Nodes (35): get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., analyze_pdf_bytes(), LayoutAnalyzer, Document Layout and Complexity Pre-Processing Analyzer.  Analyzes uploaded PDF, convert_document() (+27 more)

### Community 6 - "Community 6"

Cohesion: 0.06
Nodes (36): api_uploader_stub.dart, dart:async, dart:convert, dart:math, dart:typed_data, ApiService, BatchFileItem, formatBytes (+28 more)

### Community 7 - "Community 7"

Cohesion: 0.05
Nodes (36): AdSenseBanner, AppFooter, build, _buildHeadline, _buildPulseBadge, _buildSubtitle, ConstrainedBox, Container (+28 more)

### Community 8 - "Community 8"

Cohesion: 0.06
Nodes (33): dart:ui, trackGa4Event, trackGa4PageView, AppHeader, build, _buildThemeToggleButton, Container, IconButton (+25 more)

### Community 9 - "Community 9"

Cohesion: 0.09
Nodes (31): dict, _get_tessdata_dir(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, _store_job(), Verifies that GET /health returns ready status and identifies Baidu_Unlimited_OC (+23 more)

### Community 10 - "Community 10"

Cohesion: 0.06
Nodes (32): AdSenseBanner, AppFooter, build, _buildBreadcrumbs, _buildBulletPoint, _buildDiagramStep, _buildGitHubRepoTile, _buildH2 (+24 more)

### Community 11 - "Community 11"

Cohesion: 0.1
Nodes (22): Attempts automated repair on corrupted or damaged PDF file bytes.     1. Fixes, repair_pdf(), create_minimal_pdf_bytes(), create_reparable_corrupted_pdf_bytes(), ocr_worker process_ocr_job should attempt repair on corrupted PDF and complete O, Helper to generate minimal valid single-page PDF bytes., ocr_worker process_ocr_job should emit FAILED status on unrepairable PDF., Helper to generate a PDF stream with broken startxref offset. (+14 more)

### Community 12 - "Community 12"

Cohesion: 0.1
Nodes (15): BaseModel, ContactRequest, Submits a contact inquiry. Validates input and logs contact submission., submit_contact_form(), Validates email format using regex., Dispatches 24-hour expiring download links to the target email.     Uses Resend, send_download_links_email(), validate_email_address() (+7 more)

### Community 13 - "Community 13"

Cohesion: 0.09
Nodes (21): brand_icons.dart, ../constants/social_links.dart, AlertDialog, Icon, openSocialChannel, SizedBox, SocialLinks, ActionChip (+13 more)

### Community 14 - "Community 14"

Cohesion: 0.09
Nodes (15): dart:developer, dart:html, dart:js, _directAnchorDownload, triggerDownload, trackGa4Event, trackGa4PageView, loadTheme (+7 more)

### Community 15 - "Community 15"

Cohesion: 0.12
Nodes (16): build, _buildFaqItem, _buildFeatureTile, _buildSectionHeader, _buildStepCard, Center, Column, Container (+8 more)

### Community 16 - "Community 16"

Cohesion: 0.17
Nodes (15): get_baidu_ocr_engine(), health_check(), is_gpu_available(), ocr_complex_page(), parse_grounding_output(), Baidu Unlimited OCR GPU Microservice.  Standalone FastAPI microservice running B, Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR., Health check verifying microservice readiness, engine name, and GPU status. (+7 more)

### Community 17 - "Community 17"

Cohesion: 0.12
Nodes (15): AdSenseBanner, AdSenseBannerState, AnimatedBuilder, build, Center, didChangeAppLifecycleState, dispose, initState (+7 more)

### Community 18 - "Community 18"

Cohesion: 0.22
Nodes (8): TelemetryService, trackDocumentUploaded, trackDownloadClicked, trackEmailSent, trackEvent, trackOcrCompleted, trackPageView, telemetry_helper_stub.dart

### Community 19 - "Community 19"
_Unable to determine domain due to missing code entities._
Cohesion: 0.29
Nodes (6): Verify storing job metadata includes created_at and expires_at timestamps., Verify that requesting a download for an expired job returns HTTP 410 Gone with, Verify that requesting a download for a non-existent or evicted job returns HTTP, test_download_expired_job_returns_410_gone(), test_download_non_existent_job_returns_410_gone(), test_job_metadata_timestamps()

### Community 20 - "Community 20"

Cohesion: 0.29
Nodes (1): test_upload_oversized_file()

### Community 21 - "Community 21"
_Unable to determine domain due to missing code entities._
Cohesion: 0.4
Nodes (4): navigateToPath, openUrl, UrlHelper, url_helper_stub.dart

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
Cohesion: 0.5
Nodes (0): 

### Community 26 - "Community 26"

Cohesion: 0.67
Nodes (0): 

### Community 27 - "Community 27"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (2): navigateToPath, openUrl

### Community 28 - "Community 28"

Cohesion: 0.67
Nodes (2): configureAppUrlStrategy, package:flutter_web_plugins/url_strategy.dart

### Community 29 - "Community 29"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (2): logToBrowserConsole, web_console_stub.dart

### Community 30 - "Community 30"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 31 - "Community 31"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): triggerDownload

### Community 32 - "Community 32"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): configureAppUrlStrategy

### Community 33 - "Community 33"

Cohesion: 1.0
Nodes (1): triggerGamAdSlotRefresh

### Community 34 - "Community 34"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 35 - "Community 35"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

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
Nodes (1): Inspects PDF layout structure and returns complexity classification.

### Community 39 - "Community 39"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 40 - "Community 40"

Cohesion: 1.0
Nodes (0): 

### Community 41 - "Community 41"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 42 - "Community 42"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): Health check endpoint returning service health status and API version.

### Community 43 - "Community 43"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): Detailed healthz check endpoint for container orchestrators and monitoring tools

### Community 44 - "Community 44"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (1): Stores job payload in Redis, with fallback to in-memory store when Redis is unav

### Community 45 - "Community 45"

Cohesion: 1.0
Nodes (1): Retrieves job payload string from Redis, falling back to in-memory store.

### Community 46 - "Community 46"

Cohesion: 1.0
Nodes (1): Stores ad pass payload in Redis, with fallback to in-memory store when Redis is

### Community 47 - "Community 47"

Cohesion: 1.0
Nodes (1): Retrieves ad pass payload dict from Redis, falling back to in-memory store.

### Community 48 - "Community 48"

Cohesion: 1.0
Nodes (1): Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes

### Community 49 - "Community 49"

Cohesion: 1.0
Nodes (1): Returns extracted text blocks and page layout metadata for an OCR job.     Retu

### Community 50 - "Community 50"

Cohesion: 1.0
Nodes (1): 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r

### Community 51 - "Community 51"

Cohesion: 1.0
Nodes (1): Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR

### Community 52 - "Community 52"

Cohesion: 1.0
Nodes (1): Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S

### Community 53 - "Community 53"

Cohesion: 1.0
Nodes (1): Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b

### Community 54 - "Community 54"

Cohesion: 1.0
Nodes (1): Retrieves compiled searchable PDF bytes by token from ephemeral dev store.

### Community 55 - "Community 55"

Cohesion: 1.0
Nodes (1): Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes

### Community 56 - "Community 56"

Cohesion: 1.0
Nodes (1): Returns extracted text blocks and page layout metadata for an OCR job.     Retu

### Community 57 - "Community 57"

Cohesion: 1.0
Nodes (1): 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r

## Knowledge Gaps
- **551 isolated node(s):** `Converts basic markdown formatting into clean semantic HTML structure.`, `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH` (+546 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 30`** (2 nodes): `generate_test_pdf.py`, `generate_pdf()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (2 nodes): `download_helper_stub.dart`, `triggerDownload`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (2 nodes): `url_strategy_stub.dart`, `configureAppUrlStrategy`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (2 nodes): `gam_js_interop_stub.dart`, `triggerGamAdSlotRefresh`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (1 nodes): `url_strategy_helper.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (1 nodes): `gam_js_interop.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (1 nodes): `Health check endpoint returning service health status and API version.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (1 nodes): `Detailed healthz check endpoint for container orchestrators and monitoring tools`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 44`** (1 nodes): `Stores job payload in Redis, with fallback to in-memory store when Redis is unav`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 45`** (1 nodes): `Retrieves job payload string from Redis, falling back to in-memory store.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 46`** (1 nodes): `Stores ad pass payload in Redis, with fallback to in-memory store when Redis is`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 47`** (1 nodes): `Retrieves ad pass payload dict from Redis, falling back to in-memory store.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 48`** (1 nodes): `Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 49`** (1 nodes): `Returns extracted text blocks and page layout metadata for an OCR job.     Retu`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 50`** (1 nodes): `1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 51`** (1 nodes): `Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 52`** (1 nodes): `Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 53`** (1 nodes): `Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 54`** (1 nodes): `Retrieves compiled searchable PDF bytes by token from ephemeral dev store.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 55`** (1 nodes): `Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 56`** (1 nodes): `Returns extracted text blocks and page layout metadata for an OCR job.     Retu`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 57`** (1 nodes): `1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.