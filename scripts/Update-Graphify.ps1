# Update-Graphify.ps1 — Helper script to run fast local-first Graphify updates
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
$ScriptPath = Join-Path $ScriptDir "update_graphify.py"

Write-Host "Running Graphify Knowledge Graph Update..." -ForegroundColor Cyan
& "C:\python31315\python.exe" $ScriptPath
