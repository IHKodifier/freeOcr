# Tech Stack Assessment: freeOCR.me

> **Stage:** ★ Tech Stack Interlude  
> **Persona:** Senior Staff Engineer  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md)  
> **Last Updated:** 2026-08-23  

---

## Proposed Stack Baseline (as stated by user)

- **AI OCR Core:** **Baidu's Unlimited OCR AI Model (~6 GB size)** running on GCP GPU backend infrastructure for complex layouts; **OCRmyPDF** running on CPU for simple layouts.
- **Python Environment:** **Python 3.13.5** (matching local development machine environment).
- **Frontend Tech:** **Flutter** (Flutter Web for Desktop-first MVP; native mobile apps post-MVP; Desktop/CLI apps & Developer API at scale — no React).
- **Authentication:** **Firebase Auth** (activated immediately post-MVP when user accounts launch).
- **Database Architecture:** **GCP Cloud SQL (PostgreSQL)** for staging/production; **SQLAlchemy + SQLite (`sqlite:///./dev.db`)** for zero-cloud local development.
- **MVP Database Role & Runtime Config:** **DB-Disabled / DB-Light in MVP Production**. Core conversion flow relies on **Redis** for IP rate-limiting, job queue status, and temporary stackable rewarded ad tokens (with sliding 60-minute TTL resets). Single canonical global configuration is managed via `src/backend/app/app_limits_config.json`.
- **Privacy & Storage Lifecycle:**
  - **Free / Ephemeral Users:** Strict zero-retention ephemeral processing — user input & output files purged immediately post-conversion.
  - **Paid Subscription Users (Post-MVP):** Optional secure **GCP Cloud Storage (GCS)** user vault allowing paid subscribers to save non-sensitive output PDFs.
- **Monetization:** Ad-supported freemium MVP with rewarded ad limit boosts; Day-1 architectural readiness for paid subscriptions & developer API tiers.
- **Platform Scope Roadmap:**
  - **MVP:** Responsive Desktop-first (mobile-friendly) Web App.
  - **Immediate Post-MVP:** Dedicated Mobile Apps (iOS/Android via shared Flutter codebase), Firebase Auth, Paid Subscriptions, & GCP Cloud Storage vault.
  - **At Scale:** Dedicated Desktop/CLI Apps & Public Developer API Access.

---

## Assessment

### ✅ Strong Choices

| Component | Choice | Why It Works |
|-----------|--------|-------------|
| **Frontend Framework** | **Flutter (Web + Cross-Platform)** | Single codebase targets Web for MVP, then compiles natively to iOS, Android, macOS, and Windows post-MVP without rewriting UI logic. |
| **AI OCR Engine** | Baidu Unlimited OCR AI Model (~6 GB) & OCRmyPDF | Baidu Unlimited OCR single-pass algorithm for complex layouts; OCRmyPDF for simple layouts. Both CPU & GPU scale to 0 when idle. |
| **Backend AI Processing** | FastAPI on GCP | Native Python AI model execution environment; asynchronous processing with direct PyTorch/Paddle bindings. |
| **Local-First Zero-Cloud DB** | SQLite + SQLAlchemy (`dev.db`) | Zero cloud costs during local dev; seamless dialect parity with GCP Cloud SQL PostgreSQL when deploying staging/prod. |
| **MVP DB Strategy** | Redis-only runtime (DB-Light MVP) | Eliminates database write overhead & user data compliance liability during MVP since conversions are 100% ephemeral and userless. |

---

### ⚠️ Concerns & Recommendations

| Component | Proposed | Concern | Recommended Alternative | Rationale |
|-----------|---------|---------|------------------------|-----------|
| **Flutter Web Bundle Size** | Initial WASM/JS CanvasKit download | Flutter Web initial load can be slightly heavier than plain HTML. | **Defer non-essential assets, enable Web Gzip/Brotli compression & HTML renderer optimization** | Keeps initial page render under 2 seconds for desktop web users. |
| **Model Inference Hosting** | Standard GCP Compute Engine | 0.9B model CPU execution can take 5–10s per page under high concurrency. | **FastAPI + PyTorch/Paddle Inference on GPU-accelerated GCP Compute / Cloud Run GPU container** | Offloads heavy VRAM/matrix computation to GPU workers; keeps web API response snappy. |
| **Ephemeral File Storage** | Local Disk Storage | Risk of orphaned temporary files filling server disk and violating privacy guarantees. | **Linux In-Memory `tmpfs` RAM disk / Redis Ephemeral Stream** | Guarantees instant input file unlinking post-processing without leaving residual disk traces. |
| **HTTP Conversion Queue** | Synchronous REST Request | Multi-page PDF conversions exceeding 15 seconds will hit browser/reverse-proxy HTTP timeouts. | **Async Job Queue (Redis + Celery / Taskiq) with SSE/WebSocket Progress Updates** | Allows real-time progress bar rendering in Flutter UI while keeping background processing non-blocking. |

---

### 🔴 Red Flags

- **Monolithic Synchronous Processing:** Attempting to process 30-page PDFs directly inside a standard HTTP POST request handler will cause HTTP 504 gateway timeouts. All OCR conversions **must** route through an asynchronous job queue (Redis + Celery/Taskiq).

---

### 🕳️ Missing Layers Checklist

| Layer | Needed? | Recommendation | Why |
|-------|---------|---------------|-----|
| **Frontend UI** | Yes | **Flutter Web (Dart)** | Single cross-platform codebase; responsive desktop-first layout for MVP. |
| **Backend Framework** | Yes | **FastAPI (Python 3.13.5)** | Native compatibility with Python 3.13.5, PaddleOCR/PyTorch packages, high async throughput, auto-generated OpenAPI specs. |
| **Database** | Post-MVP Prod / Dev local | **SQLAlchemy + SQLite (`dev.db`) locally; GCP Cloud SQL (PostgreSQL 16) Post-MVP** | Pre-designed SQLAlchemy models in dev; production DB activated when Firebase Auth & Paid Tiers launch post-MVP. |
| **Task Queue** | Yes | **Redis 7 + Celery (or Taskiq)** | Asynchronous job distribution for multi-page PDF processing with automated TTL queue expiration. |
| **Ad / Rewarded Network** | Yes | **Google Mobile Ads SDK for Flutter / Google AdManager** | Supports display banners & rewarded video ad triggers for temporary limit boosts across Web & Mobile. |
| **Auth** | Post-MVP | **Firebase Auth** | Frictionless Google, Email/Password, and OAuth login when accounts launch post-MVP. |
| **Payments** | Post-MVP | **Stripe Billing** | Metered usage and recurring subscription engine ready for post-MVP activation. |
| **Error Tracking** | Yes | **Sentry (Python + Flutter SDK)** | Instant alert notification when OCR model inference or file parsing exceptions occur. |

---

## Final Recommended Stack

> All layers specified. Layers deferred to post-MVP are marked explicitly with rationale.

| Layer | Technology | Decision Basis | Notes |
|-------|-----------|---------------|-------|
| **Frontend Framework** | **Flutter 3.x (Dart)** | Cross-platform UI; Flutter Web for MVP → Mobile post-MVP → Desktop/CLI at scale | Responsive Desktop-first UI, Material 3 / Custom design tokens |
| **Backend / API** | **FastAPI (Python 3.13.5)** | Native Python 3.13.5 AI model execution & async performance | Uvicorn ASGI server, Pydantic v2 validation |
| **AI OCR Engine** | **Baidu Unlimited OCR AI Model (~6 GB) / OCRmyPDF** | Superior vision-language document accuracy for complex layouts; OCRmyPDF for simple layouts | PyTorch / Paddle inference backend on GCP; scale-to-zero CPU & GPU workers |
| **Primary Database** | **SQLite (`dev.db`) local; GCP Cloud SQL (PostgreSQL 16) Post-MVP** | Relational schema for Auth, API Keys, Rate Limits | DB-Disabled in MVP Prod; SQLAlchemy models pre-built in dev |
| **Auth & Session** | **Firebase Auth (Post-MVP)** | Industry standard auth for Flutter ecosystem | Activated post-MVP when accounts launch |
| **Hosting & Deployment** | **Firebase Hosting / GCP Cloud Run (Web) + GCP Compute/Cloud Run GPU (Backend)** | Scalable GCP containerized infrastructure | CI/CD auto-deploy pipeline via GitHub Actions |
| **Caching Layer** | **Redis 7 (GCP Memorystore / Redis Cloud)** | Rate limiting counters, job status, rewarded ad tokens | In-memory key-value store powering MVP utility |
| **CDN / Asset Delivery** | **Cloudflare / GCP Cloud CDN** | DDoS protection, SSL termination, global edge caching | Free tier Cloudflare DNS + WAF |
| **File / Ephemeral Storage** | **Linux `tmpfs` (Free / Ephemeral) + GCP Cloud Storage (GCS - Post-MVP Paid Vault)** | Instant file purging for free users; opt-in secure cloud vault for paid users | Zero-retention for free users; encrypted storage for paid users |
| **Email (transactional)** | **Firebase Auth Email / Resend (Post-MVP)** | Password resets & account verification | Deferred until Post-MVP Auth activation |
| **Email (marketing)** | N/A — *Out of scope for MVP utility* | Privacy focus; no spam newsletter campaigns | Explicitly deferred |
| **SMS / Push Notifications**| **Firebase Cloud Messaging (FCM - Post-MVP)**| Push alerts for mobile apps | In-app visual toasts/progress bars for MVP |
| **Payments** | **Stripe (Post-MVP)** | Subscriptions & metered API billing | Schema designed on Day 1; disabled at launch |
| **Subscription Management**| **Stripe Billing (Post-MVP)** | Subscriptions, tier upgrades, invoice handling | Day-1 database schema support |
| **Background Jobs / Queues**| **Celery + Redis (or Taskiq)** | Asynchronous multi-page PDF processing queue | Worker process isolation from Web API |
| **Real-time / WebSockets** | **Server-Sent Events (SSE) / WebSockets** | Live progress tracking in Flutter UI | Native FastAPI SSE endpoint |
| **Search** | **Postgres Full-Text Search (FTS - Post-MVP)** | Search conversion history for authenticated users | Post-MVP feature |
| **Analytics / Telemetry** | **PostHog / Google Analytics for Firebase** | Privacy-focused product analytics & ad conversion rate | Cookieless option available |
| **Error Tracking** | **Sentry (Flutter & Python SDK)** | Full-stack error capture & performance monitoring | Traces frontend & backend exceptions |
| **Logging & Observability** | **Structured JSON Logging (structlog)** | Ephemeral log inspection without PII storage | Log scrubbing for user document names |
| **Feature Flags** | **PostHog / Firebase Remote Config** | Gradual feature rollout & ad tier toggles | Simple runtime flag evaluation in Flutter |
| **CMS / Content Layer** | N/A — *Plain Markdown for Legal & FAQ pages* | Zero external CMS overhead needed | Static pages rendered inside Flutter UI |
| **Internationalisation** | **Flutter i18n / gen-l10n (Post-MVP)** | Multi-language UI support | English at launch; i18n structure prepared |
| **AI / ML Services** | **Baidu PaddleOCR-VL 1.6 (0.9B) local pipeline** | Core OCR vision-language model | Custom Python worker wrapper on GCP |
| **Third-party Integrations**| **Google Mobile Ads SDK for Flutter (AdSense / AdMob)** | Web display ads & Rewarded Ad Video API | Rewards user with temporary limit boost |
| **Admin / Ops Panel** | **FastAPI Admin / Retool (Internal)** | Operational dashboard for queue & model metrics | System health monitoring |
| **Testing Infrastructure**| **Pytest (Backend) + Flutter Test / Integration Test** | TDD enforcement across unit & integration tests | Automated test execution prior to PR merge |
| **CI/CD Pipeline** | **GitHub Actions** | Automated testing, linting, and build verification | Strict PR gating against `dev` branch |
| **Secrets Management** | **Doppler / GCP Secret Manager** | Encrypted credential management across envs | Zero `.env` files in git repository |

---

## Decision Log

| Decision | Rationale | Trade-off Accepted |
|----------|-----------|-------------------|
| **Flutter Web Frontend** | Provides single codebase that targets Web for MVP and compiles natively to iOS, Android, and Desktop post-MVP. | Initial web bundle size is slightly larger than plain HTML, mitigated by Gzip compression & HTML renderer optimization. |
| **Python FastAPI Backend on GCP** | Required for direct native binding to Baidu PaddleOCR-VL 1.6 (0.9B) PyTorch/Paddle model execution on GCP compute. | Higher memory footprint than Go, but eliminates cross-language IPC serialization overhead. |
| **DB-Light MVP (Redis Runtime)** | In MVP (no user logins or saved files), relying on Redis for rate limits & job state eliminates unnecessary DB write overhead & data retention liability. | Requires SQLAlchemy models and migrations to be thoroughly unit-tested locally so Post-MVP DB activation is plug-and-play. |
| **Firebase Auth (Post-MVP)** | Native integration with Flutter framework for multi-platform auth across Web, Mobile, and Desktop. | Deferred to Post-MVP to keep MVP signup-free and frictionless. |
| **In-Memory `tmpfs` File Storage** | Guarantees instant file deletion post-conversion to uphold zero-retention privacy promise. | Limits single-file size based on allocated worker RAM (mitigated by file size caps & rewarded ad boosts). |
