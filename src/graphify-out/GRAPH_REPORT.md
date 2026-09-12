# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src  (2026-09-12)

## Corpus Check
- 110 files · ~228,732 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 870 nodes · 1122 edges · 45 communities detected
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 162 edges (avg confidence: 0.77)
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

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 42 edges
2. `get_redis_client()` - 20 edges
3. `EphemeralRamStore` - 19 edges
4. `process_ocr_job()` - 19 edges
5. `package:flutter_test/flutter_test.dart` - 16 edges
6. `compose_searchable_pdf()` - 12 edges
7. `package:flutter/foundation.dart` - 12 edges
8. `../services/telemetry_service.dart` - 11 edges
9. `get_searchable_pdf()` - 10 edges
10. `dart:async` - 10 edges

## Surprising Connections (you probably didn't know these)
- `load_canonical_config()` --calls--> `test_adsense_config_interval_loaded()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_adsense_config.py
- `load_canonical_config()` --calls--> `test_canonical_config_loader()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_config_and_quotas.py
- `load_canonical_config()` --calls--> `test_limit_config_values()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_limit_evaluator.py
- `check_database_connection()` --calls--> `healthz()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\database.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py
- `EphemeralRamStore` --uses--> `Returns job status and progress for polling or verification.`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.03
Nodes (86): AboutPage, _AboutPageState, AdSenseBanner, AppFooter, build, _buildCard, Container, initState (+78 more)

### Community 1 - "Community 1"

Cohesion: 0.03
Nodes (69): AppTheme, _buildTextTheme, codePreviewTextStyle, loadTheme, saveTheme, ThemeStorageHelper, loadTheme, saveTheme (+61 more)

### Community 2 - "Community 2"

Cohesion: 0.04
Nodes (69): Verify that monetization parameters are present in backend configuration., Verify that GET /api/v1/config endpoint returns monetization configuration., Verify that modifying monetization parameters in config file is reflected dynami, test_adsense_config_api_endpoint(), test_adsense_config_interval_loaded(), test_dynamic_config_file_reload(), Verify downloading batch zip produces a valid ZIP file containing all completed, Verify that requesting an unsupported format returns HTTP 400 Bad Request. (+61 more)

### Community 3 - "Community 3"

Cohesion: 0.05
Nodes (52): batch_download_zip(), download_job_file(), get_job_page_image(), get_job_preview(), get_job_status(), Returns extracted text blocks and page layout metadata for an OCR job.     Retu, Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j, Returns job status and progress for polling or verification. (+44 more)

### Community 4 - "Community 4"

Cohesion: 0.04
Nodes (49): dart:ui, trackGa4Event, trackGa4PageView, AppHeader, build, _buildThemeToggleButton, Container, IconButton (+41 more)

### Community 5 - "Community 5"

Cohesion: 0.04
Nodes (49): check_database_connection(), AlertDialog, BackdropFilter, build, _buildDocumentPreviewPane, _buildMobileBody, _buildMobileHeader, _buildRightTextPane (+41 more)

### Community 6 - "Community 6"

Cohesion: 0.04
Nodes (46): adsense_banner.dart, build, Container, dispose, Function, HeroDropzone, _HeroDropzoneState, Icon (+38 more)

### Community 7 - "Community 7"

Cohesion: 0.05
Nodes (35): api_uploader_stub.dart, dart:async, dart:convert, dart:developer, dart:html, dart:js, dart:math, dart:typed_data (+27 more)

### Community 8 - "Community 8"

Cohesion: 0.07
Nodes (39): detect_page_orientation(), _get_tessdata_dir(), parse_html_table_to_lines(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, Quickly checks whether the page has rotated text (90, 180, 270 deg)     using d (+31 more)

### Community 9 - "Community 9"

Cohesion: 0.05
Nodes (37): AdSenseBanner, AppFooter, build, _buildHeadline, _buildPulseBadge, _buildSubtitle, ConstrainedBox, Container (+29 more)

### Community 10 - "Community 10"

Cohesion: 0.08
Nodes (27): BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings, analyze_pdf_bytes(), LayoutAnalyzer (+19 more)

### Community 11 - "Community 11"

Cohesion: 0.06
Nodes (32): AdSenseBanner, AppFooter, build, _buildBreadcrumbs, _buildBulletPoint, _buildDiagramStep, _buildGitHubRepoTile, _buildH2 (+24 more)

### Community 12 - "Community 12"

Cohesion: 0.09
Nodes (28): get_baidu_ocr_engine(), health_check(), is_gpu_available(), ocr_complex_page(), parse_grounding_output(), Baidu Unlimited OCR GPU Microservice.  Standalone FastAPI microservice running B, Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR., Health check verifying microservice readiness, engine name, and GPU status. (+20 more)

### Community 13 - "Community 13"

Cohesion: 0.1
Nodes (15): BaseModel, ContactRequest, Submits a contact inquiry. Validates input and logs contact submission., submit_contact_form(), Validates email format using regex., Dispatches a website contact inquiry to the support inbox (support@freeocr.me)., Dispatches 24-hour expiring download links to the target email.     Uses Resend, send_contact_inquiry_email() (+7 more)

### Community 14 - "Community 14"

Cohesion: 0.09
Nodes (21): brand_icons.dart, ../constants/social_links.dart, AlertDialog, Icon, openSocialChannel, SizedBox, SocialLinks, ActionChip (+13 more)

### Community 15 - "Community 15"

Cohesion: 0.12
Nodes (16): build, _buildFaqItem, _buildFeatureTile, _buildSectionHeader, _buildStepCard, Center, Column, Container (+8 more)

### Community 16 - "Community 16"

Cohesion: 0.12
Nodes (15): AdSenseBanner, AdSenseBannerState, AnimatedBuilder, build, Center, didChangeAppLifecycleState, dispose, initState (+7 more)

### Community 17 - "Community 17"

Cohesion: 0.22
Nodes (8): TelemetryService, trackDocumentUploaded, trackDownloadClicked, trackEmailSent, trackEvent, trackOcrCompleted, trackPageView, telemetry_helper_stub.dart

### Community 18 - "Community 18"

Cohesion: 0.29
Nodes (6): BrandIcon, _BrandIconPainter, build, paint, shouldRepaint, SizedBox

### Community 19 - "Community 19"

Cohesion: 0.29
Nodes (1): test_upload_oversized_file()

### Community 20 - "Community 20"

Cohesion: 0.33
Nodes (5): build, Container, ExpiredLinkView, _formatLocalExpirationTime, SizedBox

### Community 21 - "Community 21"

Cohesion: 0.4
Nodes (4): navigateToPath, openUrl, UrlHelper, url_helper_stub.dart

### Community 22 - "Community 22"

Cohesion: 0.5
Nodes (3): download_helper_stub.dart, DownloadHelper, triggerDownload

### Community 23 - "Community 23"

Cohesion: 0.5
Nodes (3): evaluate, LimitEvaluationResult, LimitEvaluator

### Community 24 - "Community 24"
_Unable to determine domain due to missing code entities._
Cohesion: 0.5
Nodes (0): 

### Community 25 - "Community 25"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 26 - "Community 26"

Cohesion: 0.67
Nodes (2): navigateToPath, openUrl

### Community 27 - "Community 27"

Cohesion: 0.67
Nodes (2): configureAppUrlStrategy, package:flutter_web_plugins/url_strategy.dart

### Community 28 - "Community 28"

Cohesion: 0.67
Nodes (2): logToBrowserConsole, web_console_stub.dart

### Community 29 - "Community 29"

Cohesion: 1.0
Nodes (1): triggerDownload

### Community 30 - "Community 30"

Cohesion: 1.0
Nodes (1): configureAppUrlStrategy

### Community 31 - "Community 31"

Cohesion: 1.0
Nodes (1): triggerGamAdSlotRefresh

### Community 32 - "Community 32"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 33 - "Community 33"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 34 - "Community 34"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 35 - "Community 35"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 36 - "Community 36"

Cohesion: 1.0
Nodes (1): Inspects PDF layout structure and returns complexity classification.

### Community 37 - "Community 37"
_Unable to determine domain due to missing code entities._
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
Nodes (1): Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR.

### Community 41 - "Community 41"

Cohesion: 1.0
Nodes (1): Health check verifying microservice readiness, engine name, and GPU status.

### Community 42 - "Community 42"

Cohesion: 1.0
Nodes (1): Executes Baidu Unlimited OCR model inference on a 300 DPI complex document page.

### Community 43 - "Community 43"

Cohesion: 1.0
Nodes (1): Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR

### Community 44 - "Community 44"

Cohesion: 1.0
Nodes (1): Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S

## Knowledge Gaps
- **546 isolated node(s):** `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH`, `Stores job payload in Redis, with fallback to in-memory store when Redis is unav` (+541 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 29`** (2 nodes): `download_helper_stub.dart`, `triggerDownload`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (2 nodes): `url_strategy_stub.dart`, `configureAppUrlStrategy`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (2 nodes): `gam_js_interop_stub.dart`, `triggerGamAdSlotRefresh`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (1 nodes): `url_strategy_helper.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (1 nodes): `gam_js_interop.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (1 nodes): `Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (1 nodes): `Health check verifying microservice readiness, engine name, and GPU status.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (1 nodes): `Executes Baidu Unlimited OCR model inference on a 300 DPI complex document page.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (1 nodes): `Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 44`** (1 nodes): `Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.