# MVP Scope Decision: freeOCR.me

> **Stage:** ★ MVP Scoping Gate  
> **Persona:** Technical Product Strategist  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`04-feature-stories.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04-feature-stories.md)  
> **Last Updated:** 2026-08-23  

---

## Core Hypothesis Being Tested

Users actively seek a fast, highly accurate, layout-preserving AI OCR web utility that guarantees zero data retention, and will happily engage with an ad-supported model (including watching 15-second rewarded ads for stackable session limit boosts) rather than hitting aggressive paywalls or sacrificing privacy.

---

## The Minimum Value Loop

```
[Drop PDF on Hero] ──► [Layout Pre-Processing Analyzer] ──► [Live SSE Progress Stream] ──► [OCRmyPDF (CPU) or Baidu Unlimited OCR (GPU)] ──► [Side-by-Side Interactive Preview] ──► [Direct Download (.pdf, .txt, .md) OR Email Links] ──► [Input File Purged]
```

---

## MVP Feature Set Breakdown

### ✅ In MVP (Must-Haves for Launch)

| Story ID | Feature | Rationale for MVP | Complexity |
|----------|---------|------------------|-----------|
| **US-101** | Hero Drag & Drop File Upload | Core entry point; zero signup friction | Low |
| **US-102** | Real-Time SSE Progress Streaming | Prevents user drop-off during multi-page OCR jobs | Medium |
| **US-103** | Baidu Unlimited OCR & OCRmyPDF Workers | Dual-engine OCR processing (Baidu Unlimited OCR ~6 GB on GPU, OCRmyPDF on CPU) | High |
| **US-104** | Invisible Text Overlay PDF Engine | 100% original visual scan layout preservation | High |
| **US-201** | Side-by-Side Interactive Preview | Delivers the "10-second Aha moment" visual proof | Medium |
| **US-202** | 3-Format 1-Click Downloads | Flexible output formats (`.pdf`, `.txt`, `.md`) | Low |
| **US-203** | Email Link Delivery & Input Purge | User convenience + instant zero-retention compliance | Medium |
| **US-204** | 24-Hour Expiration & Expired Link Page | Manages output TTL & local time expiration notice | Low |
| **US-301** | 35-Second Display Ad Rotation | Core revenue monetization for free traffic | Low |
| **US-302** | Rewarded Ad Limit Exceeded Modal | Offers stackable video ad limit boosts (+15 pages / +20MB per ad watched) | Medium |
| **US-303** | Stackable Redis Session Boost Pass | Atomically stacks limit boosts in Redis (runtime configurable settings) | Medium |
| **US-401** | Password-in-Place PDF Decryption | Recovers encrypted scanned PDFs smoothly | Low |
| **US-402** | Automated Corrupted PDF Repair | Fallback repair pipeline (`pdfcpu` / `qpdf` / `ghostscript`) | Medium |
| **US-403** | 60-Second Ephemeral Watchdog Cleaner | Failsafe zero-retention RAM disk hygiene | Low |

---

### ⏭️ Post-MVP (v1.1 Release)

| Story ID | Feature | Rationale for Deferral | Target Release |
|----------|---------|----------------------|----------------|
| **US-501** | Firebase Auth Accounts | Zero login requirement maximizes initial viral adoption | v1.1 |
| **US-502** | Stripe Paid Subscriptions | Validate usage volume & ad revenue before adding paywalls | v1.1 |
| **US-503** | Opt-In GCP Cloud Storage Vault | Free MVP is strictly 100% ephemeral zero-retention | v1.1 |
| **US-602** | Native Mobile Apps (iOS/Android) | Flutter Web covers Mobile & Desktop web users at launch | v1.2 |

---

### 🚫 Explicitly Descoped

| Feature | Reason Descoped |
|---------|----------------|
| **Client-Side WASM OCR** | PaddleOCR-VL 1.6 (0.9B) requires Python GPU/CPU backend execution |
| **Marketing Email Newsletters** | Strict privacy focus; no user email tracking or spam campaigns |
| **Public Developer API Portal** | Deferred to v2.0 until account auth & metered billing are live |

---

## MVP Build Sequence

```
1. [FastAPI Gateway & Redis Queue Setup] 
       │
       ▼
2. [Baidu PaddleOCR-VL 1.6 Worker + Linux tmpfs RAM Disk Pipeline]
       │
       ▼
3. [Searchable PDF Composition Engine (PyMuPDF / Invisible Layer Overlay)]
       │
       ▼
4. [Flutter Web UI Hero Dropzone & File Validation]
       │
       ▼
5. [SSE Progress Streaming & Side-by-Side Interactive Viewer]
       │
       ▼
6. [3-Format Download & Email Link Delivery + Instant Purge Engine]
       │
       ▼
7. [Google Mobile Ads SDK (35s Ad Rotation & Rewarded Ad Session Boost)]
       │
       ▼
8. [End-to-End Automated Testing & Deployment to GCP] ──► [SHIP MVP]
```

---

## Technical Risks of This MVP Scope

| Risk | Mitigation |
|------|-----------|
| **High GPU Worker Demand during Peak Traffic** | Configurable worker queue caps (`MAX_CONCURRENT_WORKERS = 20`) + Redis rate limiting per IP. |
| **User Enters Wrong Email for Link Delivery** | Explicit warning badge before sending email: *"Input file is deleted immediately. Check email spelling."* |
| **Ad Blockers Suppressing Display Ads** | Non-intrusive ad banner placement; fallback prompt informing user of default free limits. |

---

## What We're Explicitly NOT Learning From This MVP

- **Paid Conversion Rate:** We are testing ad engagement and utility usage, not credit card conversion rates (deferred to v1.1).
- **Long-Term Document Storage Behavior:** All MVP files expire within 24 hours (vault storage deferred to v1.1).
- **Mobile Native Camera Usage:** Evaluated via web mobile browser, not native iOS/Android camera plugins (deferred to v1.2).
