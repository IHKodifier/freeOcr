# TASK DISPATCH: Implement UC-000c (GitHub Actions CI/CD & Graphify MCP Integration)

> **Ticket:** `UC-000c`  
> **Sprint:** `Sprint 00` (Foundation & Environment Setup)  
> **Target File:** `dispatch-prompts/sprints/stage-01/sprint-00/UC-000c-dispatch.md`  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** All automated tests in `src/tests/` and `src/frontend/test/` MUST pass 100% green before proposing branch merge.
4. **Branching:** Work on feature branch `sprint/sprint-00-uc-000c` checked out from `dev`. NEVER push directly to `main`.

---

## 2. Master Product Spec Reference
- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-000c

**Ticket ID:** UC-000c  
**Name:** GitHub Actions CI/CD Pipeline & Graphify MCP Integration  
**Epic:** Epic 0 (Project Infrastructure & Environment Foundation)  
**Actor:** CI/CD Automation Runner / AI Agent  
**Trigger:** Pull Request opened or pushed into `dev` branch.  

### Preconditions
- [ ] Monorepo structure initialized (`src/backend`, `src/frontend`, `src/tests`).
- [ ] `UC-000a` and `UC-000b` completed and merged into `dev`.
- [ ] Active branch set to `dev` or dedicated feature branch `sprint/sprint-00-uc-000c`.

### Main Implementation Steps

1. **GitHub Actions Workflow (`.github/workflows/ci.yml`):**
   - Create `.github/workflows/ci.yml` with triggers on `push` to `dev` and `pull_request` targeting `dev`.
   - **Job 1: `backend-tests`**:
     - Runs on `ubuntu-latest`.
     - Sets up Python 3.13.
     - Installs dependencies from `src/backend/requirements.txt`.
     - Executes `pytest src/tests/ -v`.
   - **Job 2: `frontend-tests`**:
     - Runs on `ubuntu-latest`.
     - Sets up Java 17 and Flutter SDK (`subosito/flutter-action`).
     - Executes `cd src/frontend && flutter pub get && flutter test`.

2. **Graphify MCP Knowledge Graph Initialization:**
   - Create/update `.graphify` knowledge graph configuration or documentation to track symbol relationships across backend and frontend modules.

3. **Hierarchical Tracker Maintenance:**
   - Update Sprint 0 tracker (`07.01.00-tracker.md`), Stage tracker (`07.01-tracker.md`), and Master tracker (`master-tracker.md`) marking `UC-000c` as **Completed** (3/3 Completed, 100% Sprint 0 complete!).
   - Populate Handoff Log for Sprint 0 and prepare End-of-Sprint Handoff Prompt (`handoff-sprint-00-to-01.md`).

---

## 4. Acceptance Criteria (EARS Testable)

- WHEN a PR is opened targeting `dev` THE SYSTEM SHALL execute `.github/workflows/ci.yml` verifying backend pytest and frontend flutter test.
- WHEN all Sprint 0 tickets (`UC-000a`, `UC-000b`, `UC-000c`) pass 100% THE SYSTEM SHALL update backlog trackers to 100% Sprint 0 completion.

---

## 5. Definition of Done Checklist for Agent

- [ ] Feature branch `sprint/sprint-00-uc-000c` checked out from `dev`.
- [ ] `.github/workflows/ci.yml` created and validated.
- [ ] Backend tests (`pytest src/tests/ -v`) pass 100% green.
- [ ] Frontend tests (`cd src/frontend; flutter test`) pass 100% green.
- [ ] Graphify MCP knowledge graph initialized.
- [ ] Backlog trackers updated to 100% Sprint 0 completion.
- [ ] End-of-Sprint Handoff prompt created in `handoff-prompts/sprints/stage-01/handoff-sprint-00-to-01.md`.
- [ ] Final report provided.
