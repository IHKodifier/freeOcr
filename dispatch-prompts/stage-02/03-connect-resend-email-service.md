# Dispatch Prompt: Connect & Configure Resend Email Service for freeOCR.me

> **Task ID:** `PROD-02-RESEND-EMAIL`  
> **Target Branch:** `main`  
> **Target Environment:** GCP Cloud Run (`freeocr-api`) & Local `.env`  
> **Service Provider:** Resend Email API (`https://api.resend.com/emails`)

---

## 1. Overview & Objective

Configure and activate transactional email delivery for **freeOCR.me** using the Resend API. When a conversion completes, users can optionally enter their email to receive 24-hour expiring download links (`.pdf`, `.txt`, `.md`) directly to their inbox with zero persistent storage of the document or email address.

---

## 2. Technical Context & Existing Code

1. **Email Service Implementation:**
   The backend already contains an active Resend delivery client in [`src/backend/app/services/email_service.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/email_service.py).
2. **Delivery Heuristics:**
   - If `RESEND_API_KEY` is present in environment variables, `send_download_links_email()` dispatches via HTTP POST to `https://api.resend.com/emails` with a clean HTML email template.
   - If `RESEND_API_KEY` is missing, the service falls back to local `MOCK_DEV` mode (logging link delivery to server stdout).
3. **Download Base URL:**
   Links in the email are generated using `API_BASE_URL`. On production, this must resolve to `https://freeocr.me` (which Cloud Run routes via Firebase Hosting `/api/**` rewrites).

---

## 3. Required Environment Variables

| Variable | Description | Production Value | Development / Fallback |
|:---|:---|:---|:---|
| `RESEND_API_KEY` | Resend secret API key (`re_...`) | User-provided key | Empty (runs in mock mode) |
| `RESEND_FROM_EMAIL` | Verified sender email address | `delivery@freeocr.me` or `onboarding@resend.dev` | `onboarding@resend.dev` |
| `API_BASE_URL` | Canonical URL prefix for download links | `https://freeocr.me` | `http://127.0.0.1:8000` |

---

## 4. Step-by-Step Execution Plan

### Step 1: Obtain / Configure Resend API Key
- User creates an account or retrieves an API key from [Resend Dashboard](https://resend.com/api-keys).
- (Optional for custom domain) Add DNS TXT/MX records to verify `freeocr.me` in Resend Domains to allow sending from `noreply@freeocr.me` or `delivery@freeocr.me`. For rapid MVP testing, `onboarding@resend.dev` (delivering to user's registered Resend account email) can be used.

### Step 2: Inject Environment Variables into Live Cloud Run Service
Execute via `gcloud`:
```powershell
gcloud run services update freeocr-api `
  --region us-central1 `
  --project freeocr-staging-app `
  --update-env-vars "RESEND_API_KEY=YOUR_KEY_HERE,RESEND_FROM_EMAIL=delivery@freeocr.me,API_BASE_URL=https://freeocr.me"
```

### Step 3: Update Local `.env` Template
Ensure `src/backend/.env.example` documents all three variables clearly.

### Step 4: Verification & Automated Tests
1. **Run Unit & Integration Tests:**
   ```powershell
   $env:PYTHONPATH="src/backend;src/backend/app;."
   pytest src/tests/ -k "email" -v
   ```
2. **Execute Live Verification Curl:**
   Submit a test conversion or directly test the email endpoint:
   ```powershell
   curl.exe -X POST "https://freeocr.me/api/v1/jobs/test-job-id/send-email" `
     -H "Content-Type: application/json" `
     -d '{"email": "user@example.com"}'
   ```
   Verify HTTP 200 response indicating `email_sent: true`.

---

## 5. Definition of Done (DoD)
- [ ] `RESEND_API_KEY`, `RESEND_FROM_EMAIL`, and `API_BASE_URL` are injected into Cloud Run (`freeocr-api`).
- [ ] Live email dispatch returns HTTP 200 with delivery mode `RESEND_API`.
- [ ] Download links inside received email point to `https://freeocr.me/api/v1/jobs/{job_id}/download/...`.
- [ ] All automated tests pass locally.
- [ ] Original files remain zero-retention / ephemeral (RAM disk unlinked).
