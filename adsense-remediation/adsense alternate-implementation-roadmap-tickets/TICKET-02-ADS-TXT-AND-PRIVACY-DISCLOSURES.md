# TASK DISPATCH: TICKET-02 — `ads.txt` Direct Seller Declaration & Comprehensive Privacy Disclosures

> **Ticket ID:** `MONETIZE-02`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 20 Minutes  
> **Actor:** Coding Agent & Publisher  
> **Target Files:**  
> - [`src/frontend/web/ads.txt`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/ads.txt)  
> - [`src/frontend/web/privacy/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/privacy/index.html)  
> - [`src/frontend/lib/pages/privacy_page.dart`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/lib/pages/privacy_page.dart)  
> - [`firebase.json`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/firebase.json)  
> **Prerequisites:** Account registration initiated on ad networks  
> **Governance:** Per [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)

---

## 1. Context & Objectives

To maximize RPM and enable programmatic ad exchanges (SSP / DSP demand sources) to bid on `freeOCR.me` inventory, the site must comply with the **IAB Tech Lab `ads.txt` (Authorized Digital Sellers)** specification. Simultaneously, running multi-network advertising (Google AdSense, Monetag/PropellerAds, Adsterra, Infolinks) alongside affiliate software recommendations (Impact.com/ShareASale) requires transparent, legally compliant privacy and commercial disclosures under **GDPR**, **CCPA**, and **FTC** guidelines.

### Primary Objectives:
1. **IAB Tech Lab `ads.txt` Declaration:** Establish a centralized, authoritative `ads.txt` at `https://freeocr.me/ads.txt` declaring authorized direct seller relationships for all active and reserve monetization partners.
2. **Multi-Network Advertising Policy Disclosure:** Update the Privacy Policy (`/privacy`) to explicitly disclose third-party advertising partners, non-personalized impression tracking, frequency capping, and rewarded ad verification.
3. **FTC Affiliate Disclosure:** Disclose commercial affiliate relationships for desktop PDF recommendations with mandatory `rel="sponsored nofollow"` attribution.
4. **Data Isolation Guarantee:** Provide legal and technical guarantees that third-party ad networks have zero access to uploaded user documents, OCR outputs, or Linux RAM-disk (`tmpfs`) ephemeral memory.
5. **Full Parity Between Static HTML and Flutter SPA:** Ensure identical compliance disclosures across static prerendered HTML (`src/frontend/web/privacy/index.html`) and the Flutter Web App page (`src/frontend/lib/pages/privacy_page.dart`).

---

## 2. Technical Specifications

### Part A: Authorized Digital Sellers (`src/frontend/web/ads.txt`)

Per IAB Tech Lab standards, each entry follows the format:
`<Field #1: Domain>, <Field #2: Publisher Account ID>, <Field #3: Relationship Type>, <Field #4: Certification Authority ID (Optional)>`

```text
# ==============================================================================
# freeOCR.me — Authorized Digital Sellers (ads.txt)
# Specification: IAB Tech Lab ads.txt v1.1
# Canonical Host: https://freeocr.me/ads.txt
# Last Updated: October 2026
# ==============================================================================

# ------------------------------------------------------------------------------
# Google AdSense / Google Ad Manager
# Client ID: ca-pub-6775900998665017
# TAG ID: f08c47fec0942fa0
# ------------------------------------------------------------------------------
google.com, pub-6775900998665017, DIRECT, f08c47fec0942fa0

# ------------------------------------------------------------------------------
# Monetag / PropellerAds Network
# Active Zones: 12057513 (Clean In-Page Push), 12057981 (Rewarded Vignette)
# ------------------------------------------------------------------------------
propellerads.com, 12057513, DIRECT

# ------------------------------------------------------------------------------
# Adsterra Advertising Network
# Clean Display Banners (300x250 / 728x90)
# ------------------------------------------------------------------------------
adsterra.com, 258849, DIRECT

# ------------------------------------------------------------------------------
# Infolinks Contextual Advertising Network
# Secondary InFold / InTag Display Layer
# ------------------------------------------------------------------------------
infolinks.com, 3421890, DIRECT
```

---

### Part B: Privacy Policy Disclosures (`src/frontend/web/privacy/index.html`)

Update `src/frontend/web/privacy/index.html` to introduce dedicated, robust sections:

1. **Third-Party Advertising Networks & Programmatic Partners:**
   - Explicitly list Google AdSense, Monetag (PropellerAds), Adsterra, and Infolinks.
   - Explain how advertising partners utilize transient cookies and non-identifying telemetry to measure viewability, prevent ad fraud, and execute frequency capping.

2. **Session Verification & Local Browser Storage:**
   - Disclose the use of browser `localStorage` for `freeocr_theme` (Light/Dark mode) and `freeocr_boost_*` (rewarded ad sponsorship passes for temporary 150 MB / 1 GB limit increases).
   - Confirm that local storage tokens are client-side only, non-tracking, and contain no personally identifiable information (PII).

3. **FTC Affiliate Disclosure & Commercial Transparency:**
   - Transparently disclose that outbound recommendations for specialized desktop utilities (e.g., EaseUS PDF Editor, CloudConvert) contain affiliate tracking parameters.
   - Clarify that purchases made through partner links generate a referral commission at zero additional cost to the user.

4. **Document Data Isolation & Ephemeral Security:**
   - Emphasize that ad scripts run strictly in sandboxed DOM/iframe containers and have no technical access to the client dropzone, document data buffers, or backend ephemeral RAM processing.

---

### Part C: Flutter Web Parity (`src/frontend/lib/pages/privacy_page.dart`)

Synchronize the Flutter SPA `PrivacyPage` with the static policy:
- Update Section 5: "Third-Party Advertising Networks & Cookie Disclosures".
- Add Section 6: "Session Boosts, Local Browser Storage & Fraud Prevention".
- Add Section 7: "Affiliate Partnerships & Commercial Transparency (FTC Disclosure)".
- Add Section 8: "Complete Data Isolation: Zero Ad Network Access to Document Data".

---

### Part D: Firebase Hosting Header Configuration (`firebase.json`)

Configure strict `Content-Type: text/plain; charset=utf-8` and cache-control headers for `/ads.txt` in `firebase.json` so crawler bots receive the proper MIME type without SPA HTML rewrites.

---

## 3. Verification & Compliance Checklist

- [ ] `src/frontend/web/ads.txt` contains valid seller declarations for Google, Monetag/PropellerAds, Adsterra, and Infolinks.
- [ ] `src/frontend/web/privacy/index.html` contains updated multi-network disclosures, affiliate notices, and local storage explanations.
- [ ] `src/frontend/lib/pages/privacy_page.dart` matches the static privacy policy in structure and tone.
- [ ] `firebase.json` includes custom text/plain headers for `ads.txt`.
- [ ] PowerShell compliance test (`.\scripts\Test-AdSenseCompliance.ps1 -PageFilter "privacy"`) passes with a 100% score.
- [ ] `adsense-remediation/adsense alternate-implementation-roadmap-tickets/00-PROGRESS-TRACKER.md` marked completed for TICKET-02.
