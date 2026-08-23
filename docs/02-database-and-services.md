# Database & Infrastructure Services Guide: freeOCR.me

This guide covers local Redis state caching, SQLite `dev.db` database migrations, and RAM disk storage configuration.

---

## 1. Overview of Data Layers

- **MVP Transient Layer (Redis 7):** Used for job progress states, IP rate-limiting counters, and stackable rewarded ad session tokens.
- **Local Dev Database (SQLite `dev.db`):** Used during development for testing post-MVP ORM schemas (`users`, `subscription_tiers`, `saved_documents`).
- **RAM Disk Ephemeral Storage (`tmpfs` / `/tmp`):** In-memory folder where uploaded PDFs and generated OCR outputs live temporarily until purged.

---

## 2. Redis Setup & Commands

### Running Redis Locally
- **Option A (Native Windows Redis / Memurai):** Ensure Redis is running on `127.0.0.1:6379`.
- **Option B (Docker):**
  ```powershell
  docker run -d --name freeocr-redis -p 6379:6379 redis:7-alpine
  ```

### Inspecting Redis Keys
```powershell
# Open redis-cli
redis-cli

# Check active ad pass keys
KEYS ad_pass:*

# Check active rate limit keys
KEYS rate_limit:*
```

---

## 3. Database Management (Post-MVP Preview)

### SQLite `dev.db` & Alembic Migrations
When database persistence is enabled:
```powershell
# Apply database migrations
cd src/backend
alembic upgrade head

# Generate a new migration schema script
alembic revision --autogenerate -m "describe schema change"
```
