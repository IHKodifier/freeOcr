# Graph Report - E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend  (2026-09-10)

## Corpus Check
- 21 files · ~7,879 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 120 nodes · 193 edges · 15 communities detected
- Extraction: 68% EXTRACTED · 32% INFERRED · 0% AMBIGUOUS · INFERRED: 62 edges (avg confidence: 0.74)
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

## God Nodes (most connected - your core abstractions)
1. `get_redis_client()` - 19 edges
2. `EphemeralRamStore` - 18 edges
3. `convert_document()` - 9 edges
4. `rewarded_ad_callback()` - 8 edges
5. `process_ocr_job()` - 8 edges
6. `get_searchable_pdf()` - 7 edges
7. `load_canonical_config()` - 6 edges
8. `get_ad_pass_metadata()` - 6 edges
9. `email_download_links()` - 6 edges
10. `LayoutAnalyzer` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\jobs.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_composer.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `Retrieves compiled searchable PDF bytes by token from ephemeral dev store or Red` --uses--> `EphemeralRamStore`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\pdf_composer.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py
- `convert_document()` --calls--> `load_canonical_config()`  [INFERRED]
  E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\api\v1\endpoints\ocr.py → E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\config.py

## Communities

### Community 0 - "Community 0"

Cohesion: 0.18
Nodes (17): Dispatches 24-hour expiring download links to the target email.     Uses Resend, send_download_links_email(), analyze_pdf_bytes(), LayoutAnalyzer, Document Layout and Complexity Pre-Processing Analyzer.  Analyzes uploaded PDF, convert_document(), email_download_links(), _get_normalized_client_ip() (+9 more)

### Community 1 - "Community 1"

Cohesion: 0.16
Nodes (11): dict, batch_download_zip(), get_job_preview(), get_job_status(), Returns extracted text blocks and page layout metadata for an OCR job.     Retu, Returns job status and progress for polling or verification., Streams a single ZIP archive containing all completed documents in the batch., Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes (+3 more)

### Community 2 - "Community 2"

Cohesion: 0.16
Nodes (16): download_job_file(), get_job_page_image(), Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j, 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r, compose_searchable_pdf(), get_searchable_pdf(), Retrieves compiled searchable PDF bytes by token from ephemeral dev store or Red, Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b (+8 more)

### Community 3 - "Community 3"

Cohesion: 0.17
Nodes (15): get_baidu_ocr_engine(), health_check(), is_gpu_available(), ocr_complex_page(), parse_grounding_output(), Baidu Unlimited OCR GPU Microservice.  Standalone FastAPI microservice running B, Runs inference on 300 DPI page image bytes using authentic Baidu Unlimited OCR., Health check verifying microservice readiness, engine name, and GPU status. (+7 more)

### Community 4 - "Community 4"

Cohesion: 0.27
Nodes (8): _get_tessdata_dir(), process_ocr_job(), _publish_event(), Guarantees tessdata/eng.traineddata availability for fast 1-second Tesseract OCR, Executes page-by-page OCR extraction on uploaded PDF or image file bytes.     S, _store_job(), Attempts automated repair on corrupted or damaged PDF file bytes.     1. Fixes, repair_pdf()

### Community 5 - "Community 5"

Cohesion: 0.25
Nodes (6): BaseSettings, get_runtime_config(), load_canonical_config(), Returns the single canonical global runtime configuration (limits, quotas, engin, Loads the single canonical configuration file., Settings

### Community 6 - "Community 6"

Cohesion: 0.25
Nodes (5): check_database_connection(), health_check(), healthz(), Health check endpoint returning service health status and API version., Detailed healthz check endpoint for container orchestrators and monitoring tools

### Community 7 - "Community 7"

Cohesion: 0.22
Nodes (7): BaseModel, ContactRequest, Submits a contact inquiry. Validates input and logs contact submission., submit_contact_form(), Validates email format using regex., validate_email_address(), EmailDeliveryRequest

### Community 8 - "Community 8"
_Unable to determine domain due to missing code entities._
Cohesion: 0.67
Nodes (0): 

### Community 9 - "Community 9"

Cohesion: 0.67
Nodes (2): purge_ephemeral_ram_disk(), Scans RAM disk / ephemeral temp storage directory for orphan temporary files

### Community 10 - "Community 10"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 11 - "Community 11"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 12 - "Community 12"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 13 - "Community 13"
_Unable to determine domain due to missing code entities._
Cohesion: 1.0
Nodes (0): 

### Community 14 - "Community 14"

Cohesion: 1.0
Nodes (1): Inspects PDF layout structure and returns complexity classification.

## Knowledge Gaps
- **26 isolated node(s):** `Loads the single canonical configuration file.`, `Health check endpoint returning service health status and API version.`, `Detailed healthz check endpoint for container orchestrators and monitoring tools`, `In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH`, `Stores job payload in Redis, with fallback to in-memory store when Redis is unav` (+21 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 10`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 11`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 12`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 13`** (1 nodes): `__init__.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 14`** (1 nodes): `Inspects PDF layout structure and returns complexity classification.`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.