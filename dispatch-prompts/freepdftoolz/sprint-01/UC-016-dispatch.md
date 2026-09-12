# TASK DISPATCH: Implement UC-016 (Multi-Tool Routing Hub & Host-Aware Navigation Shell)

> **Ticket:** `UC-016`  
> **Sprint:** `Sprint F1` (FreePDFToolz Foundation & Page Operations)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint-01/UC-016-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint-01/UC-016-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **TDD Mandate (Rule 4):** Automated tests in `src/tests/` and `src/frontend/test/` MUST be written and fail BEFORE writing implementation logic.
4. **Branching Protocol:** Work strictly on feature branch `freepdftoolz/UC-016-routing-hub` checked out from `dev`. NEVER push directly to `main`.
5. **Local-First & Zero-Cloud (Rule 3):** No external paid cloud dependencies.

---

## 2. Master Product Spec Reference
- Master Spec: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Backlog: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md#uc-016-multi-tool-routing-hub--host-aware-navigation-shell)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-016

**Ticket ID:** UC-016  
**Name:** Multi-Tool Routing Hub & Host-Aware Navigation Shell  
**Epic:** Epic 6 (FreePDFToolz Core Foundation & Page Operations)  
**Actor:** Anonymous Web Visitor / Flutter Web Shell / FastAPI Gateway  
**Trigger:** Visitor navigates to `https://freeocr.me`, `https://freepdftoolz.me`, or direct tool route (e.g. `/merge`).  

### Preconditions
- [x] Staging release v1.0.0 completed on `dev`.
- [ ] Active branch set to `freepdftoolz/UC-016-routing-hub` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-016-routing-hub
  ```

---

### Main Implementation Steps

#### Step 1: Host Resolver & Route Architecture (`src/frontend/lib/`)
1. Create `src/frontend/lib/services/host_resolver.dart`:
   - Inspect `Uri.base.host`.
   - Method `bool isFreeOcrDomain()`: returns true if host contains `freeocr.me` or `ocr.localhost`.
   - Method `bool isFreePdfToolsDomain()`: returns true if host contains `freepdftoolz.me` or default.
   - Provides initial route resolution: if host is `freeocr.me` and path is `/`, defaults to OCR tool; if host is `freepdftoolz.me`, defaults to Tools Hub.
2. Update `src/frontend/lib/main.dart`:
   - Register route generators / named routes for:
     - `/` (Dynamic host root)
     - `/hub` (Explicit FreePDFToolz Hub)
     - `/ocr` (Free OCR tool - existing OCR flow)
     - `/merge`, `/split`, `/rotate`, `/delete-pages`, `/extract-pages`, `/number-pages` (Page Ops)
     - `/compress`, `/watermark`, `/crop`, `/redact`, `/sign` (Security & Transformation)
     - `/annotate`, `/edit-text`, `/pdf-to-word`, `/summarize` (AI & Conversions)
     - `/kb`, `/kb/pdf-tools`, `/privacy`, `/terms` (Content & Compliance)

#### Step 2: Responsive FreePDFToolz Hub View (`src/frontend/lib/pages/pdf_tools_hub_page.dart`)
1. Build `PdfToolsHubPage`:
   - Hero header with vibrant typography, search filter field, and category filter chips (`All`, `Page Ops`, `Security & Privacy`, `AI & Conversions`).
   - Responsive Grid View of all 15 tools + Free OCR.
   - Each `ToolCard` widget displays:
     - Custom Material icon or graphic with curated theme colors.
     - Title (e.g., "Merge PDF", "Compress PDF", "Summarize PDF").
     - Badge (e.g., "POPULAR", "AI", "NEW").
     - 1-line description.
     - Hover animation with elevation lift and subtle glow.
     - Direct tap navigation to the tool route.

#### Step 3: Global Navigation Bar & Tools Dropdown (`src/frontend/lib/widgets/app_header.dart`)
1. Enhance header with:
   - Dynamic branding: "FreePDFToolz" on `freepdftoolz.me`, "freeOCR.me" on `freeocr.me`.
   - "Tools" dropdown button allowing 1-click switching to any tool without returning home.
   - Dark mode toggle, KB link, Privacy/Security badge.

#### Step 4: Backend Tool Registry Endpoint (`src/backend/app/api/v1/endpoints/tools_info.py`)
1. Implement `GET /api/v1/tools`:
   - Returns JSON list of all available tools, endpoints, supported formats, and limit specs (100MB free, 1GB boosted).
2. Register router in `src/backend/app/main.py`.

---

## 4. TDD Test Plan (Write First!)

### Backend Unit Tests (`src/tests/unit/test_tools_info.py`):
1. `test_get_tools_info_returns_200_and_catalog()`:
   - Assert `GET /api/v1/tools` returns HTTP 200 with list containing `merge`, `split`, `ocr`, `compress`, `summarize`, etc.
   - Assert each tool contains `id`, `name`, `route`, `max_free_mb` (100).

### Frontend Widget Tests (`src/frontend/test/pages/pdf_tools_hub_page_test.dart`):
1. `test_host_resolver_detects_freeocr_vs_freepdftoolz()`:
   - Unit test `HostResolver` with mocked `Uri.base`.
2. `test_hub_page_renders_all_tool_cards()`:
   - Render `PdfToolsHubPage`, verify at least 15 tool cards are present.
3. `test_hub_search_filter()`:
   - Enter "merge" into search field, verify only Merge card is visible.
4. `test_tool_card_click_navigates_to_route()`:
   - Tap "Merge PDF", verify navigator pushes `/merge`.

---

## 5. Acceptance Criteria (EARS Testable)

- **WHEN** visitor lands on root domain `freeocr.me` **THE SYSTEM SHALL** render the OCR tool directly.
- **WHEN** visitor lands on root domain `freepdftoolz.me` **THE SYSTEM SHALL** render the responsive multi-tool hub grid.
- **WHEN** visitor navigates to `/merge` or any direct tool route **THE SYSTEM SHALL** render the specific tool page on both domains.
- **WHEN** visitor searches for a tool in the hub search box **THE SYSTEM SHALL** filter tool cards in real time.
- **WHEN** client requests `GET /api/v1/tools` **THE SYSTEM SHALL** return HTTP 200 with complete tool catalog metadata.

---

## 6. Verification Commands

```bash
# 1. Run backend tests
pytest src/tests/ -v

# 2. Run frontend tests
cd src/frontend && flutter test

# 3. Analyze Flutter code
cd src/frontend && flutter analyze
```

---

## 7. Tracker Maintenance Gate

Once 100% of tests pass:
1. Update `trackers/master-tracker.md`: Mark `UC-016` as **Completed** (PASS).
2. Stop and notify user with summary. Await user instructions for `git commit`.
