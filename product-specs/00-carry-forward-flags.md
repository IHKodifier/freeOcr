# Carry Forward Flags: freeOCR.me

> **Purpose:** Single consolidated reference for every decision, data model requirement, deferred item, assumption, risk, and architectural note flagged for resolution in a later stage or session.
>
> **How to use:** Upload/reference this file at the start of every new session alongside the relevant stage artifacts.
>
> **Last updated:** Stage 6 — Session 1 — 2026-08-23

---

## Open Flags

| ID | Type | Flag Summary | Flagged In | Resolve By | Notes |
|----|------|-------------|-----------|-----------|-------|
| CF-DAT-001 | Data Model | Day 1 Architecture readiness for Auth, Subscription Tiers, & API Keys | Stage 1 | Stage 6 (Data Model) | Post-MVP paid tiers (SafePay integration) & API subscription must be architected from day 1 |
| CF-DEF-004 | Deferred | Rewarded ads integration & ad network selection | Stage 1 | Stage 4 (Features) | Rewarded ads system to grant 60-minute temporary limit boosts for free users |
| CF-ARC-005 | Architecture | Flutter cross-platform compilation path | Tech Stack Interlude | Stage 2 (Architecture) | Flutter Web for Desktop-first MVP; native iOS/Android builds post-MVP; Desktop/CLI apps & Developer API at scale |
| CF-DAT-006 | Data Model | DB-Light MVP strategy & local SQLite SQLAlchemy model validation | Tech Stack Interlude | Stage 6 (Data Model) | MVP Prod uses Redis-only runtime (no DB writes); SQLAlchemy models & PG migrations unit-tested in dev for Post-MVP GCP Cloud SQL activation |
| CF-ARC-007 | Architecture | GCP Cloud Storage (GCS) opt-in user vault for paid subscribers | Tech Stack Interlude | Stage 2 (Architecture) | Free users remain 100% ephemeral zero-retention; paid users optionally save non-sensitive PDFs to encrypted GCS vault |
| CF-ENV-008 | Environment | Python 3.13.5 backend environment alignment | Tech Stack Interlude | Stage 2 (Architecture) | FastAPI backend & PaddleOCR dependencies compiled and executed on Python 3.13.5 |
| CF-ARC-009 | Architecture | Configurable MVP limit & concurrency posture | Stage 2 | Stage 2 (Architecture) | Page caps, file size limits, session duration, and worker concurrency externalized to `config.py` settings |
| CF-ARC-010 | Architecture | 24-Hour Output TTL & Email Download Link Delivery | Stage 3 | Stage 2 (Architecture) | Output files expire in 24 hours (with local time expired link page); input files purged immediately on direct download OR "Send Email" click |
| CF-UI-011 | UI / UX | 35-Second Ad Rotation Refresh Timer | Stage 3 | Stage 5 (Style Guide) | Display ads on landing & download pages automatically rotate every 35 seconds when page stays active |
| CF-GOV-012 | Governance | Strict Test-Driven Development (TDD) Mandate | Governance | Stage 7a (Charter) | Automated tests in `./src/tests/unit/` or `./src/tests/integration/` MUST be created before writing implementation code for any ticket |
| CF-GOV-013 | Governance | Graphify MCP Cognitive Burden Reduction | Governance | Stage 7a (Charter) | Incrementally update Graphify MCP graph during build to maintain code relationships and lower agent context load |

---

## Resolved Flags

| ID | Type | Flag Summary | Flagged In | Resolved In | Resolution Summary |
|----|------|-------------|-----------|------------|-------------------|
| CF-ARC-002 | Architecture | Backend AI OCR integration & ephemeral file processing pipeline | Stage 1 | Stage 2 (Architecture) | Baidu PaddleOCR-VL 1.6 (0.9B) backend execution on GCP using `tmpfs` Linux RAM disk for file processing |
| CF-RSK-003 | Risk | Zero data retention & strict ephemeral cleanup guarantee | Stage 1 | Stage 2 (Architecture) | Dual-layer cleanup: Python context manager instant `tmpfs` unlinking post-conversion + 60s background watchdog cleaner process |
