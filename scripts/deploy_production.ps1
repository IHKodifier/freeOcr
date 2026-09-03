# freeOCR.me Production Deployment Orchestration Script (PowerShell)
# Usage: .\scripts\deploy_production.ps1 [-ProjectId <GCP_PROJECT_ID>] [-DeployBackend] [-DeployFrontend]

param(
    [string]$ProjectId = "freeocr-prod",
    [switch]$DeployBackend,
    [switch]$DeployFrontend
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  freeOCR.me Production Deployment Pipeline" -ForegroundColor Green
Write-Host "  Target Launch: Monday, September 7, 2026" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
Set-Location $RootDir

# If neither switch specified, deploy both
if (-not $DeployBackend -and -not $DeployFrontend) {
    $DeployBackend = $true
    $DeployFrontend = $true
}

# 1. Compile Frontend Web Release & Static SEO Pages
if ($DeployFrontend) {
    Write-Host "`n[STEP 1/3] Building Flutter Web Release Distribution..." -ForegroundColor Cyan
    Set-Location "$RootDir\src\frontend"
    flutter build web --release --no-wasm-dry-run

    Write-Host "[STEP 2/3] Compiling Markdown Documentation into Static SEO HTML..." -ForegroundColor Cyan
    Set-Location $RootDir
    python scripts/build_seo_pages.py

    Write-Host "[STEP 3/3] Deploying to Firebase Hosting CDN..." -ForegroundColor Cyan
    if (Get-Command firebase -ErrorAction SilentlyContinue) {
        firebase deploy --only hosting
        Write-Host ">> Frontend successfully deployed to Firebase Hosting!" -ForegroundColor Green
    } else {
        Write-Host "[NOTICE] 'firebase' CLI not found. Run 'firebase deploy --only hosting' once logged in." -ForegroundColor Yellow
    }
}

# 2. Deploy Backend Container to GCP Cloud Run
if ($DeployBackend) {
    Write-Host "`n[GCP BACKEND] Submitting container build to Google Cloud Artifact Registry..." -ForegroundColor Cyan
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
        gcloud builds submit "$RootDir\src\backend" --tag "gcr.io/$ProjectId/freeocr-backend:latest"
        
        Write-Host "[GCP BACKEND] Deploying to Cloud Run (min-instances=0, scale-to-zero)..." -ForegroundColor Cyan
        gcloud run deploy freeocr-api `
            --image "gcr.io/$ProjectId/freeocr-backend:latest" `
            --region us-central1 `
            --platform managed `
            --min-instances 0 `
            --max-instances 5 `
            --memory 2Gi `
            --cpu 2 `
            --allow-unauthenticated `
            --set-env-vars "ENVIRONMENT=production"
            
        Write-Host ">> Backend successfully deployed to GCP Cloud Run!" -ForegroundColor Green
    } else {
        Write-Host "[NOTICE] 'gcloud' CLI not found. Configure Google Cloud SDK to deploy backend image." -ForegroundColor Yellow
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Deployment pipeline checks completed!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
