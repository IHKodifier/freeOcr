# TASK DISPATCH: Implement UC-032 (Original Educational SEO Content Hub & AdSense Indexation)

> **Ticket:** `UC-032`  
> **Sprint:** `Sprint F3` (FreePDFToolz AI, Conversions & AdSense Launch)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 03/UC-032-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2003/UC-032-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated verification tests MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-032-seo-content` checked out from `dev`. NEVER push directly to `main`.
5. **AdSense Compliance:** Adhere strictly to Google AdSense Site Quality Guidelines (original high-value content, clear navigation, privacy policy, contact details, zero scraper content).

---

## 2. Ticket Specification — UC-032

**Ticket ID:** UC-032  
**Name:** Original Educational SEO Content Hub & AdSense Indexation  
**Epic:** Epic 8 (FreePDFToolz AI, Conversions & AdSense Launch)  
**Actor:** Search Engine Bots (Googlebot, Bingbot) / Web Visitors  
**Trigger:** Search bot or visitor requests tool pages or `/sitemap.xml` on `freepdftoolz.me`.  

### Preconditions
- [x] All 15 FreePDFToolz utilities implemented and registered.
- [ ] Active branch set to `freepdftoolz/UC-032-seo-content` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-032-seo-content
  ```

---

### Main Implementation Steps

#### Step 1: Pre-rendered Static SEO Generation (`scripts/build_seo_pages.py`)
1. Enhance static SEO generator for `freepdftoolz.me`:
   - Generate static HTML pre-rendered landing pages for all 15 FreePDFToolz tools:
     - `/merge`, `/split`, `/rotate`, `/delete-pages`, `/extract-pages`, `/number-pages`
     - `/compress`, `/watermark`, `/crop`, `/redact`, `/sign`
     - `/annotate`, `/edit-text`, `/pdf-to-word`
     - `/about`, `/contact`, `/privacy`, `/terms`
   - Inject schema.org structured data:
     - `SoftwareApplication` markup (ApplicationCategory: `UtilityApplication`, OperatingSystem: `All`).
     - `FAQPage` rich snippet markup matching each tool's interactive FAQ accordion.
   - Inject canonical URL tags pointing to `https://freepdftoolz.me/<tool>`.
2. Generate dynamic XML Sitemaps:
   - `sitemap.xml` listing all valid tool URLs with priority `0.9`, weekly change frequency, and current lastmod timestamp.
   - `robots.txt` allowing crawler access and pointing to `https://freepdftoolz.me/sitemap.xml`.

#### Step 2: Knowledge Base & Guides Integration (`src/frontend/`)
1. Create FreePDFToolz documentation and guides hub (`/docs` and `/kb`):
   - Comprehensive technical guides explaining PDF compression algorithms, PDF/A preservation, cryptographic redaction security, and electronic signature legal compliance.
2. Verify host-aware domain switching:
   - On `freepdftoolz.me`, footer and header point to FreePDFToolz documentation, legal policies, and brand assets.

---

## 3. TDD Test Plan (Write First!)

### Automated SEO Tests (`src/tests/test_seo_pages.py`):
1. `test_seo_generator_produces_all_15_tool_pages()`: Asserts 15 static HTML files generated in output directory.
2. `test_seo_pages_contain_valid_json_ld_schema()`: Validates schema.org JSON-LD parses as valid JSON with `@type: "SoftwareApplication"` and `"FAQPage"`.
3. `test_sitemap_xml_valid_format()`: Asserts `sitemap.xml` contains all tool URLs with proper `<url><loc>` XML tags.
4. `test_robots_txt_points_to_sitemap()`: Verifies `robots.txt` references `freepdftoolz.me/sitemap.xml`.

---

## 4. Verification Commands
```powershell
# 1. Run SEO Pytest Suite
$env:PYTHONPATH="src/backend;."
C:\python31315\python.exe -m pytest src/tests/test_seo_pages.py -v

# 2. Verify Static Generator Execution
C:\python31315\python.exe scripts/build_seo_pages.py
```
