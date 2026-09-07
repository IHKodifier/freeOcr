# Dispatch Prompt: Deploy Baidu Unlimited OCR Model on GCP Cloud Run GPU

> **Task ID:** `PROD-01-GPU-OCR`  
> **Target Branch:** `main` (or active feature branch)  
> **Target Environment:** GCP Project `freeocr-staging-app` / `freeocr-prod`  
> **Engine:** Baidu Unlimited OCR / PaddleOCR Vision-Language Model (~6 GB) on NVIDIA L4 GPU with `--min-instances 0` (Scale-to-Zero)

---

## Instructions for Agent:

You are tasked with deploying the **Baidu Unlimited OCR AI Model** on GCP Cloud Run GPU for the **freeOCR.me** platform.

### Context:
1. The web application is live at `https://freeocr.me`.
2. Simple document layouts are processed on CPU using `OCRmyPDF`/Tesseract in <1.5 seconds.
3. Complex layouts (multi-column documents, math formulas, dense tables) are routed via `src/backend/app/services/layout_analyzer.py` to the Baidu Unlimited OCR AI engine.
4. Scale-to-zero is mandatory (`--min-instances 0`) so that GPU compute costs are $0.00 when the queue is idle.

### Execution Steps:
1. **Create GPU Dockerfile (`src/backend/Dockerfile.gpu`):**
   - Base: `nvidia/cuda:12.2.0-runtime-ubuntu22.04` with Python 3.11.
   - Install `paddlepaddle-gpu==2.6.2`, `paddleocr>=2.8.0`, `pymupdf>=1.24.0`, `fastapi`, and `uvicorn`.
   - Setup non-root execution (`USER appuser`).
2. **Implement Standalone GPU Service (`src/backend/app/services/baidu_gpu_service.py`):**
   - Expose `POST /ocr/complex-page` accepting 300 DPI page image bytes.
   - Run PaddleOCR inference and return bounding polygons `[[x0,y0], [x1,y1], [x2,y2], [x3,y3]]` and text strings.
   - Expose `GET /health` verifying GPU initialization.
3. **Build & Deploy to Cloud Run GPU:**
   ```powershell
   gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com
   gcloud builds submit src/backend --config cloudbuild-gpu.yaml
   gcloud beta run deploy freeocr-gpu-worker `
     --image us-central1-docker.pkg.dev/freeocr-staging-app/freeocr/gpu-worker:latest `
     --gpu 1 --gpu-type nvidia-l4 `
     --cpu 4 --memory 16Gi `
     --min-instances 0 `
     --max-instances 3 `
     --timeout 300 `
     --region us-central1 `
     --no-cpu-throttling
   ```
4. **Wire Endpoint in `ocr_worker.py`:**
   - Update `ocr_worker.py` to call the `freeocr-gpu-worker` URL for complex pages.
   - Verify invisible text overlay (`render_mode=3`) in `pdf_composer.py`.
5. **Run Automated Test Suite:**
   ```powershell
   $env:PYTHONPATH="src/backend;src/backend/app;."; .\.venv\Scripts\pytest src/tests/test_complex_pdf_reconstruction.py -v
   ```

Do not commit or push to remote without explicit user authorization.
