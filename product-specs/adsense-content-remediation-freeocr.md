# freeOCR.me: Google AdSense Content Remediation & Compliance Blueprint

> **Canonical Path:** `product-specs/adsense-content-remediation-freeocr.md`  
> **Status:** Deployed Live & Submitted for AdSense Review  
> **Live URL:** `https://freeocr.me`  
> **Target AdSense Publisher ID:** `ca-pub-6775900998665017`  
> **GA4 Property:** `G-E852V95BXB`  

---

## 1. Executive Summary & Review Status

The initial build of `freeocr.me` was upgraded with over 18,000 words of pre-rendered, crawlable editorial content to pass Google AdSense site approval. All automated tests pass across GitHub Actions, and live inspections confirm that search engine and AdSense crawlers receive full static HTML text with zero layout shifts or empty ad containers.

---

## 2. Architecture & File Inventory

### 2.1 Generators & Pre-Render Pipeline
- **Generator Script:** `scripts/build_seo_pages.py` (Python 3)
  - Pre-renders static markdown documentation and articles into HTML files within `src/frontend/web/`.
  - Injects canonical links, schema markup, OpenGraph metadata, and Google analytics.
- **CI/CD Integration:** `.github/workflows/deploy.yml` in job `deploy-freeocr` runs:
  ```bash
  python scripts/build_seo_pages.py
  ```
  directly after `flutter build web --release`.

### 2.2 Content Inventory

| Route / Subpage | Content Scope | Compliance & SEO Purpose |
|:---|:---|:---|
| **`/` (Index Shell)** | `<article id="editorial-content">` | Introduces the freeOCR.me dual-engine OCR architecture (Baidu PP-OCRv4 + OCRmyPDF), privacy safeguards, and 12 expandable FAQs. |
| **`/about`** | Mission & Infrastructure | Details the team background, local-first Linux RAM disk storage, scale-to-zero GCP Cloud Run infrastructure, and open-source models. |
| **`/contact`** | Support & Channels | Contact form, official email addresses (`delivery@freeocr.me`), and response commitments. |
| **`/privacy`** | Privacy & Cookies | GDPR, CCPA, and ephemeral RAM disk disclosures. Explicit Google AdSense / DoubleClick cookie clauses and opt-out links to [aboutads.info/choices](https://www.aboutads.info/choices/) and [google.com/settings/ads](https://www.google.com/settings/ads). |
| **`/terms`** | Terms of Service | Service agreements, fair usage quotas, privacy guarantees, and open-source license attribution. |
| **`/kb`** | Knowledge Base Directory | Central catalog of all OCR articles, whitepapers, and guides. |
| **`/kb/ocr-guide`** | Technical Guide | Complete guide on optimizing scanned PDFs, image DPI, binarization, and skew correction. |
| **`/kb/privacy-security`** | Privacy Whitepaper | Explains how ephemeral Linux `tmpfs` RAM disk processing protects confidential documents. |
| **`/kb/pdf-standards`** | Standards Guide | ISO 32000-1, PDF/A archival compliance, and invisible font rendering layers. |
| **`/kb/faq`** | Technical FAQ | Expanded technical answers to complex conversion and OCR questions. |
| **`/kb/ai-vs-traditional-ocr`** | Deep Whitepaper | Technical analysis of Convolutional Neural Networks (CNNs) & transformers vs rule-based OCR engines. |
| **`sitemap.xml` & `robots.txt`** | Crawler Discovery | Directs crawlers to all indexed routes under `https://freeocr.me/`. |

---

## 3. DOM & AdSense Guardrails

- **Hardcoded Ad Banner Suppression:** In `src/frontend/lib/widgets/adsense_banner.dart`, `kAdSenseApproved` remains `false` until AdSense review approval is confirmed in the Google AdSense dashboard.
- **Root Domain Matching:** All sitemaps and schema headers explicitly match `https://freeocr.me`.
- **Zero Cloud API Leakage:** Local open-source OCR engines ensure zero third-party data processing.
