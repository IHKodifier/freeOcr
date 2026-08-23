# Engineering Charter: freeOCR.me

> **Stage:** ★ Engineering Charter Interlude  
> **Persona:** Founding Engineer  
> **Approved:** [x] approved  
> **Reads from:** [`01b-tech-stack.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01b-tech-stack.md), [`06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md), [`07-roadmap.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/07-roadmap.md)  
> **Canonical Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  
> **Last Updated:** 2026-08-23  

---

## 1. Project Commands

```powershell
# Run Backend Locally (FastAPI + Python 3.13.5 + SQLite dev.db + Redis)
.\scripts\start_backend.ps1

# Run Backend Automated Tests (Pytest)
pytest src/tests/ -v

# Run Frontend Web Client (Flutter Web)
cd src/frontend; flutter run -d chrome

# Run Frontend Tests (Flutter Test)
cd src/frontend; flutter test

# Update Graphify MCP Knowledge Graph
# (Executes incremental graph sync to maintain symbol relationships)
```

---

## 2. Governance Boundaries

| Always | Ask First | Never |
|:---|:---|:---|
| **Must write automated tests BEFORE writing implementation code (TDD)** | Adding new core dependencies | Commit or push directly to `main` |
| Work exactly one ticket (`UC-XXX`) at a time | Changing API schemas or data models | Commit `.env` secrets or API credentials |
| Purge temp input files immediately from RAM disk post-conversion | Spinning up paid cloud resources | Delete or weaken failing tests to force a pass |
| Update `trackers/` status upon ticket completion | Modifying core architectural patterns | Start a ticket whose `Depends on` is not Done |
| Update Graphify MCP knowledge graph incrementally | Adding external cloud integrations | Leave input PDF bytes in persistent storage |

---

## 3. Git Branch Protection & Workflow

- **`main` (Production):** Protected release branch. NEVER commit or push code directly to `main`.
- **`dev` (Staging):** Protected staging branch. All feature work branches off `dev`.
- **Sprint Branches:** Work takes place on `sprint/sprint-XX` or `feature/UC-XXX` checked out from `dev`.
- **PR Merge Gate:** 100% of automated unit/integration tests must pass locally before merging into `dev`.
- **Commit Format:** `feat(UC-XXX): brief description` or `fix(UC-XXX): brief description`.

---

## 4. TDD & API-First Mandate

- **Test-First Development:** Automated test files (`src/tests/unit/` and `src/tests/integration/`) MUST be created first to test new functionality BEFORE writing application code.
- **1:1 Acceptance Criteria Mapping:** Every testable acceptance criterion in `06a-use-case-tickets.md` must have a corresponding automated test assertion.
- **100% API Decoupling:** The Flutter frontend must NEVER query databases or file systems directly; all interactions route through FastAPI endpoints governed by schemas.

---

## 5. Working a Ticket Protocol

1. Read the ticket's full specification in [`06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md).
2. Create failing unit/integration tests in `./src/tests/` that validate every acceptance criterion.
3. Write implementation code until all tests pass cleanly (`pytest` & `flutter test`).
4. Update the ticket status from `Not Started` to `Done` in `trackers/` and update overall completion percentage.
5. Update Graphify MCP knowledge graph to preserve codebase relationship context.
├── dispatch-prompts/              # Saved zero-context ticket dispatch prompts
│   └── sprints/
│       └── stage-01/              # Per-sprint ticket prompts (UC-000a-dispatch.md...)
├── handoff-prompts/               # Stage & Sprint handoff prompts upon completion of all sprint tickets.
6. Generate sprint handoff prompt upon completion of all sprint tickets.
