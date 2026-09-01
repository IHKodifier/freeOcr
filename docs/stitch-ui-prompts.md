# Google Stitch UI Design Prompts — freeOCR.me

This document contains copy-pasteable Google Stitch prompts for generating screen-by-screen UI designs and design system variants for **freeOCR.me**.

> 🎨 **Active Stitch Project:** `freeOCR.me UI Architecture`
> - **Stitch Project ID:** `5093015952569298765`
> - **Stitch Resource Name:** `projects/5093015952569298765`
> - **Stitch Web UI:** Accessible in your browser at `https://stitch.google.com/projects/5093015952569298765` (or inside Google Stitch Web UI)

> 📂 **Modular Prompt Files:** All prompts are split into individual standalone files under [`docs/stitch-prompts/`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/README.md):
> - [`00-apple-design-baseline.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/00-apple-design-baseline.md) — Apple Design System Baseline
> - [`01-converter-home-screen.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/01-converter-home-screen.md) — Converter Home Screen (`/`)
> - [`02-split-preview-viewer.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/02-split-preview-viewer.md) — Split Preview Viewer (`/result/{job_id}`)
> - [`03-knowledge-base-portal.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/03-knowledge-base-portal.md) — Knowledge Base Portal (`/kb`, `/kb/*`)
> - [`04-developer-api-teaser.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/04-developer-api-teaser.md) — Developer API Teaser (`/docs`)
> - [`05-legal-compliance-pages.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/docs/stitch-prompts/05-legal-compliance-pages.md) — Privacy Policy & Terms (`/privacy`, `/terms`)

All prompts are explicitly governed by the **Apple Design System** ([`skills/apple-design/SKILL.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/skills/apple-design/SKILL.md)).

---

## Apple Design System Baseline (App-Wide Specification)

Every screen and UI variant generated via Google Stitch must conform to these Apple Design foundations:

1. **Fluid Motion & Physics-Based Springs:**
   - Default UI transitions use critically damped springs (**Damping `1.0`**, **Response `0.4s`**) for zero overshoot and natural settling.
   - Momentum-driven gestures (flicks, drag releases, sheet dismissals) use bouncier springs (**Damping `0.8`**, **Response `0.3s`**).
   - Every motion is **100% interruptible** — animations start from the live presentation value and inherit pointer velocity without hard-cuts or input lockouts.
2. **Response & Direct Manipulation:**
   - Feedback triggers instantly on `pointerdown` (`active` state `transform: scale(0.97)`). Zero tap delay (~300ms delay eliminated).
   - 1:1 direct tracking with `setPointerCapture` so content stays glued to the user's touch/cursor point.
3. **Materials, Depth & Translucency:**
   - Frosted glassmorphism surfaces (`backdrop-filter: blur(16px)` / `saturation(180%)`, background `rgba(255, 255, 255, 0.7)` in Light Mode and `rgba(15, 23, 42, 0.75)` in Dark Mode).
   - Subtle high-precision borders (`1px solid rgba(255, 255, 255, 0.12)` in Dark Mode, `1px solid rgba(0, 0, 0, 0.08)` in Light Mode).
4. **Spatial Consistency & Origin Anchoring:**
   - Menus, sheets, and popovers animate out from their trigger element (`transform-origin` set to trigger position).
   - Enter and exit paths are strictly symmetric (slide-in from right exits to right).
5. **Responsive Viewport Breakpoints & Theme Adaptation:**
   - **Phone (<640px):** Single-column stacked layouts, bottom action sheets, full-width touch targets (minimum 44x44pt).
   - **Tablet (640px – 1024px):** Adaptive split views, collapsible sidebars, multi-touch gesture support.
   - **Desktop (>1024px):** Side-by-side dual-pane workspace, keyboard shortcuts, floating action bar.
   - High-contrast automatic **Light Mode** (#F8FAFC) & **Dark Mode** (#0F172A) with vibrant indigo/violet primary accents (#6366F1).

---

## 1. Converter Home Screen (`/`)

> ✅ **Generated Screen:** `freeOCR.me - Modern Privacy OCR`  
> - **Screen ID:** `5f0b75d53617401289640a6b7d1f7716`  
> - **Logo Asset ID:** `0107dfd8295f4e3a81d199394e57a75e`  
> - **View in Stitch Web UI:** `https://stitch.google.com/projects/5093015952569298765`  

```text
Design a modern, ultra-clean responsive web application interface for freeOCR.me, a privacy-focused online OCR platform, strictly adhering to Apple Design principles (skills/apple-design/SKILL.md).

Design System & Aesthetics:
- Light/Dark Mode compatible with vibrant indigo/violet primary accents (#6366F1), slate neutral canvas (#F8FAFC / #0F172A), and frosted glassmorphic card overlays (backdrop-filter: blur(16px)).
- Typography: SF Pro / Inter optical sizing with high-contrast text hierarchy.
- Header: Centered brand identity with scanner logo ("freeOCR.me"), navigation menu ("Home", "Knowledge Base", "API Docs"), and an interactive sun/moon Theme Switcher button with spring-driven rotation physics.

Hero Section:
- Subtitle badge: "100% Free & Privacy Ephemeral • Zero Registration".
- Interactive Drag & Drop zone with 1:1 pointer tracking, instant scale feedback on press (scale(0.98)), dashed animated boundary, cloud upload icon, file picker button ("Select PDF or Images"), and max size indicator ("Up to 500MB via Ad Boost Pass").
- Supported file format chips: PDF, PNG, JPG, WEBP, TIFF, BMP.
- AdSense Leaderboard Display Banner card below hero with discrete "Sponsored" label.

Footer:
- Apple-style 4-column responsive footer:
  - Column 1: Brand description & Ephemeral Privacy Pledge.
  - Column 2: Navigation Links ("Home", "Knowledge Base", "API Docs").
  - Column 3: Engine Attributions ("Baidu Unlimited OCR", "Tesseract OCR", "OCRmyPDF", "PyMuPDF").
  - Column 4: Social Media Handles (Twitter/X, LinkedIn, Discord) + Legal Policy Links ("Privacy Policy - GDPR/CCPA", "Terms of Service").
- Responsive layouts for Mobile Phone, Tablet, and Desktop viewports.
```

---

## 2. Result & Interactive Split Preview Viewer (`/result/{job_id}`)

> ✅ **Generated Screens:**
> - **Desktop Screen ID:** `0414f6ee6e904e33a729b85fd6299a32` (`freeOCR.me - PDF Split-View Comparison`)  
> - **Mobile Screen ID:** `a0ea1b8c2a2b4870b3ff57b7c8acb232` (`freeOCR.me - PDF Comparison (Mobile)`)  
> - **View in Stitch Web UI:** `https://stitch.google.com/projects/5093015952569298765`  

```text
Design an interactive PDF split-view comparison screen for freeOCR.me following Apple Design fluid interface standards.

Layout & Components:
- Header: Back button ("Back to Converter Home") with spring hover effect, document title ("scanned_invoice_2026.pdf"), and 1-click download menu (Searchable PDF, Raw Text .txt, Markdown .md).
- Top Ad Banner: Policy-compliant Google AdSense unit with user-event rotation triggers.
- Main Split Viewer Area:
  - Left Panel: Original scanned document image render with fluid zoom controls (+ / - / fit width).
  - Right Panel: Extracted OCR text overlay rendered in JetBrains Mono / SF Mono, interactive search bar, copy-to-clipboard button with instant feedback checkmark animation.
  - Middle Divider: Draggable split handle with 1:1 pointer capture, velocity-aware release, and momentum projection (damping 0.8, response 0.3s).
- Bottom Action Dock: Floating glassmorphic bar with "Convert Another File" button and "Download Searchable PDF" primary CTA.
- Responsive Behavior: Side-by-side on Desktop (>1024px), tabbed/stacked view on Phone (<640px).
```

---

## 3. Knowledge Base Index & Educational Article Pages (`/kb`, `/kb/*`)

> ✅ **Generated Screen:** `Knowledge Base - The Evolution of PDF (Desktop)`  
> - **Screen ID:** `9a684f8e26714924ba230234c05d5b43`  
> - **Diagram Asset ID:** `6eb36569c12e42ccb33a626c36a7698d`  
> - **Engine Icon Asset ID:** `1e09c826eab84eb7b7a7305291eda58b`  
> - **View in Stitch Web UI:** `https://stitch.google.com/projects/5093015952569298765`  

```text
Design an authoritative, AdSense-qualifying Knowledge Base portal for freeOCR.me following Apple Design spatial hierarchy and typography standards.

Navigation & Layout:
- Breadcrumb navigation: Home > Knowledge Base > [Article Title].
- Left Sidebar / Tab Switcher (collapsible on Mobile):
  - "The Evolution of PDF: From PostScript to Portable Document Format"
  - "Understanding Optical Character Recognition"
  - "Zero-Disk Retention & Ephemeral RAM Security"

Article Content Card:
- Frosted glass container with rich typography (SF Pro / Inter), clear H1/H2 headings, callout boxes (Tip / Important / Architecture).
- Historical PDF Wiki content detailing PDF origins, PostScript roots, ISO 32000-2 standards, and document encoding milestones.
- Open-Source Engine Badges: Interactive reference cards explicitly acknowledging technology integration: "Powered by Baidu's Unlimited OCR AI Model, Tesseract OCR, OCRmyPDF, and PyMuPDF".
- Step-by-step visual diagram explaining raster image binarization, layout complexity analysis, invisible text layer injection, and PDF compilation.

Monetization & Sidebar:
- Right sidebar with related topics, table of contents, and a vertical AdSense rectangle banner.
```

---

## 4. Developer API Teaser Page (`/docs`)

> ✅ **Generated Screens:**
> - **Desktop Screen ID:** `c5df1a393b6e411cbe12d83682d697b6` (`freeOCR.me - Developer API Teaser`)  
> - **Mobile Screen ID:** `ce9e5f062f7445b7acec9919f04f8a77` (`freeOCR.me - Developer API Teaser (Mobile)`)  
> - **View in Stitch Web UI:** `https://stitch.google.com/projects/5093015952569298765`  

```text
Design an Apple-inspired developer teaser page for freeOCR.me's upcoming Developer API.

Layout & Hero Card:
- Header: "freeOCR.me Developer API — Access Coming Soon".
- Subtitle: "High-throughput OCR, searchable PDF composition, and SSE status streaming for developers."
- Main Content Card: Apple-grade frosted glass container (backdrop-filter: blur(16px)) with subtle glowing border gradient.

Feature Roadmap Grid:
- REST API Upload (`POST /api/v1/ocr/convert`)
- Real-Time SSE Stream (`GET /api/v1/ocr/jobs/{job_id}/events`)
- Instant Email Dispatch (`POST /api/v1/ocr/email-links`)
- OpenAPI 3.0 Specification Download

Early Access Callout:
- Email notification signup box with "Notify Me at Launch" button, featuring instant pointer-down scale feedback and spring animation.
- Badge: "Public Developer API Launching Post-MVP".
- Responsive across Mobile, Tablet, and Desktop screen sizes.
```

---

## 5. Privacy Policy & Terms of Service Pages (`/privacy`, `/terms`)

> ✅ **Generated Screens:**
> - **Privacy Policy (Desktop):** `5c8822d0eb274b6ab49e5bbec8bc2e3c` (`Privacy Policy - freeOCR.me`)  
> - **Terms of Service (Desktop):** `9f79c4d38ba04912bcebc146841a0c55` (`Terms of Service - freeOCR.me`)  
> - **Privacy Policy (Mobile):** `83b721d5ec2e4b1d94e41994ae9e8a08` (`Privacy Policy (Mobile)`)  
> - **View in Stitch Web UI:** `https://stitch.google.com/projects/5093015952569298765`  

```text
Design clean, legal & compliance documentation pages for freeOCR.me adhering to GDPR, CCPA, and Apple Design principles.

Layout & Structure:
- Single-column readable container (max-width: 800px) with frosted glass backdrop and table of contents anchor menu.

Privacy Disclosures (GDPR & CCPA Compliant):
- Transparent statements on Google AdSense cookie policy and CCPA privacy rights.
- Anonymized Google Analytics 4 telemetry disclaimers.
- Strict Zero-Disk File Retention Policy: Full disclosure on Linux tmpfs RAM disk execution, 60-second watchdog cleanup, and instant file unlinking upon download.

Terms of Service Disclosures:
- Open-source software engine licensing acknowledgments (GPL-3.0 / AGPL / Apache-2.0 upstream components).
- Service availability SLAs, acceptable usage caps, and liability limitations.

Footer:
- Apple-inspired 4-column footer featuring Social Media Handles (Twitter/X, LinkedIn, Discord) and Legal Links (Privacy / Terms). (Note: Repository links excluded).
```
