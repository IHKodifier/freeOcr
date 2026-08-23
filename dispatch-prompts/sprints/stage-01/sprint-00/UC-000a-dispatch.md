# TASK DISPATCH: Implement UC-000a (Monorepo Project Structure & Dependency Initialization)

> **Ticket:** `UC-000a`  
> **Sprint:** `Sprint 00` (Foundation & Environment Setup)  
> **Target File:** `dispatch-prompts/sprints/stage-01/sprint-00/UC-000a-dispatch.md`  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **TDD Mandate:** You MUST write failing automated unit/integration test files in `./src/tests/` BEFORE writing implementation code.
3. **Branch Protection:** Work on branch `dev` or `sprint/sprint-00`. NEVER push directly to `main`.
4. **Environment:** Python 3.13.5 + FastAPI backend (`./src/backend`); Flutter Web frontend (`./src/frontend`).

---

## 2. Master Product Spec Reference
- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Data Model: [`product-specs/06-data-model.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06-data-model.md)
- Style Guide: [`product-specs/05-style-guide.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/05-style-guide.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-000a

**Ticket ID:** UC-000a  
**Name:** Monorepo Project Structure & Dependency Initialization  
**Epic:** Epic 0 (Project Infrastructure & Environment Foundation)  
**Actor:** Lead Engineer / Developer  
**Trigger:** Initial project bootstrapping.  

### Preconditions
- [ ] Git repository initialized on branch `dev`.
- [ ] Python 3.13.5 installed locally; Flutter SDK installed.

### Main Implementation Steps
1. **Directory Layout:** Create monorepo folders: `./src/frontend` (Flutter), `./src/backend` (FastAPI), `./src/tests` (Unit/Integration).
2. **Backend Dependencies:** Create `./src/backend/pyproject.toml` or `requirements.txt` with dependencies: `fastapi`, `uvicorn`, `redis`, `sqlalchemy`, `alembic`, `pymupdf`, `pytest`, `celery`.
3. **Frontend Project:** Initialize `./src/frontend` Flutter Web project using `flutter create --platforms web ./src/frontend`.
4. **Design Tokens:** Configure Flutter Material 3 `ColorScheme` theme tokens in `./src/frontend/lib/theme/app_theme.dart` matching `product-specs/05-style-guide.md` (`primary`: Electric Indigo `#4F46E5`, `secondary`: Cyber Blue `#3B82F6`, `surface`: Slate `#F8FAFC`/`#0F172A`).
5. **Test Harness:** Create initial test file `./src/tests/test_health.py` containing a passing baseline test.

### Acceptance Criteria (EARS Testable)
- WHEN running `cd src/frontend; flutter analyze` THE SYSTEM SHALL exit with 0 errors.
- WHEN running `pytest src/tests/` THE SYSTEM SHALL discover and execute the test suite successfully.

---

## 4. Definition of Done Checklist for Agent
- [ ] `./src/frontend`, `./src/backend`, and `./src/tests` folders created.
- [ ] Python 3.13.5 dependencies configured in `./src/backend/pyproject.toml` or `requirements.txt`.
- [ ] Flutter Web project initialized in `./src/frontend` with Material 3 tokens.
- [ ] `pytest src/tests/` runs clean and green.
- [ ] Graphify MCP knowledge graph updated with new symbols.
- [ ] Final output report provided summarizing created files and test results.
