# Development Roadmap: freeOCR.me

> **Stage:** 7 — Development Roadmap  
> **Persona:** Engineering Programme Manager  
> **Approved:** [x] approved  
> **Reads from:** All prior specs — [`04b-mvp-scope.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/04b-mvp-scope.md), [`06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)  
> **Last Updated:** 2026-08-23  

---

## Programme Summary

| Phase | Name | Duration | Gate Condition | Owner |
|-------|------|----------|---------------|-------|
| **Phase 0** | **Foundation & TDD Baseline** | Weeks 1–2 | CI/CD pipeline, Flutter shell, FastAPI skeleton, Redis & Graphify MCP initialized | Lead Engineer |
| **Phase 1** | **MVP Build (Sprints 1–3)** | Weeks 3–8 | All 13 Use Case Tickets (`UC-001`–`UC-013`) pass automated TDD tests | Dev Team |
| **Phase 2** | **Staging & User Validation** | Weeks 9–10 | Tested by 20 real users; 99%+ clean OCR conversion accuracy | Founder / PM |
| **Phase 3** | **Production Launch** | Weeks 11–12 | Deployed to GCP Cloud Run / Compute Engine; ad rotation live | All |
| **Phase 4** | **Post-MVP SaaS Expansion** | Months 3+ | Firebase Auth, SafePay Subscriptions, GCS Vault & Developer API | PM |

**Critical Path Item:** Baidu Unlimited OCR AI Model (~6 GB) & OCRmyPDF dual-engine execution on GCP worker nodes with Linux `tmpfs` RAM disk integration (`UC-003` & `UC-004`).  
**Governance Mandate:** **Strict Test-Driven Development (TDD)** — Automated test suites (`pytest` for backend, `flutter test` for UI) must be created and verified before implementation code is merged. **Graphify MCP** graph updated incrementally.

---

## Phase 0: Foundation & Tooling (Weeks 1–2 / Sprint 0)

**Goal:** Frictionless development baseline, monorepo structure, automated CI/CD TDD pipeline, local Redis/dev.db setup, and Graphify MCP initialization.

### Sprint 0 Ticket Breakdown

| Ticket | Use Case Name | Owner | Estimate | Depends On | Status |
|--------|--------------|-------|----------|------------|--------|
| **UC-000a** | Monorepo Project Structure & Dependency Initialization | Lead | S | None | Not Started |
| **UC-000b** | Local Development Pipeline, Redis & Dev Database Setup | Lead | S | UC-000a | Not Started |
| **UC-000c** | GitHub Actions CI/CD Pipeline & Graphify MCP Integration | Lead | S | UC-000a, UC-000b | Not Started |

**Phase 0 Gate:** Automated test suite executes green on GitHub Actions CI; local `.\scripts\start_backend.ps1` runs clean.

---

## Phase 1: MVP Build (Weeks 3–8)

> **Scope:** 13 Use Case Tickets assigned sequentially across 3 two-week sprints.

### Sprint 1: Core Conversion Engine & Ephemeral Processing (Weeks 3–4)

| Ticket | Use Case Name | Owner | Estimate | Depends On | Status |
|--------|--------------|-------|----------|------------|--------|
| **UC-001** | Drag & Drop PDF Upload & Validation | FE/BE | S | None | Not Started |
| **UC-002** | Real-Time SSE Progress Streaming | BE | M | UC-001 | Not Started |
| **UC-003** | Baidu Unlimited OCR & OCRmyPDF Workers & `tmpfs` RAM Disk | BE | L | UC-001 | Not Started |
| **UC-004** | Searchable PDF Composition Engine (Invisible Layer) | BE | H | UC-003 | Not Started |
| **UC-013** | Corrupted PDF Auto-Repair & 60s Watchdog RAM Cleaner | BE | M | UC-003 | Not Started |

**Sprint 1 Goal:** User can drag a PDF onto hero dropzone, watch real-time SSE progress, and generate a searchable PDF with 100% original visual layout fidelity in RAM disk.

---

### Sprint 2: Interactive Preview, Multi-Export & Email Purge Delivery (Weeks 5–6)

| Ticket | Use Case Name | Owner | Estimate | Depends On | Status |
|--------|--------------|-------|----------|------------|--------|
| **UC-005** | Interactive Side-by-Side Split Preview Viewer | FE | M | UC-002, UC-004 | Not Started |
| **UC-005b**| Premium Apple-Grade UI Generation & All-Screen Visual Polish | FE/Des | M | UC-005 | Not Started |
| **UC-006** | 1-Click Multi-Format Direct Downloads (`.pdf`, `.txt`, `.md`) | FE/BE | S | UC-004, UC-005 | Not Started |
| **UC-007** | Email Link Delivery & Immediate Input File Purging | BE | M | UC-006 | Not Started |
| **UC-008** | 24-Hour Expiration TTL & Local Time Expired Link Page | BE/FE | S | UC-007 | Not Started |
| **UC-012** | Password-in-Place Encrypted PDF Decryption | FE/BE | S | UC-001, UC-003 | Not Started |

**Sprint 2 Goal:** Users inspect OCR text in a premium side-by-side viewer; all project screens (Landing, Preview, Modals, Expired Link) feature Apple-grade glassmorphic UI polish and fluid spring physics.

---

### Sprint 3: Ad Monetization, Rewarded Session Passes & MVP Polish (Weeks 7–8)

| Ticket | Use Case Name | Owner | Estimate | Depends On | Status |
|--------|--------------|-------|----------|------------|--------|
| **UC-009** | 35-Second AdSense Display Ad Banner Auto-Rotation Timer | FE | S | None | Not Started |
| **UC-010** | Limit Exceeded Detection & Rewarded Video Ad Modal Trigger | FE | M | UC-001 | Not Started |
| **UC-011** | Rewarded Ad Callback & Stackable Session Limit Boost Pass | BE/FE | M | UC-010 | Not Started |

**Sprint 3 Goal:** 35-second rotating ad banners active; users uploading over-limit files can watch rewarded video ads to stack limit boosts (+15 pages & +20MB per ad, runtime configurable) indefinitely up to 500MB/500+ pages.

**Phase 1 Gate — MVP Definition of Done:**
- [ ] All 13 Use Case Tickets (`UC-001`–`UC-013`) pass 100% of automated unit and integration tests.
- [ ] Core user journey (Drag & drop -> SSE progress -> Preview -> Download/Email -> Purge) works end-to-end.
- [ ] Zero P0 bugs open; input file instant unlinking verified in RAM disk.

---

## Phase 2: Staging & User Validation (Weeks 9–10)

- [ ] Sentry error tracking & telemetry live.
- [ ] 20 beta users test multi-page PDF conversions.
- [ ] P95 processing latency < 4 seconds per page verified.

**Phase 2 Gate:** Beta user satisfaction confirmed; zero security/privacy compliance gaps.

---

## Phase 3: Production Launch (Weeks 11–12)

- [ ] GCP Cloud Run / Compute Engine production environment provisioned.
- [ ] Google AdSense / Google Mobile Ads SDK live credentials enabled.
- [ ] Production domain `freeocr.me` pointed via Cloudflare DNS with TLS 1.3.

**Phase 3 Gate:** Public launch live on `https://freeocr.me/`.

---

## Phase 4: Post-MVP Roadmap (Months 3+)

| Feature | Priority | Dependencies | Target Release |
|---------|----------|--------------|----------------|
| **Firebase Auth & User Accounts** | P2 | Firebase SDK integration | v1.1 |
| **SafePay Paid Subscriptions & Ad-Free Experience** | P2 | SafePay API integration | v1.1 |
| **Opt-In GCP Cloud Storage User Vault** | P2 | GCS SDK + User Auth | v1.1 |
| **Native Mobile Apps (iOS / Android)** | P3 | Flutter Mobile compilation | v1.2 |
| **Developer API & Metered Keys** | P3 | FastAPI Rate-limiting + SafePay | v2.0 |

---

## Risk Register

| Risk | Likelihood | Impact | Early Warning Sign | Mitigation |
|------|-----------|--------|--------------------|-----------|
| **Baidu Unlimited OCR Model Size & GPU Scaling** | Medium | High | GPU VRAM utilization > 85% or cold-start latency | Implement dual-engine CPU routing for simple layouts & scale CPU/GPU workers to 0 during idle periods. |
| **Ad Blockers Suppressing Banner Revenue** | High | Low | Ad impression metrics drop > 30% | Non-intrusive ad placement; transparent prompt explaining ad-supported free utility model. |
| **Orphan Files in RAM Disk on Exception** | Low | High | `tmpfs` disk usage > 500MB | Dual-layer cleanup: Python context manager `finally:` unlinking + 60s Watchdog background cleaner. |
