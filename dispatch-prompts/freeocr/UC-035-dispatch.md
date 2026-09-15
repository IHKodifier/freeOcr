# TASK DISPATCH: Implement UC-035 (AdSense Review Original Article: Deep-Learning AI vs Traditional OCR for Complex Document Layouts)

> **Ticket:** `UC-035`  
> **Target Domain:** `freeocr.me`  
> **Campaign:** Google AdSense Site Review & Editorial Freshness Qualification  
> **Target File:** [`dispatch-prompts/freeocr/UC-035-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freeocr/UC-035-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated verification tests in `src/frontend/test/` and `src/tests/` MUST be written and pass before declaring completion.
4. **Branching Protocol:** Work strictly on dedicated feature branch `feature/UC-035-adsense-article` checked out from `dev`. NEVER push directly to `main`.
5. **AdSense Compliance Mandate:** Content must be 100% original, deeply technical, authoritative (E-E-A-T), formatted with high-contrast typography, and crawlable via pre-rendered static HTML as well as client-side Flutter rendering.

---

## 2. Ticket Specification — UC-035

**Ticket ID:** UC-035  
**Name:** AdSense Editorial Article: Deep-Learning AI vs Traditional OCR for Complex Layouts  
**Epic:** AdSense Site Review & Editorial Content Freshness  
**Target Domain:** `https://freeocr.me`  
**Route & Slug:** `/kb/ai-vs-traditional-ocr` (with canonical alias `/kb/ai-ocr-complex-layouts`)  
**Actor:** Search Engine Crawlers (`Googlebot`, `Mediapartners-Google`) & Web Visitors  
**Trigger:** AdSense crawler re-inspection during site review window or visitor navigating Knowledge Base.

---

## 3. Article Editorial Specifications

### Title & Metadata
- **Title:** *Why Deep-Learning AI OCR Outperforms Classical OCR on Complex Document Layouts*
- **Meta Description:** *An engineering comparison between classical heuristic OCR (Tesseract) and Vision-Language Transformer OCR on multi-column articles, borderless tables, mathematical formulas, and rotated scans.*
- **Word Count:** 1,800+ words of original, comprehensive technical analysis with comparison tables, architectural diagrams, and benchmark metrics.

### Core Sections & Technical Deep Dive
1. **The Heuristic Wall: How Classical OCR Fails Document Geometry:**
   - How legacy engines (e.g., standard Tesseract 3/4) rely on vertical/horizontal projection profiles to guess columns.
   - Failure modes: Multi-column newspaper layouts read horizontally across columns, merging unrelated paragraphs; nested tables with borderless cells parsed as scrambled run-on sentences; marginalia and stamps corrupting main body text.
2. **The Vision-Language Revolution (Transformers & DLA):**
   - Document Layout Analysis (DLA) + Reading Order Detection (ROD) as a unified neural task.
   - How modern Vision-Language models (e.g., Baidu's PaddleOCR / LayoutLM) identify semantic blocks (Title, Header, Table Cell, Caption, Body) *before* optical character recognition begins.
3. **Head-to-Head Comparative Benchmark:**
   - Concrete comparison table across 5 difficult document archetypes:
     - Multi-column research papers (IEEE/ACM formats).
     - Financial balance sheets & bank statements with invisible gridlines.
     - Receipts with crumpled paper, skewed rotation, and non-uniform thermal print.
     - Historical archival scans with bleed-through ink and varied illumination.
     - Forms with checkboxes, underline blanks, and handwritten annotations.
4. **Searchable PDF Text Injection (True Coordinate Layering):**
   - How `freeocr.me` uses PyMuPDF and OCRmyPDF to embed an invisible glyph layer precisely positioned under original scan rasters in compliance with ISO 32000-2, preserving exact visual layout while enabling Ctrl+F searchability.
5. **Zero-Disk Retention in AI OCR Workflows:**
   - Why processing documents entirely within RAM disks (`tmpfs`) protects data privacy against commercial cloud OCR vendors who log prompts and inputs for model training.

---

## 4. Integration Architecture & System Placement

### A. Frontend Flutter Knowledge Base (`src/frontend/lib/pages/kb_page.dart`)
1. **New Navigation Tab & Slug Support:**
   - Add new article tab index (`_slugToTab('ai-vs-traditional-ocr')`).
   - Add entry in desktop Left Sidebar:
     - Title: `AI vs Traditional OCR`
     - Subtitle: `Solving Complex Document Layouts`
     - Icon: `Icons.psychology_outlined`
   - Add entry in mobile segmented tabs button: `AI vs Legacy`.
2. **Dedicated Article View Method (`_buildAiVsTraditionalArticle`):**
   - Render structured content with `GlassCard`, section headers, responsive data tables, callout blocks, and code/formula snippets.
3. **Table of Contents (Right Sidebar):**
   - Update TOC to dynamically reflect the active article sections:
     - `The Heuristic Geometry Wall`
     - `Vision Transformers & Layout Analysis`
     - `Layout Benchmark Matrix`
     - `Searchable PDF Coordinate Layering`
     - `Zero-Disk Ephemeral Privacy`

### B. Route Routing (`src/frontend/lib/main.dart`)
Ensure `/kb/ai-vs-traditional-ocr` routes to `KbPage(initialArticleSlug: 'ai-vs-traditional-ocr')`.

### C. Site-Wide Internal Linking (SEO Discovery Graph)
1. **Global Footer (`src/frontend/lib/widgets/app_footer.dart`):**
   - In the "Resources / Knowledge Base" column, add a link: `AI vs Classical OCR` navigating to `/kb/ai-vs-traditional-ocr`.
2. **Homepage FAQ (`src/frontend/lib/widgets/landing_faq_section.dart`):**
   - Add a targeted FAQ item:
     - *Q: How does freeOCR.me handle complex multi-column PDFs and tables compared to traditional OCR?*
     - *A: freeOCR.me utilizes deep-learning vision models that perform Document Layout Analysis (DLA) before character recognition...* (with an inline text link: *[Read our technical comparison →](/kb/ai-vs-traditional-ocr)*).
3. **Eye-Catching Landing Page Announcement Ribbon (`src/frontend/lib/widgets/announcement_banner.dart`):**
   - Implement an industry-standard (Stripe/Linear style) prominent announcement card positioned prominently above the main dropzone/hero.
   - **Color Palette & Contrast:** Deep luminous warm amber/orange gradient (`#FF6B00` to `#EA580C` or `#D97706` amber) with dark obsidian / crisp white typography and subtle border glow.
   - **Pill Badge:** `⚡ HIGH-FIDELITY UPGRADE` or `✨ ENGINE UPDATE 2.4`
   - **Headline:** *Next-Gen PDF Composition: Near-Lossless Layout Fidelity*
   - **Body Copy:** *"Our neural PDF reconstruction engine has been overhauled to regenerate exact visual replicas of your input scans. Experience pixel-accurate layout preservation, pristine typography, and flawless multi-column reading order in every searchable PDF."*
   - **CTA Action:** Deep link button `[Read Technical Deep-Dive →]` navigating directly to `/kb/ai-vs-traditional-ocr`.
   - **Dismissible:** Users can dismiss the ribbon per session via an animated close icon.

### D. Static HTML Pre-Rendering & Schema.org JSON-LD (`scripts/build_seo_pages.py`)
1. Create source markdown file at `docs/blog/ai-vs-traditional-ocr.md`.
2. Update `scripts/build_seo_pages.py` to compile `docs/blog/ai-vs-traditional-ocr.md` into static HTML at `src/frontend/build/web/kb/ai-vs-traditional-ocr/index.html` (or `ai-vs-traditional-ocr.html`).
3. Inject structured JSON-LD `TechArticle` schema:
   ```json
   {
     "@context": "https://schema.org",
     "@type": "TechArticle",
     "headline": "Why Deep-Learning AI OCR Outperforms Classical OCR on Complex Document Layouts",
     "description": "An engineering comparison between classical heuristic OCR and Vision-Language Transformer OCR on multi-column layouts, tables, and historical scans.",
     "author": {
       "@type": "Organization",
       "name": "freeOCR.me Engineering Team"
     },
     "publisher": {
       "@type": "Organization",
       "name": "freeOCR.me",
       "url": "https://freeocr.me"
     },
     "datePublished": "2026-09-15",
     "dateModified": "2026-09-15",
     "mainEntityOfPage": "https://freeocr.me/kb/ai-vs-traditional-ocr"
   }
   ```
4. This ensures AdSense bots (`Mediapartners-Google`) crawling via raw HTTP GET receive 100% complete semantic HTML text immediately without executing Flutter's WASM/JS engine.

### E. Sitemap & Robots Indexation
1. Update `src/frontend/web/sitemap.xml`:
   ```xml
   <url>
     <loc>https://freeocr.me/kb/ai-vs-traditional-ocr</loc>
     <changefreq>weekly</changefreq>
     <priority>0.9</priority>
   </url>
   ```
2. Verify `src/frontend/web/robots.txt` permits crawling `/kb/` and references `https://freeocr.me/sitemap.xml`.

---

## 5. TDD Test Plan (Write First!)

### Frontend Widget Tests (`src/frontend/test/pages/kb_page_ai_article_test.dart`):
1. `test_kb_page_loads_ai_vs_traditional_article_by_slug()`:
   - Pumps `KbPage(initialArticleSlug: 'ai-vs-traditional-ocr')`.
   - Asserts headline *"Why Deep-Learning AI OCR Outperforms Classical OCR"* is visible.
   - Asserts comparison table and technical headings are present.
2. `test_app_footer_contains_ai_ocr_link()`:
   - Asserts `AppFooter` renders a clickable link pointing to `/kb/ai-vs-traditional-ocr`.
3. `test_faq_section_contains_layout_question_and_link()`:
   - Asserts `LandingFaqSection` includes the new FAQ item with route navigation.

### Backend / SEO Tests (`src/tests/test_seo_article_ai_ocr.py`):
1. `test_sitemap_contains_ai_ocr_article()`:
   - Parses `src/frontend/web/sitemap.xml`.
   - Asserts `https://freeocr.me/kb/ai-vs-traditional-ocr` is present with priority `>= 0.8`.
2. `test_markdown_seo_compiler_generates_valid_html()`:
   - Executes `python scripts/build_seo_pages.py`.
   - Validates generated HTML contains valid `<h1>`, `<h2>`, JSON-LD schema, and meta description.

---

## 6. Execution Commands

```powershell
# 1. Run Flutter Widget Tests
cd src/frontend
flutter test test/pages/kb_page_ai_article_test.dart

# 2. Run Backend SEO Tests
$env:PYTHONPATH="src/backend;."
pytest src/tests/test_seo_article_ai_ocr.py -v

# 3. Build Static SEO Pages
python scripts/build_seo_pages.py
```

---

## 7. Definition of Done (DoD)
- [ ] Feature branch `feature/UC-035-adsense-article` created from `dev`.
- [ ] 1,800+ word original technical article published in Flutter `KbPage`.
- [ ] Internal links added to `AppFooter`, `LandingFaqSection`, and `AppHeader`.
- [ ] Pre-rendered static HTML with JSON-LD `TechArticle` generated for search crawlers.
- [ ] `src/frontend/web/sitemap.xml` updated and validated.
- [ ] 100% of automated tests passing locally (both Flutter and Pytest).
- [ ] All trackers updated.
