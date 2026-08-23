# Product Brief: freeOCR.me

> **Stage:** 1 — Idea Clarification & Product Brief  
> **Persona:** Obsessive SaaS Founder  
> **Approved:** [x] approved  
> **Last Updated:** 2026-08-23  

---

## The Problem

Users need to extract readable, searchable text from scanned PDFs, receipts, notes, and contracts every day. Current free web tools fall short: they produce inaccurate text output, mangle original document formatting, impose tight page/file size caps behind paywalls, and force users to trust unknown servers with confidential contracts or invoices. Users are frustrated by tools that sacrifice accuracy or exploit privacy just to perform basic OCR.

---

## The Insight

High-accuracy AI OCR engine capabilities (such as Baidu PaddleOCR-VL 1.6 - 0.9B) can deliver near-perfect text extraction and layout preservation. By combining backend AI processing with an aggressive zero-retention privacy policy (purging uploaded files immediately post-processing, even before download begins) and a rewarded-ad tier system, **freeOCR.me** can deliver superior OCR quality for free while establishing an infrastructure ready for subscription and developer API monetisation.

---

## Solution Overview

**freeOCR.me** is a fast, web-based OCR conversion platform that transforms scanned PDFs and images into searchable PDFs and clean text files. It pairs high-accuracy backend AI OCR with strict privacy enforcement and a generous, ad-supported free tier that users can temporarily expand by watching rewarded ads.

---

## Target Users

| Segment | Who They Are | Their Pain | Purchase Trigger |
|---------|-------------|-----------|-----------------|
| **Students & Academics** | Scanning textbooks, research papers, and handwritten lecture notes | Character errors in equations/notes, paywalls on multi-page files | Need batch conversion for full textbooks or ad-free high volume processing |
| **Legal Professionals** | Processing scanned contracts, filings, and discovery documents | Privacy risks with untrusted web servers, mangled legal formatting | Mandatory data confidentiality guarantee & high-volume API / batch processing |
| **Accountants & Admins** | Converting scanned invoices, receipts, and financial statements | Broken table/column layouts, inability to copy structured text | High-frequency monthly processing & accounting workflow integrations |
| **General Web Users** | Casual users needing one-off OCR conversions | Annoying sign-up barriers, low file size limits on free utilities | Instant single-click utility with optional rewarded ad limit boosts |

---

## Platform

- [x] Web App (Desktop & Mobile Web responsive)
- [ ] iOS (Native)
- [ ] Android (Native)
- [x] Desktop / CLI (Post-MVP consideration)

---

## Business Model

### MVP Launch (Freemium + Ad-Supported)
- **Free Tier:** Daily limit on conversion requests, page count (e.g., 5 pages/file), and maximum file size (e.g., 10MB). Banner & display ads on conversion pages.
- **Rewarded Ad Boosts:** Free users can opt to watch a short rewarded ad to unlock temporary limit increases (e.g., +15 pages, +20MB file size boost for the active session).

### Post-MVP Expansion (Architected from Day 1)
- **Paid Tier (Subscription or Usage-Based):** Monthly/annual subscription or pay-as-you-go credits unlocking ad-free experience, priority queue processing, larger file/page limits, and batch uploads.
- **Developer API Subscription:** Usage-based API keys allowing third-party developers and enterprise apps to leverage freeOCR.me's OCR backend.

---

## Key Differentiators

| Differentiator | Why It Matters | Why Competitors Can't Just Copy It |
|---------------|---------------|-------------------------------------|
| **Superior AI Accuracy & Layout Preservation** | Retains original text positions, tables, and document structures without garbling fonts | Powered by backend AI OCR integration (Baidu PaddleOCR-VL 1.6 - 0.9B) rather than basic client-side WASM |
| **Zero-Retention Ephemeral Privacy** | Guarantees user data is deleted immediately upon OCR completion (before download starts) and never trained on | Core architectural mandate built into backend pipeline, eliminating compliance risk |
| **Rewarded Ad Limit Expansion** | Gives non-paying users a way to convert larger documents without forcing an immediate paywall | Integrated rewarded ad mechanics tailored specifically for high-utility productivity workflows |
| **Day-1 API & Multi-Tenant Readiness** | Allows seamless transition from web utility to scalable SaaS platform without architectural rewrite | Designed from inception with decoupled API authentication, rate-limiting, and credit schemas |

---

## Constraints & Flagged Assumptions

### Constraints
- **Backend Dependency:** OCR cannot run purely client-side in browser WASM; backend server must handle Baidu PaddleOCR-VL 1.6 (0.9B) inference execution/API communication securely.
- **Ephemeral Storage Lifecycle:** Input files must be purged immediately post-conversion to honour zero-retention guarantee.
- **Ad Compliance:** Web ad networks must support rewarded video/interstitial ad mechanics cleanly across desktop and mobile web.

### Flagged Assumptions
- **Cost Margin:** Baidu PaddleOCR-VL 1.6 (0.9B) conversion cost / compute overhead per page is sufficiently low to remain profitable under an ad-supported revenue model.
- **User Trust:** Clear, transparent privacy badges and instant deletion guarantees will drive organic user adoption over legacy tools.

---

## Success Metrics

| Metric | 6-Month Target | 12-Month Target | Why This Metric |
|--------|---------------|-----------------|-----------------|
| **Monthly Active Conversions** | 50,000 files processed | 300,000 files processed | Validates core product utility & traffic growth |
| **OCR Conversion Success Rate** | > 99.2% clean OCR | > 99.7% clean OCR | Ensures high accuracy & user satisfaction |
| **Rewarded Ad Engagement** | 15% of active free users | 25% of active free users | Measures monetization effectiveness for high-volume free users |
| **Free-to-Paid Upgrade Rate** | N/A (MVP phase) | 2.5% upgrade rate | Demonstrates willingness to pay for ad-free & API access |
| **P95 Processing Latency** | < 4 seconds per page | < 2.5 seconds per page | Critical for user retention and frictionless UX |
