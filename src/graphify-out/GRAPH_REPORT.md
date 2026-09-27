# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src  (2026-09-27)

## Corpus Check
- 190 files · ~1,223,024 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1992 nodes · 2775 edges · 73 communities detected
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 304 edges (avg confidence: 0.78)
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
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 82 edges
2. `dart:typed_data` - 37 edges
3. `../services/telemetry_service.dart` - 36 edges
4. `../widgets/adsense_banner.dart` - 32 edges
5. `../widgets/app_header.dart` - 32 edges
6. `../widgets/app_footer.dart` - 32 edges
7. `package:flutter_test/flutter_test.dart` - 32 edges
8. `package:flutter/foundation.dart` - 30 edges
9. `EphemeralRamStore` - 28 edges
10. `get_redis_client()` - 24 edges

## Surprising Connections (you probably didn't know these)
- `load_canonical_config()` --calls--> `test_canonical_config_loader()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\tests\test_config_and_quotas.py
- `healthz()` --calls--> `check_redis_connection()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\main.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `EphemeralRamStore` --uses--> `Returns job status and progress for polling or verification.`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py
- `Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `Returns extracted text blocks and page layout metadata for an OCR job.     Retu` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.01
Nodes (237): AboutPage, _AboutPageState, AdSenseBanner, AppFooter, build, _buildCard, Container, initState (+229 more)

### Community 1 - "Community 1"

Cohesion: 0.02
Nodes (181): BaseModel, BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings, ContactRequest (+173 more)

### Community 2 - "Community 2"

Cohesion: 0.01
Nodes (164): dart:typed_data, FavoritesService, isFavorite, loadTheme, saveTheme, ThemeStorageHelper, loadTheme, saveTheme (+156 more)

### Community 3 - "Community 3"

Cohesion: 0.02
Nodes (106): dart:async, dart:convert, dart:html, dart:js, AdSenseBanner, AppFooter, AppHeader, build (+98 more)

### Community 4 - "Community 4"

Cohesion: 0.04
Nodes (59): dict, detect_page_orientation(), _get_tessdata_dir(), parse_html_table_to_lines(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S (+51 more)

### Community 5 - "Community 5"

Cohesion: 0.03
Nodes (63): AdSenseBanner, AnnouncementBanner, AppFooter, build, _buildHeadline, _buildPulseBadge, _buildSubtitle, ConstrainedBox (+55 more)

### Community 6 - "Community 6"

Cohesion: 0.04
Nodes (51): check_database_connection(), AlertDialog, BackdropFilter, build, _buildDocumentPreviewPane, _buildMobileBody, _buildMobileHeader, _buildRightTextPane (+43 more)

### Community 7 - "Community 7"

Cohesion: 0.04
Nodes (46): AdSenseBanner, build, _buildEducationalFaqSection, _buildFilterChip, _buildHeroHeader, _buildHowItWorksSection, _buildPill, _buildSearchBarAndFilters (+38 more)

### Community 8 - "Community 8"

Cohesion: 0.04
Nodes (43): dart:ui, getBrand, getBrandTitle, getDefaultHomeRoute, HostResolver, isFreeOcrDomain, isFreePdfToolsDomain, AppHeader (+35 more)

### Community 9 - "Community 9"

Cohesion: 0.04
Nodes (43): adsense_banner.dart, build, _buildGuideCard, Center, Column, Divider, FeaturedGuideItem, FeaturedGuidesSection (+35 more)

### Community 10 - "Community 10"

Cohesion: 0.05
Nodes (41): build, _buildColorCircle, _buildControlsCard, _buildDocumentCard, _buildDrawTab, _buildFontStyleTile, _buildPlacementCanvas, _buildResultCard (+33 more)

### Community 11 - "Community 11"

Cohesion: 0.05
Nodes (36): brand_icons.dart, ../constants/social_links.dart, AlertDialog, Icon, openSocialChannel, SizedBox, SocialLinks, AdSenseBanner (+28 more)

### Community 12 - "Community 12"

Cohesion: 0.05
Nodes (38): api_uploader_stub.dart, dart:math, ApiService, BatchFileItem, formatBytes, Function, getBatchDownloadZipUrl, getDownloadUrl (+30 more)

### Community 13 - "Community 13"

Cohesion: 0.07
Nodes (34): extract_pdf_pages(), parse_extract_page_numbers(), Extracts specified pages from a PDF document into a merged single PDF or separat, Parses a page selection specification (comma-separated, ranges like '2-4', JSON, create_mock_pdf_bytes(), AC: Requesting page 99 on a 3-page document returns HTTP 422., Verifies endpoint returns merged PDF with correct content and headers., Verifies endpoint returns ZIP archive containing separate extracted pages. (+26 more)

### Community 14 - "Community 14"

Cohesion: 0.07
Nodes (34): create_zip_archive(), parse_page_ranges(), Creates a clean zip archive containing the provided files., Parses a page range string (e.g. '1-3, 5, 8-10') into a list of 0-indexed page n, Splits a PDF into separate files according to the provided 0-indexed page ranges, split_pdf(), create_mock_pdf_bytes(), AC: Splitting every N pages produces a ZIP archive of chunked PDFs. (+26 more)

### Community 15 - "Community 15"

Cohesion: 0.06
Nodes (34): AdSenseBanner, AppFooter, build, _buildAiVsTraditionalArticle, _buildBreadcrumbs, _buildBulletPoint, _buildDiagramStep, _buildGitHubRepoTile (+26 more)

### Community 16 - "Community 16"

Cohesion: 0.06
Nodes (33): AdSenseBanner, AppFooter, build, _buildActionButtons, _buildConfiguratorCard, _buildDocumentOverviewCard, _buildDownloadCard, _buildFormatSelector (+25 more)

### Community 17 - "Community 17"

Cohesion: 0.09
Nodes (30): delete_pdf_pages(), Deletes specified 0-indexed pages from a PDF document and saves the pruned resul, create_mock_pdf_bytes(), AC: Successfully deletes pages and returns pruned PDF with attachment header., AC: Supports comma-separated string for page indices., AC: Submitting page index outside document range returns HTTP 422., Helper to generate a minimal valid in-memory PDF with specified page text., AC: Non-PDF upload returns HTTP 400 Bad Request. (+22 more)

### Community 18 - "Community 18"

Cohesion: 0.09
Nodes (30): number_pdf_pages(), Applies formatted page numbers to pages of a PDF document at specified anchor po, create_mock_pdf_bytes(), Verifies that all 6 supported positions apply without errors., Invalid position string raises ValueError., Empty 0-byte file raises RuntimeError., Helper to generate a minimal valid in-memory PDF with specified page text., Verifies endpoint numbers pages and returns valid PDF stream with correct header (+22 more)

### Community 19 - "Community 19"

Cohesion: 0.09
Nodes (28): Permanently redacts sensitive text glyphs, vector shapes, and raster pixel strea, redact_pdf(), create_mock_pdf_bytes(), AC: Verifies coordinate-based redaction removes glyphs under specified bounding, Helper to generate a minimal valid in-memory PDF with specified page text., AC: Verifies ValueError when neither search_phrase nor rects are specified., AC: POST /api/v1/tools/redact returns HTTP 200 with sanitized PDF stream., AC: POST /api/v1/tools/redact accepts rects_json and applies redactions. (+20 more)

### Community 20 - "Community 20"

Cohesion: 0.09
Nodes (28): Applies page-specific rotations to a PDF document and saves the result.      A, rotate_pdf_pages(), create_mock_pdf_bytes(), AC: Submitting multiple page rotations applies all specified angles., AC: Submitting an angle of 45° returns HTTP 422 Unprocessable Entity., AC: Submitting rotation for a page index beyond document length returns 422., AC: Non-PDF upload returns HTTP 400 Bad Request., Helper to generate a minimal valid in-memory PDF with specified page text. (+20 more)

### Community 21 - "Community 21"

Cohesion: 0.1
Nodes (28): Inserts a signature image stream onto a specific page of a PDF document at speci, sign_pdf(), create_mock_pdf_bytes(), create_mock_png_bytes(), AC: Attempting to sign page index 99 on a 2-page document raises ValueError., AC: Empty signature image stream raises ValueError., Helper to generate a minimal valid in-memory PDF with specified page text., AC: POST /api/v1/tools/sign returns HTTP 200 and a valid signed PDF. (+20 more)

### Community 22 - "Community 22"

Cohesion: 0.09
Nodes (28): Applies custom text or transparent image watermark to all pages of a PDF documen, watermark_pdf(), create_mock_pdf_bytes(), create_mock_png_bytes(), AC: Overlays a transparent PNG onto PDF; verifies page rendering succeeds withou, AC: Unsupported watermark type raises ValueError in service., Helper to generate a minimal valid in-memory PDF with specified page text., AC: Uploading unsupported watermark type returns HTTP 400. (+20 more)

### Community 23 - "Community 23"

Cohesion: 0.06
Nodes (29): AdSenseBanner, AppFooter, build, _buildControlsCard, _buildDocumentHeader, _buildLivePreviewCard, _buildMarginSlider, _buildNoFileSelected (+21 more)

### Community 24 - "Community 24"
_Unable to determine domain due to missing code entities._
Cohesion: 0.07
Nodes (29): AdSenseBanner, AppFooter, build, _buildAngleChip, _buildConfiguratorLayout, _buildControlsPanel, _buildDocumentHeaderCard, _buildPreviewPanel (+21 more)

### Community 25 - "Community 25"
_Unable to determine domain due to missing code entities._
Cohesion: 0.07
Nodes (28): ActionChip, AdSenseBanner, AppFooter, build, _buildActionButton, _buildLivePreviewCard, _buildOverviewCard, _buildPreviewLine (+20 more)

### Community 26 - "Community 26"

Cohesion: 0.09
Nodes (26): compress_pdf(), Compresses an input PDF document using stream optimization, object deduplication, create_test_pdf_with_image(), AC: For a minimal PDF that cannot be further compressed, the output     must NE, AC: Providing an unapproved compression preset raises ValueError., AC: POST /api/v1/tools/compress with valid PDF and level returns     HTTP 200,, Helper to generate a PDF containing raster image content and text., AC: Uploading a non-PDF file returns HTTP 400. (+18 more)

### Community 27 - "Community 27"

Cohesion: 0.07
Nodes (27): AdSenseBanner, AppFooter, _applyManualRangeInput, build, _buildModeOption, _buildPageCard, _deselectAll, _detectPageCount (+19 more)

### Community 28 - "Community 28"

Cohesion: 0.07
Nodes (28): AnimatedHourglassIcon, _AnimatedHourglassIconState, build, _buildBatchProgressUI, _buildSingleProgressUI, Column, Container, didUpdateWidget (+20 more)

### Community 29 - "Community 29"

Cohesion: 0.1
Nodes (24): crop_pdf(), Applies margin cropping by updating page /CropBox dimensions without deleting, create_mock_pdf_bytes(), AC: Cropping target_page=0 modifies page 0 while leaving page 1 unchanged when a, Helper to generate a minimal valid in-memory PDF with specified page text., AC: POST /api/v1/tools/crop returns HTTP 200 and a valid cropped PDF stream., AC: Uploading non-PDF file returns HTTP 400 Bad Request., AC: Margins exceeding PDF boundaries return HTTP 422 Unprocessable Entity. (+16 more)

### Community 30 - "Community 30"

Cohesion: 0.08
Nodes (24): AdSenseBanner, AlertDialog, AppFooter, build, _buildActionButton, _buildErrorBanner, _buildFilesManagerCard, _buildStatusHeader (+16 more)

### Community 31 - "Community 31"

Cohesion: 0.17
Nodes (15): get_baidu_ocr_engine(), health_check(), is_gpu_available(), ocr_complex_page(), parse_grounding_output(), Baidu Unlimited OCR GPU Microservice.  Standalone FastAPI microservice running B, Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR., Health check verifying microservice readiness, engine name, and GPU status. (+7 more)

### Community 32 - "Community 32"
_Unable to determine domain due to missing code entities._
Cohesion: 0.15
Nodes (12): TelemetryService, trackDocumentUploaded, trackDownloadClicked, trackEmailSent, trackEvent, trackOcrCompleted, trackPageView, trackRewardedAdWatched (+4 more)

### Community 33 - "Community 33"
_Unable to determine domain due to missing code entities._
Cohesion: 0.15
Nodes (12): Validates deploy.yml invokes build_freepdftoolz_site.ps1 for the freepdftoolz jo, Smoke tests health endpoint asserting GET /api/v1/health returns HTTP 200 and he, Verifies backend CORS middleware correctly responds to requests from https://fre, Validates CI/CD deploy workflow explicitly enforces scale-to-zero Cloud Run flag, Validates firebase.json properly defines multi-site rewrites and dedicated publi, Validates dedicated FreePDFToolz pages and legal compliance links exist., test_cloud_run_configuration_scale_to_zero(), test_cors_headers_match_freepdftoolz_domain() (+4 more)

### Community 34 - "Community 34"
_Unable to determine domain due to missing code entities._
Cohesion: 0.22
Nodes (12): create_mock_pdf_bytes(), Helper to generate a minimal valid in-memory PDF with specified page text., AC: When uploading fewer than 2 PDF files, system rejects with HTTP 400., AC: System rejects non-PDF uploads with HTTP 400., AC: 2 valid PDFs merge into a single PDF with total combined page count., AC: Output PDF preserves the exact sequence of the files submitted., AC: System rejects more than 50 files with HTTP 400., test_merge_enforces_max_files_limit() (+4 more)

### Community 35 - "Community 35"
_Unable to determine domain due to missing code entities._
Cohesion: 0.17
Nodes (11): test_seo_and_dom_permanence.py — Governance and SEO Verification Test Suite  V, Verify that sitemap.xml is valid XML and contains all 23 articles plus complianc, Verify that robots.txt allows all crawlers and AdSense review bots., Verify that the Knowledge Base catalog directory lists all 23 articles., Verify that index.html retains #editorial-content permanently in the live DOM., Verify that all 23 articles exist, are substantial (>800 words), and adhere to S, test_all_23_articles_generated_and_rich(), test_editorial_content_permanence_in_index_html() (+3 more)

### Community 36 - "Community 36"

Cohesion: 0.18
Nodes (10): Verify that all 4 category directories and their index.html/flat .html files exi, Verify that each category page has proper title, description, canonical link, an, Verify that the primary navigation and footer on /kb do not use hashtag fragment, Verify that sitemap.xml includes all 4 category URLs and contains zero fragment, Verify that child articles have breadcrumbs pointing to their parent category hu, test_article_breadcrumbs_link_to_category(), test_category_pages_exist(), test_category_pages_meta_and_canonical() (+2 more)

### Community 37 - "Community 37"
_Unable to determine domain due to missing code entities._
Cohesion: 0.36
Nodes (7): analyze_pdf_bytes(), Document Layout and Complexity Pre-Processing Analyzer.  Analyzes uploaded PDF, create_sample_pdf(), test_complex_layout_landscape_orientation(), test_complex_layout_math_formula(), test_complex_layout_multipage_pure_scan(), test_simple_layout_classification()

### Community 38 - "Community 38"
_Unable to determine domain due to missing code entities._
Cohesion: 0.25
Nodes (6): merge_pdfs(), Merges multiple PDF files in the specified sequential order using PyMuPDF., cleanup_directory(), merge_pdf_files(), Removes temporary working directory and all intermediate files., Merges 2 to 50 uploaded PDF documents into a single document in sequential order

### Community 39 - "Community 39"
_Unable to determine domain due to missing code entities._
Cohesion: 0.29
Nodes (1): test_upload_oversized_file()

### Community 40 - "Community 40"

Cohesion: 0.29
Nodes (6): get_tool_categories(), get_tool_detail(), get_tools_catalog(), Returns the complete catalog of all 16 PDF tools with metadata,     routes, and, Returns the categorized breakdown of tools., Returns metadata for a specific tool by ID.     Raises 404 if tool does not exis

### Community 41 - "Community 41"

Cohesion: 0.29
Nodes (6): Verify storing job metadata includes created_at and expires_at timestamps., Verify that requesting a download for an expired job returns HTTP 410 Gone with, Verify that requesting a download for a non-existent or evicted job returns HTTP, test_download_expired_job_returns_410_gone(), test_download_non_existent_job_returns_410_gone(), test_job_metadata_timestamps()

### Community 42 - "Community 42"

Cohesion: 0.4
Nodes (4): download_helper_stub.dart, DownloadHelper, triggerDownload, triggerDownloadBytes

### Community 43 - "Community 43"

Cohesion: 0.4
Nodes (4): calculateAdsRequired, evaluate, LimitEvaluationResult, LimitEvaluator

### Community 44 - "Community 44"

Cohesion: 0.4
Nodes (4): navigateToPath, openUrl, UrlHelper, url_helper_stub.dart

### Community 45 - "Community 45"

Cohesion: 0.5
Nodes (0): 

### Community 46 - "Community 46"

Cohesion: 0.5
Nodes (0): 

### Community 47 - "Community 47"

Cohesion: 0.67
Nodes (0): 

### Community 48 - "Community 48"

Cohesion: 0.67
Nodes (2): triggerDownload, triggerDownloadBytes

### Community 49 - "Community 49"

Cohesion: 0.67
Nodes (2): navigateToPath, openUrl

### Community 50 - "Community 50"

Cohesion: 0.67
Nodes (2): configureAppUrlStrategy, package:flutter_web_plugins/url_strategy.dart

### Community 51 - "Community 51"

Cohesion: 0.67
Nodes (0): 

### Community 52 - "Community 52"

Cohesion: 1.0
Nodes (1): configureAppUrlStrategy

### Community 53 - "Community 53"

Cohesion: 1.0
Nodes (0): 

### Community 54 - "Community 54"

Cohesion: 1.0
Nodes (0): 

### Community 55 - "Community 55"

Cohesion: 1.0
Nodes (0): 

### Community 56 - "Community 56"

Cohesion: 1.0
Nodes (0): 

### Community 57 - "Community 57"

Cohesion: 1.0
Nodes (1): Inspects PDF layout structure and returns complexity classification.

### Community 58 - "Community 58"

Cohesion: 1.0
Nodes (0): 

### Community 59 - "Community 59"

Cohesion: 1.0
Nodes (0): 

### Community 60 - "Community 60"

Cohesion: 1.0
Nodes (1): Stores job payload in Redis, with fallback to in-memory store when Redis is unav

### Community 61 - "Community 61"

Cohesion: 1.0
Nodes (1): Retrieves job payload string from Redis, falling back to in-memory store.

### Community 62 - "Community 62"

Cohesion: 1.0
Nodes (1): Stores ad pass payload in Redis, with fallback to in-memory store when Redis is

### Community 63 - "Community 63"

Cohesion: 1.0
Nodes (1): Retrieves ad pass payload dict from Redis, falling back to in-memory store.

### Community 64 - "Community 64"

Cohesion: 1.0
Nodes (1): Verify Redis client initialization with expected configuration.

### Community 65 - "Community 65"

Cohesion: 1.0
Nodes (1): Verify check_redis_connection returns True when Redis ping succeeds.

### Community 66 - "Community 66"

Cohesion: 1.0
Nodes (1): Verify check_redis_connection returns False gracefully on connection exception.

### Community 67 - "Community 67"

Cohesion: 1.0
Nodes (1): Verify downloading zip format for a single job packages PDF, TXT, and MD into an

### Community 68 - "Community 68"

Cohesion: 1.0
Nodes (1): Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR.

### Community 69 - "Community 69"

Cohesion: 1.0
Nodes (1): Health check verifying microservice readiness, engine name, and GPU status.

### Community 70 - "Community 70"

Cohesion: 1.0
Nodes (1): Executes Baidu Unlimited OCR model inference on a 300 DPI complex document page.

### Community 71 - "Community 71"

Cohesion: 1.0
Nodes (1): Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR

### Community 72 - "Community 72"

Cohesion: 1.0
Nodes (1): Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S

## Knowledge Gaps
- **1371 isolated node(s):** `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH`, `Initializes and returns a Redis client.     Supports both local development Red` (+1366 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 52`** (2 nodes): `url_strategy_stub.dart`, `configureAppUrlStrategy`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 53`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 54`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 55`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 56`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 57`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 58`** (1 nodes): `url_strategy_helper.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 59`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 60`** (1 nodes): `Stores job payload in Redis, with fallback to in-memory store when Redis is unav`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 61`** (1 nodes): `Retrieves job payload string from Redis, falling back to in-memory store.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 62`** (1 nodes): `Stores ad pass payload in Redis, with fallback to in-memory store when Redis is`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 63`** (1 nodes): `Retrieves ad pass payload dict from Redis, falling back to in-memory store.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 64`** (1 nodes): `Verify Redis client initialization with expected configuration.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 65`** (1 nodes): `Verify check_redis_connection returns True when Redis ping succeeds.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 66`** (1 nodes): `Verify check_redis_connection returns False gracefully on connection exception.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 67`** (1 nodes): `Verify downloading zip format for a single job packages PDF, TXT, and MD into an`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 68`** (1 nodes): `Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 69`** (1 nodes): `Health check verifying microservice readiness, engine name, and GPU status.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 70`** (1 nodes): `Executes Baidu Unlimited OCR model inference on a 300 DPI complex document page.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 71`** (1 nodes): `Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 72`** (1 nodes): `Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.