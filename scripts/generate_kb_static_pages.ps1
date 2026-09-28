# generate_kb_static_pages.ps1 — Delegates to generate_kb_static_pages.py to ensure 100% data consistency
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
$PyScript = Join-Path $ScriptDir "generate_kb_static_pages.py"
$HubScript = Join-Path $ScriptDir "generate_kb_index_hub.py"

$pythonExe = "python"
if (Test-Path "$RootDir\.venv\Scripts\python.exe") {
    $pythonExe = "$RootDir\.venv\Scripts\python.exe"
}

Write-Host "Executing $PyScript via $pythonExe..." -ForegroundColor Cyan
& $pythonExe $PyScript
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Executing $HubScript via $pythonExe..." -ForegroundColor Cyan
& $pythonExe $HubScript
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
