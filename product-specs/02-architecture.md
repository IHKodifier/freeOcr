# High-Level Architecture: freeOCR.me

> **Stage:** 2 — High-Level Architecture  
> **Persona:** Senior Software Architect  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`01b-tech-stack.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01b-tech-stack.md)  
> **Last Updated:** 2026-08-23  

---

## Architecture Pattern

**freeOCR.me** utilizes an **Asynchronous Event-Driven Web Utility Architecture** decoupled between a lightweight **Flutter Web** client, a **FastAPI (Python 3.13.5)** API Gateway on GCP, an in-memory **Redis** job queue, and GPU-accelerated **Celery Worker Nodes** running **Baidu PaddleOCR-VL 1.6 (0.9B)**.

To enforce the core **zero-retention privacy promise** while delivering maximum OCR performance, file conversions operate entirely within a Linux **`tmpfs` RAM disk**. Input files never touch persistent magnetic/SSD disk storage, and are unlinked instantly from RAM as soon as output PDF/text payloads are streamed back to the user.

---

## System Diagram

```mermaid
graph TD
    subgraph Client Layer
        A["Flutter Web Client (Desktop / Mobile Browser)"]
        AdSDK["Google Ads SDK (Display / Rewarded Ads)"]
    end

    subgraph Edge & API Gateway Layer
        CF["Cloudflare CDN / WAF (SSL & DDoS)"]
        GW["FastAPI Gateway (Python 3.13.5)"]
        SSE["SSE Stream Handler (Real-Time Progress)"]
    end

    subgraph Memory & State Layer (MVP Runtime)
        Redis["Redis 7 (Job Queue, Rate Limits, Ad Session Tokens)"]
    end

    subgraph Processing & Inference Engine
        Worker["Celery / Taskiq GPU Worker Nodes (GCP)"]
        RAM["Linux tmpfs (RAM Disk /tmp)"]
        OCR["Baidu PaddleOCR-VL 1.6 (0.9B Engine)"]
        Cleaner["60s Ephemeral Watchdog Process"]
    end

    subgraph Post-MVP Persistence Layer (Disabled in MVP)
        FA["Firebase Auth"]
        SQL["GCP Cloud SQL (PostgreSQL 16)"]
        GCS["GCP Cloud Storage (Paid User Vault)"]
    end

    A -->|1. Drag & Drop PDF| CF
    A -->|Watched Rewarded Ad| AdSDK
    AdSDK -->|2. Ad Token| GW
    CF -->|3. REST API Upload| GW
    GW -->|4. Validate & Queue Job| Redis
    GW -->|5. Subscribe Progress| SSE
    SSE -->|6. Real-Time SSE Stream| A
    Redis -->|7. Pop Conversion Task| Worker
    Worker -->|8. Write Ephemeral PDF| RAM
    Worker -->|9. Vision-Language Inference| OCR
    OCR -->|10. Text / Searchable PDF| RAM
    RAM -->|11. Output Stream & Instant Unlink| GW
    RAM -.->|Failsafe Cleanup| Cleaner
    
    %% Post-MVP Connections
    GW -.->|Post-MVP Auth| FA
    GW -.->|Post-MVP Metadata| SQL
    Worker -.->|Post-MVP Opt-In Vault| GCS
```

---

## Confirmed Tech Stack

Reference: [`01b-tech-stack.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01b-tech-stack.md)

- **Frontend:** Flutter 3.x (Flutter Web Desktop-first MVP → Cross-platform Mobile post-MVP → Desktop/CLI at scale).
- **Backend API:** FastAPI on Python 3.13.5 (Uvicorn ASGI server).
- **AI OCR Core:** Baidu PaddleOCR-VL 1.6 (0.9B) PyTorch/Paddle inference pipeline on GCP GPU nodes.
- **Queue & Messaging:** Redis 7 (Job queue, IP rate limiting, rewarded ad 60-min session tokens, SSE pub/sub).
- **Storage:** Ephemeral Linux `tmpfs` RAM disk (`/tmp`) for free users; opt-in GCP Cloud Storage (GCS) for post-MVP paid users.
- **Database & Auth (Post-MVP):** Firebase Auth + GCP Cloud SQL (PostgreSQL 16) via SQLAlchemy models (DB-Disabled in MVP prod).

---

## Service Responsibilities

| Service / Layer | Responsibility | Owns |
|----------------|---------------|------|
| **Flutter Web Client** | Drag-and-drop file upload UI, rewarded ad trigger, SSE progress bar, output PDF/text preview & download | Client state, Ad SDK integration, SSE event listener |
| **FastAPI Gateway** | Request validation, rate-limit enforcement, Redis task dispatching, SSE progress streaming, output delivery | API routes, input sanitization, SSE connection pool |
| **Redis Memory Store** | Job state management, IP rate-limit counters, 60-minute rewarded ad session passes, SSE message broker | Transient job status, rate-limit keys, ad tokens |
| **Celery OCR Worker** | Background job execution, reading PDF pages, invoking PaddleOCR-VL 1.6 inference engine | OCR pipeline, PDF page rendering, searchable PDF generation |
| **Baidu PaddleOCR-VL 1.6**| High-accuracy vision-language OCR execution, layout analysis, font/table position mapping | Text recognition, layout bounding box calculation |
| **Linux `tmpfs` RAM Disk** | Ultra-fast in-memory temporary storage for incoming PDF and generated output | Ephemeral file bytes in RAM (`/tmp`) |
| **Watchdog Cleanup Process**| Failsafe background cron checking `/tmp` for orphaned files older than 60 seconds | RAM disk storage hygiene & zero-retention compliance |

---

## Core Data Flow: PDF Conversion Lifecycle

```
[User Drag & Drop] 
       │
       ▼
1. Client POST /api/v1/ocr/convert (PDF Bytes + Optional Ad Session Token)
       │
       ▼
2. Gateway Rate-Limit & Config Validation (Check limits in Redis & config.py)
       │
       ▼
3. Job Created in Redis Queue ──► Client Initiates SSE Stream GET /api/v1/jobs/{job_id}/events
       │
       ▼
4. Celery Worker Picks Up Task
       │
       ▼
5. Worker Writes PDF to Ephemeral RAM Disk (`/tmp/ephemeral_<job_id>.pdf`)
       │
       ▼
6. Baidu PaddleOCR-VL 1.6 Executes Page-by-Page Inference
       │ ├──► Emit SSE Progress Update ("Page 3 of 10 converted...")
       ▼
7. Worker Renders Output Searchable PDF / Plain Text to RAM Disk (`/tmp/out_<job_id>.pdf`)
       │
       ▼
8. Output Payload Streamed to Gateway ──► Gateway Sends Download to Client
       │
       ▼
9. Python Context Manager Unlinks Input & Output Files from `tmpfs` RAM Disk (0 bytes remain)
```

---

## Searchable PDF Layout Preservation Engine (Invisible Text Overlay)

To guarantee that the output PDF looks **100% identical** to the original scanned document while making text searchable and selectable:

1. **Original Image Background:** The worker extracts each scanned PDF page as a high-resolution raster image background (`300 DPI PNG/JPEG`).
2. **Vision-Language Bounding Polygons:** **Baidu PaddleOCR-VL 1.6 (0.9B)** processes the page visually, outputting recognized text along with exact 2D bounding box polygon coordinates `[x_min, y_min, x_max, y_max]` for every word and paragraph block.
3. **Invisible Text Layer Overlay:** A PDF composition engine (via `PyMuPDF` / `fitz` or `reportlab`) embeds the original scan image as the page background, and injects a **transparent (invisible) text layer** directly over the matching `(x, y)` coordinates.
4. **Fidelity Guarantee:** No second vision AI is needed for comparison; the output PDF is visually pixel-identical to the input scan, while text selection, copy-pasting, and `Ctrl+F` search work seamlessly.

---

## Auth & Access Control

### MVP Phase (DB-Light / Unauthenticated)
- **Zero Login Barrier:** Users convert files without account registration.
- **IP & Fingerprint Rate Limiting:** Enforced via Redis sliding window counter (e.g., 5 free conversions / 24 hours).
- **60-Minute Rewarded Ad Session Pass:** Watching a rewarded ad writes a temporary session boost token to Redis (`ad_pass:{client_id}` with 3600s TTL), unlocking higher page and file size caps.

### Post-MVP Phase (Multi-Tenant SaaS)
- **Firebase Auth:** Email/Password, Google OAuth, and SAML SSO integration.
- **Bearer JWT Tokens:** Passed in `Authorization: Bearer <token>` HTTP headers.
- **Day-1 Database Schema:** SQLAlchemy tables (`users`, `subscription_tiers`, `api_keys`, `usage_logs`) pre-configured and unit-tested in local dev (`SQLite dev.db`).

---

## Third-Party Integrations

| Service | Purpose | Method | Notes |
|---------|---------|--------|-------|
| **Google Mobile Ads SDK (Web/Flutter)** | Banner display ads & Rewarded Video Ads | Flutter Plugin / JS SDK | Rewarded video callback grants 60-minute limit pass |
| **Baidu PaddleOCR-VL 1.6 (0.9B)** | Core AI Vision-Language OCR model | Native Python PyTorch/Paddle C-extensions | Self-hosted on GCP GPU worker nodes |
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
