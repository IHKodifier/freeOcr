# scripts/build_freepdftoolz_site.ps1
# FreePDFToolz Dedicated Web Distribution Builder
# Copies Flutter compiled bundle and overlays FreePDFToolz editorial shell and subpages.

[CmdletBinding()]
param(
    [string]$RootDir = ""
)

if (-not $RootDir) {
    $RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " FreePDFToolz Web Distribution Assembly Pipeline " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

$FlutterBuildDir = Join-Path $RootDir "src/frontend/build/web"
$PdfToolzSourceDir = Join-Path $RootDir "src/frontend/web_pdftoolz"
$TargetDir = Join-Path $RootDir "src/frontend/build/freepdftoolz_web"

Write-Host "[1/5] Checking Flutter build output directory: $FlutterBuildDir" -ForegroundColor Yellow
if (-not (Test-Path $FlutterBuildDir)) {
    Write-Host "[WARN] Flutter build output not found at $FlutterBuildDir." -ForegroundColor Yellow
    Write-Host "[INFO] Creating placeholder directory structure..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $FlutterBuildDir | Out-Null
}

Write-Host "[2/5] Initializing target distribution directory: $TargetDir" -ForegroundColor Yellow
if (Test-Path $TargetDir) {
    Remove-Item -Recurse -Force $TargetDir
}
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

Write-Host "[3/5] Mirroring compiled Flutter artifacts..." -ForegroundColor Yellow
if (Test-Path $FlutterBuildDir) {
    Get-ChildItem -Path $FlutterBuildDir | Copy-Item -Destination $TargetDir -Recurse -Force
}

Write-Host "[4/5] Regenerating latest FreePDFToolz pages if generator present..." -ForegroundColor Yellow
$GeneratorScript = Join-Path $RootDir "scripts/generate_freepdftoolz_pages.py"
if (Test-Path $GeneratorScript) {
    $PyExe = Join-Path $RootDir ".venv/Scripts/python.exe"
    if (Test-Path $PyExe) {
        & $PyExe $GeneratorScript
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 $GeneratorScript
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        python $GeneratorScript
    } elseif (Get-Command py -ErrorAction SilentlyContinue) {
        py -3 $GeneratorScript
    }
}

Write-Host "[5/5] Overlaying FreePDFToolz editorial shell, subpages, and whitepapers..." -ForegroundColor Yellow
if (Test-Path $PdfToolzSourceDir) {
    Get-ChildItem -Path $PdfToolzSourceDir | Copy-Item -Destination $TargetDir -Recurse -Force
} else {
    Write-Error "Error: Source directory $PdfToolzSourceDir not found!"
    exit 1
}

# Verify critical files
$CriticalFiles = @(
    "index.html",
    "about/index.html",
    "contact/index.html",
    "privacy/index.html",
    "terms/index.html",
    "hub/index.html",
    "sitemap.xml",
    "robots.txt"
)

$MissingFiles = 0
foreach ($RelPath in $CriticalFiles) {
    $FullPath = Join-Path $TargetDir $RelPath
    if (-not (Test-Path $FullPath)) {
        Write-Host "[ERROR] Missing critical file: $RelPath" -ForegroundColor Red
        $MissingFiles++
    }
}

if ($MissingFiles -gt 0) {
    Write-Error "FreePDFToolz distribution assembly failed: $MissingFiles files missing."
    exit 1
}

$TotalFiles = (Get-ChildItem -Recurse -File $TargetDir).Count
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] FreePDFToolz site successfully assembled with $TotalFiles files at:" -ForegroundColor Green
Write-Host "          $TargetDir" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
