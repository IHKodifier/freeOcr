# TASK DISPATCH: Implement UC-033 (FreePDFToolz GCP Cloud Run Zero-Scale Deployment, Custom Domain SSL & Live Launch)

> **Ticket:** `UC-033`  
> **Sprint:** `Sprint F3` (FreePDFToolz AI, Conversions & AdSense Launch)  
> **Target File:** [`dispatch-prompts/freepdftoolz/sprint 03/UC-033-dispatch.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/dispatch-prompts/freepdftoolz/sprint%2003/UC-033-dispatch.md)  
> **Governance Target:** [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)  

---

## 1. Governance & Rule Preconditions

You are an AI coding assistant working on **FreePDFToolz.me & freeOCR.me**. Before writing ANY code or executing tools:
1. **Read Canonical Governance Rules:** Review [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md).
2. **Strict Authorization Protocol (Rule 2.1):** You MUST NOT run `git commit` or `git push` without explicit user instruction.
3. **Interactive Dual-Domain Deployment Protocol (Rule 2.2):** All production/staging merges and pushes must be explicitly approved via interactive selection `[deploy:freepdftoolz]`.
4. **Zero-Scaling & Cost Protection Mandate (Rule 3):** Backend GCP Cloud Run instances MUST scale to 0 when idle (`--min-instances 0`, `--max-instances 5`). Zero idle billing.
5. **Domain Protection:** `https://freepdftoolz.me` is dedicated exclusively to the PDF tools suite. Zero cross-contamination with `freeocr.me` AdSense review.

---

## 2. Ticket Specification — UC-033

**Ticket ID:** UC-033  
**Name:** FreePDFToolz GCP Cloud Run Zero-Scale Deployment, Custom Domain SSL & Live Launch  
**Epic:** Epic 8 (FreePDFToolz Infrastructure, Custom Domain & Public Launch)  
**Actor:** DevOps / Full-Stack Engineer  
**Trigger:** FreePDFToolz ready for staging & live production rollout to `https://freepdftoolz.me`.  

### Preconditions
- [x] Domain `freepdftoolz.me` purchased and DNS managed (Cloudflare / Registrar).
- [x] Sprint F1 & F2 completed and merged into `dev`.
- [ ] Active branch set to `freepdftoolz/UC-033-live-deploy` checked out from `dev`:
  ```bash
  git checkout dev
  git checkout -b freepdftoolz/UC-033-live-deploy
  ```
- [x] Google Cloud SDK (`gcloud`) and Firebase CLI installed.

---

## 3. Main Implementation Steps

#### Step 1: Provision Dedicated Zero-Scaling GCP Project
1. Configure / verify dedicated GCP project for FreePDFToolz (`freepdftoolz-prod` / `freepdftoolz-staging`):
   - Enable Cloud Run API (`run.googleapis.com`), Cloud Build API (`cloudbuild.googleapis.com`), and Container Registry / Artifact Registry.
   - Create Service Account `freepdftoolz-deployer` with roles:
     - `roles/run.admin`
     - `roles/storage.admin`
     - `roles/cloudbuild.builds.editor`
     - `roles/iam.serviceAccountUser`
   - Generate Service Account JSON Key and add to GitHub Secrets as `GCP_SA_KEY_PDFTOOLZ`.

#### Step 2: Backend Cloud Run Zero-Scale Service Configuration
1. Deploy `freepdftoolz-api` service via `gcloud run deploy`:
   - Image: `gcr.io/${GCP_PROJECT}/freepdftoolz-backend:latest`
   - Flags:
     - `--min-instances 0` (Zero instances when idle, zero compute costs!)
     - `--max-instances 5` (Cost spike cap)
     - `--memory 2Gi`, `--cpu 2`
     - `--timeout 300`
     - `--allow-unauthenticated`
     - `--region us-central1`
     - `--update-env-vars "ENVIRONMENT=production,API_BASE_URL=https://freepdftoolz.me"`
2. Verify Health Probe:
   - `GET https://freepdftoolz-api-xxxx.a.run.app/api/v1/health` returns `{"status": "healthy"}`.

#### Step 3: Firebase Hosting Custom Domain & SSL Mapping
1. Initialize Firebase Hosting site `freepdftoolz` in Firebase project:
   - `firebase hosting:sites:create freepdftoolz`
2. Connect custom domain `freepdftoolz.me` and `www.freepdftoolz.me`:
   - Retrieve custom domain DNS A / CNAME records from Firebase Console.
   - Configure DNS records on domain registrar:
     - `A @ 199.36.158.100` (or Firebase designated IPs)
     - `CNAME www freepdftoolz.web.app.`
   - Verify Google-managed SSL certificate auto-provisioning (TLS 1.3).
3. Update `firebase.json` rewrites:
   - Route `/api/**` to Cloud Run service `freepdftoolz-api`.
   - Route all single-page app routes `**` to `/index.html`.

#### Step 4: GitHub Actions GitOps Pipeline Verification
1. Verify `.github/workflows/deploy.yml`:
   - Commit message with `[deploy:freepdftoolz]` or `[deploy:both]` automatically compiles Flutter Web release bundle, submits backend Docker container, deploys Cloud Run, and deploys Firebase Hosting.
2. Execute live smoke test against `https://freepdftoolz.me`:
   - Health check probe.
   - 1-click test of `/merge`, `/compress`, and `/sign`.

---

## 4. TDD & Automated Verification Plan

### Automated Deployment Tests (`src/tests/test_deployment_freepdftoolz.py`):
1. `test_cloud_run_configuration_scale_to_zero()`: Validates Cloud Run template specifies `autoscaling.knative.dev/minScale: "0"`.
2. `test_firebase_hosting_rewrites_config()`: Validates `firebase.json` properly maps API routes to `freepdftoolz-api` and frontend SPA routes.
3. `test_health_probe_live_endpoint()`: Smoke test asserting `GET /api/v1/health` returns HTTP 200 and healthy status.
4. `test_cors_headers_match_freepdftoolz_domain()`: Verifies backend allows CORS origins for `https://freepdftoolz.me`.

---

## 5. Definition of Done (DoD)
- [ ] Dedicated GCP project initialized with scale-to-zero Cloud Run backend service.
- [ ] Custom domain `https://freepdftoolz.me` live with automatic TLS 1.3 SSL certificate.
- [ ] Firebase Hosting serving Flutter Web frontend with pre-rendered SEO pages.
- [ ] Reverse proxy rewrites routing `/api/v1/*` seamlessly to backend Cloud Run.
- [ ] Zero idle billing confirmed (Cloud Run scales to 0 instances when idle).
- [ ] 100% automated deployment tests pass locally and in CI/CD pipeline.
