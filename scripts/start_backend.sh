#!/usr/bin/env bash
# freeOCR.me Backend Local Start Script (Bash)
echo "=================================================="
echo " Starting freeOCR.me FastAPI Backend Service..."
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR" || exit 1

if [ -d "$ROOT_DIR/.venv/bin" ]; then
    echo "[INFO] Activating virtual environment (.venv)..."
    source "$ROOT_DIR/.venv/bin/activate"
elif [ -d "$ROOT_DIR/.venv/Scripts" ]; then
    echo "[INFO] Activating virtual environment (.venv)..."
    source "$ROOT_DIR/.venv/Scripts/activate"
fi

echo "[INFO] Launching Uvicorn on http://127.0.0.1:8000"
echo "[INFO] Swagger Docs: http://127.0.0.1:8000/docs"
echo "[INFO] Health Probe: http://127.0.0.1:8000/api/v1/health"
python3 -m uvicorn src.backend.app.main:app --host 127.0.0.1 --port 8000 --reload
