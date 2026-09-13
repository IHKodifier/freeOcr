# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src  (2026-09-13)

## Corpus Check
- 120 files · ~246,856 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1011 nodes · 1321 edges · 45 communities detected
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 168 edges (avg confidence: 0.78)
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
1. `package:flutter/material.dart` - 49 edges
2. `get_redis_client()` - 20 edges
3. `package:flutter_test/flutter_test.dart` - 20 edges
4. `EphemeralRamStore` - 19 edges
5. `process_ocr_job()` - 19 edges
6. `../services/telemetry_service.dart` - 16 edges
7. `package:flutter/foundation.dart` - 13 edges
8. `../widgets/adsense_banner.dart` - 13 edges
9. `../widgets/app_header.dart` - 13 edges
10. `../widgets/app_footer.dart` - 13 edges

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

Cohesion: 0.02
Nodes (97): AppTheme, _buildTextTheme, codePreviewTextStyle, loadTheme, saveTheme, ThemeStorageHelper, loadTheme, saveTheme (+89 more)

### Community 1 - "Community 1"

Cohesion: 0.02
Nodes (98): AboutPage, _AboutPageState, AdSenseBanner, AppFooter, build, _buildCard, Container, initState (+90 more)

### Community 2 - "Community 2"

Cohesion: 0.03
Nodes (77): Verify that monetization parameters are present in backend configuration., Verify that GET /api/v1/config endpoint returns monetization configuration., Verify that modifying monetization parameters in config file is reflected dynami, test_adsense_config_api_endpoint(), test_adsense_config_interval_loaded(), test_dynamic_config_file_reload(), Verify downloading batch zip produces a valid ZIP file containing all completed, Verify that requesting an unsupported format returns HTTP 400 Bad Request. (+69 more)

### Community 3 - "Community 3"

Cohesion: 0.03
Nodes (64): adsense_banner.dart, AdSenseBanner, AppFooter, build, _buildActionButton, _buildDropzone, _buildFilesHeader, _buildReorderableList (+56 more)

### Community 4 - "Community 4"

Cohesion: 0.05
Nodes (52): batch_download_zip(), download_job_file(), get_job_page_image(), get_job_preview(), get_job_status(), Returns extracted text blocks and page layout metadata for an OCR job.     Retu, Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j, Returns job status and progress for polling or verification. (+44 more)

### Community 5 - "Community 5"

Cohesion: 0.05
Nodes (42): BaseModel, BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings, ContactRequest (+34 more)

### Community 6 - "Community 6"

Cohesion: 0.04
Nodes (53): brand_icons.dart, ../constants/social_links.dart, AlertDialog, Icon, openSocialChannel, SizedBox, SocialLinks, AdSenseBanner (+45 more)

### Community 7 - "Community 7"

Cohesion: 0.04
Nodes (48): dart:ui, getBrand, getBrandTitle, getDefaultHomeRoute, HostResolver, isFreeOcrDomain, isFreePdfToolsDomain, trackGa4Event (+40 more)

### Community 8 - "Community 8"

Cohesion: 0.04
Nodes (49): check_database_connection(), AlertDialog, BackdropFilter, build, _buildDocumentPreviewPane, _buildMobileBody, _buildMobileHeader, _buildRightTextPane (+41 more)

### Community 9 - "Community 9"

Cohesion: 0.07
Nodes (39): detect_page_orientation(), _get_tessdata_dir(), parse_html_table_to_lines(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, Quickly checks whether the page has rotated text (90, 180, 270 deg)     using d (+31 more)

### Community 10 - "Community 10"

Cohesion: 0.05
Nodes (41): AdSenseBanner, AppFooter, build, _buildHeadline, _buildPulseBadge, _buildSubtitle, ConstrainedBox, Container (+33 more)

### Community 11 - "Community 11"

Cohesion: 0.06
Nodes (32): api_uploader_stub.dart, dart:async, dart:convert, dart:html, dart:js, dart:math, dart:typed_data, ApiService (+24 more)

### Community 12 - "Community 12"

Cohesion: 0.09
Nodes (28): get_baidu_ocr_engine(), health_check(), is_gpu_available(), ocr_complex_page(), parse_grounding_output(), Baidu Unlimited OCR GPU Microservice.  Standalone FastAPI microservice running B, Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR., Health check verifying microservice readiness, engine name, and GPU status. (+20 more)

### Community 13 - "Community 13"

Cohesion: 0.07
Nodes (28): AnimatedHourglassIcon, _AnimatedHourglassIconState, build, _buildBatchProgressUI, _buildSingleProgressUI, Column, Container, didUpdateWidget (+20 more)

### Community 14 - "Community 14"

Cohesion: 0.08
Nodes (25): AdSenseBanner, AppFooter, build, _buildBentoCard, _buildCheckBullet, _buildCodeTeaserCard, _buildEarlyAccessCta, _buildHeroBadge (+17 more)

### Community 15 - "Community 15"

Cohesion: 0.12
Nodes (16): build, _buildFaqItem, _buildFeatureTile, _buildSectionHeader, _buildStepCard, Center, Column, Container (+8 more)

### Community 16 - "Community 16"

Cohesion: 0.22
Nodes (12): create_mock_pdf_bytes(), Helper to generate a minimal valid in-memory PDF with specified page text., AC: When uploading fewer than 2 PDF files, system rejects with HTTP 400., AC: System rejects non-PDF uploads with HTTP 400., AC: 2 valid PDFs merge into a single PDF with total combined page count., AC: Output PDF preserves the exact sequence of the files submitted., AC: System rejects more than 50 files with HTTP 400., test_merge_enforces_max_files_limit() (+4 more)

### Community 17 - "Community 17"

Cohesion: 0.22
Nodes (8): TelemetryService, trackDocumentUploaded, trackDownloadClicked, trackEmailSent, trackEvent, trackOcrCompleted, trackPageView, telemetry_helper_stub.dart

### Community 18 - "Community 18"

Cohesion: 0.25
Nodes (6): merge_pdfs(), Merges multiple PDF files in the specified sequential order using PyMuPDF., cleanup_directory(), merge_pdf_files(), Removes temporary working directory and all intermediate files., Merges 2 to 50 uploaded PDF documents into a single document in sequential order

### Community 19 - "Community 19"

Cohesion: 0.25
Nodes (7): AdSenseBanner, build, Center, LayoutBuilder, resetSessionCount, rotateAd, SizedBox

### Community 20 - "Community 20"

Cohesion: 0.25
Nodes (6): build, Card, _getStatusColor, _getStatusIcon, ProgressCard, SizedBox

### Community 21 - "Community 21"

Cohesion: 0.29
Nodes (6): get_tool_categories(), get_tool_detail(), get_tools_catalog(), Returns the complete catalog of all 16 PDF tools with metadata,     routes, and, Returns the categorized breakdown of tools., Returns metadata for a specific tool by ID.     Raises 404 if tool does not exis

### Community 22 - "Community 22"

Cohesion: 0.29
Nodes (1): test_upload_oversized_file()

### Community 23 - "Community 23"

Cohesion: 0.4
Nodes (4): download_helper_stub.dart, DownloadHelper, triggerDownload, triggerDownloadBytes

### Community 24 - "Community 24"
_Unable to determine domain due to missing code entities._
Cohesion: 0.4
Nodes (4): calculateAdsRequired, evaluate, LimitEvaluationResult, LimitEvaluator

### Community 25 - "Community 25"
_Unable to determine domain due to missing code entities._
Cohesion: 0.4
Nodes (4): navigateToPath, openUrl, UrlHelper, url_helper_stub.dart

### Community 26 - "Community 26"

Cohesion: 0.5
Nodes (0): 

### Community 27 - "Community 27"

Cohesion: 0.67
Nodes (0): 

### Community 28 - "Community 28"

Cohesion: 0.67
Nodes (2): triggerDownload, triggerDownloadBytes

### Community 29 - "Community 29"

Cohesion: 0.67
Nodes (2): navigateToPath, openUrl

### Community 30 - "Community 30"

Cohesion: 0.67
Nodes (2): configureAppUrlStrategy, package:flutter_web_plugins/url_strategy.dart

### Community 31 - "Community 31"

Cohesion: 1.0
Nodes (1): configureAppUrlStrategy

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
Nodes (1): Verify downloading zip format for a single job packages PDF, TXT, and MD into an

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
- **653 isolated node(s):** `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH`, `Stores job payload in Redis, with fallback to in-memory store when Redis is unav` (+648 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 31`** (2 nodes): `url_strategy_stub.dart`, `configureAppUrlStrategy`
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
- **Thin community `Community 38`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (1 nodes): `Verify downloading zip format for a single job packages PDF, TXT, and MD into an`
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