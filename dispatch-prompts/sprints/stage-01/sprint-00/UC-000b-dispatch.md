# TASK DISPATCH: Implement UC-000b (Local Development Pipeline, Redis & Dev Database Setup)

> **Ticket:** `UC-000b`  
> **Sprint:** `Sprint 00` (Foundation & Environment Setup)  
> **Target File:** `dispatch-prompts/sprints/stage-01/sprint-00/UC-000b-dispatch.md`  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **freeOCR.me**. Before writing ANY code or running tools:
1. **Read Canonical Governance Rules:** Read [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md) using `view_file`.
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction. All commits stay local and require explicit user staging/approval.
3. **TDD Mandate:** You MUST write failing automated unit/integration test files in `./src/tests/` BEFORE writing implementation code.
4. **Branching:** Work on a feature branch `sprint/sprint-00-uc-000b` checked out from `dev`. NEVER push directly to `main`.
5. **Environment:** Python 3.13.5 + FastAPI backend (`./src/backend`); SQLite `dev.db` + Redis `redis://localhost:6379/0`.

---

## 2. Master Product Spec Reference
- Master PRD: [`product-specs/08-master-prd.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/08-master-prd.md)
- Use Case Tickets: [`product-specs/06a-use-case-tickets.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06a-use-case-tickets.md)
- Architecture Spec: [`product-specs/02-architecture.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/02-architecture.md)
- Data Model: [`product-specs/06-data-model.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/06-data-model.md)
- Master Tracker: [`trackers/master-tracker.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/trackers/master-tracker.md)

---

## 3. Ticket Specification — UC-000b

**Ticket ID:** UC-000b  
**Name:** Local Development Pipeline, Redis & Dev Database Setup  
**Epic:** Epic 0 (Project Infrastructure & Environment Foundation)  
**Actor:** Lead Engineer / Developer  
**Trigger:** Running local development environment and verifying service pipeline.  

### Preconditions
- [ ] Monorepo structure initialized (`src/backend`, `src/frontend`, `src/tests`).
- [ ] Active branch set to `dev` or dedicated feature branch `sprint/sprint-00-uc-000b`.

### Main Implementation Steps

1. **Python Environment Setup (`.venv`):**
   - Create Python 3.13 virtual environment `.venv` at project root if missing (`python -m venv .venv`).
   - Install/verify requirements from `src/backend/requirements.txt` into `.venv` (`pip install -r src/backend/requirements.txt`).

2. **Environment & App Settings (`src/backend/app/config.py`):**
   - Create `.env.example` with default settings (`DATABASE_URL=sqlite:///./dev.db`, `REDIS_URL=redis://localhost:6379/0`, `ENVIRONMENT=development`).
   - Implement Pydantic `BaseSettings` in `src/backend/app/config.py` to load environment configuration safely with fallback defaults.

3. **Database Migration Pipeline (Alembic & SQLite):**
   - Initialize Alembic configuration inside `src/backend/alembic/` for SQLite `dev.db` schema migrations.
   - Configure `env.py` to read `DATABASE_URL` from `config.py`.

4. **Health Check Endpoint (`GET /healthz`):**
   - Implement `GET /healthz` in `src/backend/app/main.py` that verifies:
     a) SQLite Database connection ping.
     b) Redis cache server connection ping.
   - Returns HTTP 200 `{"status": "healthy", "database": "connected", "redis": "connected"}` or HTTP 503 if a dependency is unreachable.

5. **Test-Driven Development (TDD):**
   - Write failing automated test cases in `src/tests/test_database.py` and `src/tests/test_redis.py` **before** writing endpoint implementation code.

---

## 4. Acceptance Criteria (EARS Testable)

- WHEN running `python -m pytest src/tests/ -v` inside `.venv` THE SYSTEM SHALL pass 100% of test assertions.
- WHEN querying `GET /healthz` with database and Redis active THE SYSTEM SHALL return HTTP 200 `{"status": "healthy"}`.
- WHEN `.env` variables are missing THE SYSTEM SHALL fall back safely to SQLite `dev.db` defaults.

---

## 5. Definition of Done Checklist for Agent

- [ ] Python virtual environment `.venv` created and dependencies installed (`pip install -r src/backend/requirements.txt`).
- [ ] `.env.example` created and `src/backend/app/config.py` implemented via Pydantic `BaseSettings`.
- [ ] Alembic initialized inside `src/backend/alembic/` for `dev.db` migrations.
- [ ] `GET /healthz` endpoint implemented with Redis & DB pings.
- [ ] Automated tests in `src/tests/` pass 100% green (`pytest src/tests/ -v`).
- [ ] Sprint trackers updated (`07.01.00-tracker.md`, `07.01-tracker.md`, `master-tracker.md`).
- [ ] NO unprompted git commits or remote pushes executed.
- [ ] Final handoff report provided summarizing test results and created files.
