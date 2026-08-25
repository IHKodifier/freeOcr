# High-Level Architecture: freeOCR.me

> **Stage:** 2 — High-Level Architecture  
> **Persona:** Senior Software Architect  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`01b-tech-stack.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01b-tech-stack.md)  
> **Last Updated:** 2026-08-23  

---

## Architecture Pattern

**freeOCR.me** utilizes an **Asynchronous Event-Driven Web Utility Architecture** decoupled between a static **Firebase Hosting (GCP Global CDN)** frontend serving the **Flutter Web** application (<20ms latency, 0s cold start, $0.00/mo cost), a **FastAPI (Python 3.13.5)** API Gateway on **GCP Cloud Run** (scales to `min-instances = 0` during idle periods), an in-memory **Redis** job queue router, a **Document Layout Complexity Analyzer**, and dual-engine worker nodes:
- **Frontend Hosting (Firebase Hosting):** Serves static Flutter Web compiled assets, SEO knowledge articles, blog posts, and legal terms instantly without container cold starts. Sends an optimistic background `GET /api/v1/config` ping upon app boot to pre-warm the scale-to-zero Cloud Run API container before document upload.
- **Backend API (GCP Cloud Run):** Runs Python 3.13.5 FastAPI Gateway (`min-instances = 0`) for scale-to-zero $0 idle cost.
- **CPU Worker Nodes:** Running **OCRmyPDF** on GCP CPU compute (scales to 0 during idle periods).
- **GPU Worker Nodes:** Running **Baidu's Unlimited OCR AI Model (~6 GB)** on GCP GPU compute (scales to 0 during idle periods).

To enforce the core **zero-retention privacy promise** while delivering maximum OCR performance, file conversions operate entirely within a Linux **`tmpfs` RAM disk**. Input files never touch persistent magnetic/SSD disk storage, and are unlinked instantly from RAM as soon as output PDF/text payloads are streamed back to the user.

---

## System Diagram

```mermaid
graph TD
    subgraph Frontend Edge Layer (0s Cold Start, $0.00/mo)
        FH["Firebase Hosting (GCP Global Static CDN)"]
        A["Flutter Web Client (Desktop / Mobile Browser)"]
        AdSDK["Google Ads SDK (Display / Rewarded Ads)"]
    end

    subgraph Edge & API Gateway Layer
        CF["Cloudflare CDN / WAF (SSL & DDoS)"]
        GW["FastAPI Gateway on GCP Cloud Run (min-instances=0)"]
        SSE["SSE Stream Handler (Real-Time Progress)"]
        LA["Layout & Complexity Analyzer (PyMuPDF Heuristics)"]
    end

    subgraph Memory & State Layer (MVP Runtime)
        Redis["Redis 7 (Dual Queues, 5h Quotas, Stacked 60m Ad Boosts)"]
        Config["Single Canonical Config (app_limits_config.json)"]
    end

    subgraph Dual Processing & Inference Engine
        QueueCPU["ocr:queue:cpu (Simple Layout Queue)"]
        QueueGPU["ocr:queue:gpu (Complex Layout Queue)"]
        TriggerCPU["CPU Cold-Start Trigger (Scale-to-Zero)"]
        TriggerGPU["GPU Cold-Start Trigger (Scale-to-Zero)"]
        WorkerCPU["Celery CPU Worker Node (OCRmyPDF)"]
        WorkerGPU["Celery GPU Worker Node (Baidu Unlimited OCR ~6GB)"]
        RAM["Linux tmpfs (RAM Disk /tmp)"]
        Cleaner["60s Ephemeral Watchdog Process"]
    end

    subgraph Post-MVP Persistence Layer (Disabled in MVP)
        FA["Firebase Auth"]
        SQL["GCP Cloud SQL (PostgreSQL 16)"]
        GCS["GCP Cloud Storage (Paid User Vault)"]
    end

    FH -->|1. Instant Web App Serve <20ms| A
    A -.->|2. App Boot Pre-Warm Ping| GW
    A -->|Watched Rewarded Ad| AdSDK
    AdSDK -->|3. Stacked Ad Token (Resets 60m TTL)| GW
    CF -->|4. REST API Upload| GW
    GW -->|5. Read Global Parameters| Config
    GW -->|6. Analyze Layout Complexity| LA
    LA -->|Simple Layout| QueueCPU
    LA -->|Complex Layout| QueueGPU
    QueueCPU -.->|Trigger if Idle| TriggerCPU
    QueueGPU -.->|Trigger if Idle| TriggerGPU
    TriggerCPU --> WorkerCPU
    TriggerGPU --> WorkerGPU
    GW -->|7. Subscribe Progress| SSE
    SSE -->|8. Real-Time SSE Stream| A
    WorkerCPU -->|9. Write Ephemeral PDF| RAM
    WorkerGPU -->|9. Write Ephemeral PDF| RAM
    WorkerCPU -->|10. CPU OCR Execution| RAM
    WorkerGPU -->|10. AI Vision-Language Inference| RAM
    RAM -->|11. Output Stream & Instant Unlink| GW
    RAM -.->|Failsafe Cleanup| Cleaner
    
    %% Post-MVP Connections
    GW -.->|Post-MVP Auth| FA
    GW -.->|Post-MVP Metadata| SQL
    WorkerGPU -.->|Post-MVP Opt-In Vault| GCS
```


---

## Confirmed Tech Stack

Reference: [`01b-tech-stack.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01b-tech-stack.md)

- **Frontend:** Flutter 3.x (Flutter Web Desktop-first MVP → Cross-platform Mobile post-MVP → Desktop/CLI at scale).
- **Backend API:** FastAPI on Python 3.13.5 (Uvicorn ASGI server).
- **Single Canonical Config:** `src/backend/app/app_limits_config.json`.
- **Layout Pre-Processor:** `PyMuPDF` (`fitz`) structural analyzer detecting columns, tables, and formulas.
- **Dual OCR Core:**
  - **Simple Layouts:** `OCRmyPDF` on GCP CPU workers (scale to 0).
  - **Complex Layouts:** Baidu's Unlimited OCR AI Model (~6 GB) on GCP GPU workers (scale to 0).
- **Queue & Messaging:** Redis 7 (Dual queues `ocr:queue:cpu` & `ocr:queue:gpu`, 5h quotas, 60m sliding ad tokens, SSE pub/sub).
- **Storage:** Ephemeral Linux `tmpfs` RAM disk (`/tmp`) for free users; opt-in GCP Cloud Storage (GCS) for post-MVP paid users.
- **Database & Auth (Post-MVP):** Firebase Auth + GCP Cloud SQL (PostgreSQL 16) via SQLAlchemy models (DB-Disabled in MVP prod).

---

## Service Responsibilities

| Service / Layer | Responsibility | Owns |
|----------------|---------------|------|
| **Flutter Web Client** | Drag-and-drop file upload UI, rewarded ad trigger, SSE progress bar, output PDF/text preview & download | Client state, Ad SDK integration, SSE event listener |
| **FastAPI Gateway** | Request validation, rate-limit enforcement, Redis task dispatching, SSE progress streaming, output delivery | API routes, input sanitization, SSE connection pool |
| **Layout Analyzer** | Inspects PDF structure, bounding boxes, column layout, tables, and math formulas post-upload | Complexity classification (`SIMPLE` / `COMPLEX`) |
| **Redis Memory Store** | Job state management, 5h simple/complex quota counters, stackable 60m ad limit tokens, SSE message broker | Transient job status, rate-limit keys, ad boost tokens |
| **Celery CPU Worker** | Background job execution for simple layouts using OCRmyPDF; scale-to-zero when queue empty | CPU OCR pipeline, searchable PDF generation |
| **Celery GPU Worker** | Background job execution for complex layouts using Baidu's Unlimited OCR AI Model (~6 GB); scale-to-zero when queue empty | Vision-language OCR pipeline, table & formula parsing |
| **Linux `tmpfs` RAM Disk** | Ultra-fast in-memory temporary storage for incoming PDF and generated output | Ephemeral file bytes in RAM (`/tmp`) |
| **Watchdog Cleanup Process**| Failsafe background cron checking `/tmp` for orphaned files older than 60 seconds | RAM disk storage hygiene & zero-retention compliance |


---

## Core Data Flow: PDF Conversion Lifecycle

[User Drag & Drop] 
       │
       ▼
1. Client POST /api/v1/ocr/convert (PDF Bytes + Optional Ad Session Token)
       │
       ▼
2. Gateway Layout Analysis & Quota Check (PyMuPDF layout analyzer → SIMPLE or COMPLEX → Check 5h quotas & app_limits_config.json)
       │
       ▼
3. Job Dispatched to ocr:queue:cpu or ocr:queue:gpu ──► If worker inactive, fire Cold-Start Trigger ──► Client Initiates SSE Stream
       │
       ▼
4. Celery Worker (CPU / GPU) Picks Up Task from Respective Queue
       │
       ▼
5. Worker Writes PDF to Ephemeral RAM Disk (`/tmp/ephemeral_<job_id>.pdf`)
       │
       ▼
6. OCR Engine (OCRmyPDF on CPU or Baidu Unlimited OCR on GPU) Executes Processing
       │ ├──► Emit SSE Progress Update ("Page 3 of 10 converted...")
       ▼
7. Worker Renders Output Searchable PDF / Plain Text to RAM Disk (`/tmp/out_<job_id>.pdf`)
       │
       ▼
8. Output Payload Streamed to Gateway ──► Gateway Sends Download to Client
       │
       ▼
9. Python Context Manager Unlinks Input & Output Files from `tmpfs` RAM Disk (0 bytes remain)

---

## Searchable PDF Layout Preservation Engine (Invisible Text Overlay)

To guarantee that the output PDF looks **100% identical** to the original scanned document while making text searchable and selectable:

1. **Original Image Background:** The worker extracts each scanned PDF page as a high-resolution raster image background (`300 DPI PNG/JPEG`).
2. **Vision-Language Bounding Polygons:** **Baidu's Unlimited OCR AI Model (~6 GB)** processes complex pages visually (or `OCRmyPDF` for simple single-column pages), outputting recognized text along with exact 2D bounding box polygon coordinates `[x_min, y_min, x_max, y_max]` for every word, paragraph block, table, and formula.
3. **Invisible Text Layer Overlay:** A PDF composition engine (via `PyMuPDF` / `fitz` or `reportlab`) embeds the original scan image as the page background, and injects a **transparent (invisible) text layer** directly over the matching `(x, y)` coordinates.
4. **Fidelity Guarantee:** No second vision AI is needed for comparison; the output PDF is visually pixel-identical to the input scan, while text selection, copy-pasting, and `Ctrl+F` search work seamlessly.

---

## Unified Runtime Configuration Architecture (Zero-Redeploy)

To ensure that changing basic limits, per-ad boost increments, or ad rotation timers **never requires redeploying the website or rebuilding frontend/backend binaries**, all runtime parameters are consolidated into a single configuration file (`src/backend/app/app_limits_config.json`) served dynamically via `GET /api/v1/config`.

### 1. Single Configuration Source (`src/backend/app/app_limits_config.json`)
```json
{
  "limits": {
    "base_max_file_mb": 10,
    "base_max_pages": 10,
    "simple_quota_5h": 20,
    "complex_quota_5h": 5,
    "boost_per_ad_mb": 20,
    "boost_per_ad_pages": 15,
    "ad_boost_ttl_seconds": 3600,
    "max_stack_file_mb": 500,
    "max_stack_pages": 500
  },
  "monetization": {
    "ad_rotation_interval_seconds": 35,
    "rewarded_ad_duration_seconds": 15,
    "display_ads_enabled": true,
    "rewarded_ads_enabled": true
  },
  "engines": {
    "simple_engine": "OCRmyPDF",
    "complex_engine": "Baidu_Unlimited_OCR"
  }
}
```

### 2. Runtime Flow (Zero Redeploy)
1. **Frontend Bootstrapping:** When Flutter Web initializes, it calls `GET /api/v1/config` to fetch active limits, ad rotation timers, and stackable boost rules.
2. **Backend Enforcement:** FastAPI loads `app_limits_config.json` at runtime (overridable via `.env` or hot-reloaded on file modification). Both file validation endpoints and ad callbacks consume this single configuration object.
3. **Instant Hot Updates:** Updating `app_limits_config.json` immediately alters dropzone validation rules, ad rotation timers, and backend limits for all connected users without code compilation or server redeployment.

---

## Auth & Access Control

### MVP Phase (DB-Light / Unauthenticated)
- **Zero Login Barrier:** Users convert files without account registration.
- **IP & Fingerprint Rate Limiting:** Enforced via 5-hour rolling window counters in Redis for **Simple Layout** and **Complex Layout** conversions.
- **Stackable Rewarded Ad Limit Boost Pass:** Watching rewarded video ads atomically increments session limit counters in Redis (`ad_pass:{client_id}` with runtime configurable step sizes +20MB / +15 pages per ad), stacking allowed limits indefinitely up to 500+ MB / 500+ pages. **Reset-on-Stack Expiry Policy:** Each newly watched rewarded ad resets the 60-minute countdown timer to 60 minutes from the timestamp of the latest ad watched (`EXPIRE ad_pass:{ip} 3600`).

---

## Third-Party Integrations

| Service | Purpose | Method | Notes |
|---------|---------|--------|-------|
| **Google Mobile Ads SDK (Web/Flutter)** | Banner display ads & Rewarded Video Ads | Flutter Plugin / JS SDK | Rewarded video callback grants stackable session limit boosts (+15 pages / +20MB per ad) with 60-minute sliding TTL |
| **Baidu Unlimited OCR AI Model (~6 GB)** | Core AI Vision-Language OCR model | Native Python PyTorch/Paddle C-extensions | Self-hosted on GCP GPU worker nodes (scale-to-zero when queue empty) |
| **OCRmyPDF** | Standard CPU OCR Engine | Python subprocess / C-bindings | Self-hosted on GCP CPU worker nodes (scale-to-zero when queue empty) |
| **Sentry** | Error tracking & exception monitoring | Python & Flutter Sentry SDKs | Captures backend/frontend crashes without PII |
| **Cloudflare** | DNS, SSL termination, DDoS protection | Cloudflare Proxy | Edge caching for static web assets |

---

## Infrastructure & Scaling Matrix

| Component | Service | Tier at Launch | Scale Trigger |
|-----------|---------|---------------|---------------|
| **Web Frontend** | Firebase Hosting / GCP Cloud Run | Free Tier / Standard Web | > 10,000 daily web visitors |
| **API Gateway** | GCP Cloud Run / Compute Engine | 2 vCPU, 4GB RAM (Auto-scale 1-5 instances) | CPU utilization > 70% |
| **OCR Workers** | GCP Compute Engine (GPU / High-CPU) | 1x NVIDIA T4 / L4 GPU (or High-CPU ONNX) | Queue depth > 10 pending jobs |
| **In-Memory Store** | GCP Memorystore for Redis | 1 GB Redis 7 Instance | Memory usage > 75% |
| **Ephemeral Disk** | Linux `tmpfs` RAM Disk | 2 GB mounted at `/tmp` | Managed via Python context manager + Watchdog |
| **Post-MVP Database**| GCP Cloud SQL (PostgreSQL 16) | db-f1-micro (Dev/Staging); db-custom-2-8 (Prod) | Post-MVP Auth & Paid Tier Launch |

---

## Security & Compliance

### Ephemeral Privacy Enforcement
- **Zero-Retention Guarantee:** Input files are written strictly to Linux `tmpfs` RAM disk and unlinked immediately post-processing.
- **Dual-Layer Cleanup:**
  1. **Immediate Execution Cleanup:** Python `try ... finally` context manager executes `os.remove()` / `unlink()` instantly upon job completion.
  2. **60-Second Watchdog Cleaner:** Independent background process scans `/tmp` every 30 seconds and purges any file with an `mtime` older than 60 seconds.
- **Zero Model Training:** Customer document data is never saved, logged, or fed into model training pipelines.

### Data in Transit
- **TLS 1.3 Encryption:** All client-to-server traffic is encrypted using HTTPS via Cloudflare & GCP SSL certificates.

---

## Scalability Strategy & Configurable Posture

All system operational boundaries are **fully externalized** in `config.py` / `.env` settings to enable instant adjustments without code deployment:

```python
# config.py - System Limit & Posture Settings
FREE_TIER_PAGE_LIMIT = int(os.getenv("FREE_TIER_PAGE_LIMIT", 10))
FREE_TIER_MAX_FILE_MB = int(os.getenv("FREE_TIER_MAX_FILE_MB", 15))
REWARDED_AD_SESSION_MINUTES = int(os.getenv("REWARDED_AD_SESSION_MINUTES", 60))
REWARDED_AD_PAGE_LIMIT = int(os.getenv("REWARDED_AD_PAGE_LIMIT", 50))
MAX_CONCURRENT_WORKERS = int(os.getenv("MAX_CONCURRENT_WORKERS", 20))
EPHEMERAL_WATCHDOG_TTL_SEC = int(os.getenv("EPHEMERAL_WATCHDOG_TTL_SEC", 60))
```

---

## Key Technical Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| **`tmpfs` RAM Disk Overflow** | Medium | High | Strict file size validation at Gateway before accepting upload + 60s Watchdog cleaner process. |
| **Slow Multi-Page OCR Latency** | Medium | Medium | Asynchronous Redis queue + Celery workers with real-time SSE progress updates to client. |
| **Ad Blocker Interferences** | High | Low | Graceful fallback UI when ad SDK is blocked; user informed of default free limits. |
| **GCP GPU Cost Spikes** | Low | High | Dynamic worker auto-scaling with hard upper limit caps (`MAX_CONCURRENT_WORKERS = 20`). |

---

## Scale Profile

> This section defines the app's scale posture and the architectural decisions it drives.

**Scale Target:** Global Web Utility (Desktop-First Responsive Web)

| Dimension | Launch (MVP) | 12 Months | Global Scale Target |
|-----------|--------------|-----------|--------------------|
| **Concurrent Users** | 50 peak concurrent | 1,500 peak concurrent | 25,000 peak concurrent |
| **Requests / sec (peak)** | 15 req/sec | 250 req/sec | 3,000 req/sec |
| **Data Volume (Daily)** | ~500 PDFs / day | ~25,000 PDFs / day | ~500,000 PDFs / day |
| **Geographic Regions** | Single GCP Region (us-central1) | Multi-Region GCP | Multi-Region Global Edge |
| **Languages Supported** | English UI (Multi-lang OCR) | English, Spanish, French UI | 15+ Locales |

---

### Global Scale Considerations

| Concern | In Scope Now? | Decision / Approach |
|---------|--------------|---------------------|
| **Multi-Region Deployment** | Post-MVP | Cloudflare CDN edge caching for Web UI; GCP regional worker clusters. |
| **Data Sovereignty / GDPR** | Yes | Zero-retention RAM disk execution eliminates data sovereignty compliance issues. |
| **Localisation (i18n)** | Post-MVP | Flutter i18n localization framework pre-structured in UI code. |
| **Global Abuse / Rate Limiting** | Yes | Cloudflare WAF + Redis sliding window rate limiter per client IP. |
