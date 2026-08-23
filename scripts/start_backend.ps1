# freeOCR.me Backend Local Start Script (PowerShell)
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Starting freeOCR.me FastAPI Backend Service..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
Set-Location $RootDir

# Activate virtual environment if present
if (Test-Path "$RootDir\.venv\Scripts\Activate.ps1") {
    Write-Host "[INFO] Activating virtual environment (.venv)..." -ForegroundColor Yellow
    . "$RootDir\.venv\Scripts\Activate.ps1"
}

# Start uvicorn
Write-Host "[INFO] Launching Uvicorn on http://127.0.0.1:8000" -ForegroundColor Green
Write-Host "[INFO] Swagger Docs: http://127.0.0.1:8000/docs" -ForegroundColor Cyan
Write-Host "[INFO] Health Probe: http://127.0.0.1:8000/api/v1/health" -ForegroundColor Cyan
python -m uvicorn src.backend.app.main:app --host 127.0.0.1 --port 8000 --reload
