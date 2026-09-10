# Dispatch Prompt: Deploy Baidu Unlimited OCR Model on GCP Cloud Run GPU

> **Task ID:** `PROD-01-GPU-OCR`  
> **Base Branch:** `dev`  
> **Dedicated Feature Branch:** `feature/PROD-01-gpu-worker` (checked out from `dev`)  
> **Target Environment:** GCP Project `freeocr-staging-app` (Region: `us-central1`)  
> **Engine:** Baidu Unlimited OCR / PaddleOCR Vision-Language Model (~6 GB) on NVIDIA L4 GPU with `--min-instances 0` (Scale-to-Zero)

---

## 1. Instructions for Agent

You are tasked with deploying the **Baidu Unlimited OCR AI Model** on GCP Cloud Run GPU for the **freeOCR.me** platform.

### Git Branching Mandate:
Before modifying or creating any code, you MUST checkout a dedicated feature branch from `dev`:
```powershell
git checkout dev
git pull origin dev
git checkout -b feature/PROD-01-gpu-worker
```
- NEVER commit directly to `main` or `dev`.
- Follow strict commit protocol: no unprompted commits or remote pushes without explicit user instruction.

### Context:
1. The web application is live at `https://freeocr.me`.
2. Simple document layouts are processed on CPU using `OCRmyPDF`/Tesseract in <1.5 seconds.
3. Complex layouts (multi-column documents, math formulas, dense tables) are routed via `src/backend/app/services/layout_analyzer.py` to the Baidu Unlimited OCR AI engine.
4. Scale-to-zero is mandatory (`--min-instances 0`) so that GPU compute costs remain **$0.00 when the queue is idle**.

---

## 2. Technical Requirements & Architecture

1. **Standalone Microservice (`freeocr-gpu-worker`):**
   - Keeps the main `freeocr-api` lightweight, responsive, and instant-starting.
   - Only boots the NVIDIA L4 GPU container when complex layout documents enter the conversion queue.
2. **Pre-baked Model Weights (Critical Cold-Start Optimization):**
   - PaddleOCR model weights must be pre-downloaded during Docker image build.
   - Avoids 2–4 minute download delays and timeouts during runtime cold boots.
3. **Resilient CPU Fallback:**
   - If the GPU worker is cold-starting, experiences a timeout (>15s), or encounters any network error, `ocr_worker.py` must automatically and silently fall back to CPU `OCRmyPDF`/Tesseract.
   - Zero conversion requests must ever fail or hang.
4. **Internal Endpoint Security:**
   - Protect the GPU endpoint from public abuse using an internal shared secret header (`X-Internal-Secret: ...`) or Cloud IAM service account tokens.

---

## 3. Step-by-Step Execution Plan

### Step 0: Git Branch Isolation
Checkout dedicated branch from `dev`:
```powershell
git checkout dev
git pull origin dev
git checkout -b feature/PROD-01-gpu-worker
```

### Step 1: Create Artifact Registry Repository (if not already present)
```powershell
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project freeocr-staging-app
gcloud artifacts repositories create freeocr --repository-format=docker --location=us-central1 --description="freeOCR Docker Repository" --project freeocr-staging-app 2>$null
```

### Step 2: Create GPU Dockerfile (`src/backend/Dockerfile.gpu`)
- Base Image: `nvidia/cuda:12.2.0-runtime-ubuntu22.04` with Python 3.11.
- Install dependencies: `paddlepaddle-gpu==2.6.2`, `paddleocr>=2.8.0`, `pymupdf>=1.24.0`, `fastapi`, `uvicorn`, `httpx`.
- Pre-bake weights: Run a build-time pre-warm command:
  ```dockerfile
  RUN python3 -c "from paddleocr import PaddleOCR; PaddleOCR(use_angle_cls=True, lang='en', use_gpu=False)"
  ```
- Configure non-root execution (`USER appuser`).

### Step 3: Implement Standalone GPU Service (`src/backend/app/services/baidu_gpu_service.py`)
- Expose `GET /health` verifying GPU readiness.
- Expose `POST /ocr/complex-page` accepting:
  - Input: 300 DPI page image bytes or Base64 payload.
  - Verification: Validate `X-Internal-Secret` against `INTERNAL_SECRET` env var.
  - Output: JSON list of bounding polygons `[[x0,y0], [x1,y1], [x2,y2], [x3,y3]]`, recognized text strings, and confidence scores.

### Step 4: Build & Deploy to Cloud Run GPU
1. **Submit Cloud Build:**
   ```powershell
   gcloud builds submit src/backend `
     --tag us-central1-docker.pkg.dev/freeocr-staging-app/freeocr/gpu-worker:latest `
     --project freeocr-staging-app `
     --timeout=1800s
   ```
2. **Deploy Service:**
   ```powershell
   gcloud run deploy freeocr-gpu-worker `
     --image us-central1-docker.pkg.dev/freeocr-staging-app/freeocr/gpu-worker:latest `
     --gpu 1 --gpu-type nvidia-l4 `
     --cpu 4 --memory 16Gi `
     --min-instances 0 `
     --max-instances 3 `
     --timeout 300 `
     --region us-central1 `
     --no-cpu-throttling `
     --set-env-vars "INTERNAL_SECRET=FREEOCR_INTERNAL_SECRET_KEY" `
     --allow-unauthenticated `
     --project freeocr-staging-app
   ```

### Step 5: Wire GPU Worker & Resilient Fallback in `ocr_worker.py`
1. Read `BAIDU_GPU_WORKER_URL` and `INTERNAL_SECRET` from environment.
2. In `ocr_worker.py`, when `layout_analyzer.py` classifies a page as `complex`:
   - Attempt HTTP POST to `${BAIDU_GPU_WORKER_URL}/ocr/complex-page`.
   - On success: synthesize dual-layer searchable PDF overlay (`render_mode=3` in `pdf_composer.py`).
   - On exception/timeout: log warning and immediately fall back to local CPU `OCRmyPDF`/Tesseract engine.
3. Update `freeocr-api` Cloud Run service with environment variables:
   ```powershell
   gcloud run services update freeocr-api `
     --region us-central1 `
     --project freeocr-staging-app `
     --update-env-vars "BAIDU_GPU_WORKER_URL=https://[GPU_SERVICE_URL],INTERNAL_SECRET=FREEOCR_INTERNAL_SECRET_KEY"
   ```

### Step 6: Automated Verification & Test Suite
```powershell
$env:PYTHONPATH="src/backend;src/backend/app;."
.\.venv\Scripts\pytest src/tests/test_complex_pdf_reconstruction.py -v
```

---

## 4. Definition of Done (DoD)
- [x] Dedicated feature branch `feature/PROD-01-gpu-worker` checked out from `dev`.
- [ ] `freeocr-gpu-worker` deployed on Cloud Run GPU (NVIDIA L4, `--min-instances 0`, `--no-cpu-throttling`) *(Pending GCP GPU Quota)*.
- [ ] Scale-to-zero operational ($0.00 cost when idle) *(Pending GCP GPU Quota)*.
- [x] Model weights pre-baked into image definition (`Dockerfile.gpu` & `cloudbuild-gpu.yaml`).
- [x] `ocr_worker.py` successfully queries GPU worker for complex layouts.
- [x] Resilient CPU fallback handles cold-boot delays or GPU timeouts gracefully with zero failed jobs.
- [x] 100% of automated tests pass locally (92/92 passed).
- [x] No unprompted commits or remote pushes without explicit user instruction.
