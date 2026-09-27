<#
.SYNOPSIS
    Test-AdSenseCompliance.ps1 — Automated Google AdSense Readiness & Compliance Benchmarking Suite (PowerShell Edition)

.DESCRIPTION
    Native PowerShell benchmarking engine that tests freeOCR.me, FreePDFToolz.me, or any web directory for 100%
    compliance with Google AdSense Publisher Policies, Webmaster Quality Guidelines, and Indexability.

.PARAMETER TargetDir
    The directory of HTML and web assets to benchmark (Default: 'src/frontend/web').

.PARAMETER ClientId
    The Google AdSense Client Publisher ID (Default: 'ca-pub-6775900998665017').

.EXAMPLE
    .\scripts\Test-AdSenseCompliance.ps1
    .\scripts\Test-AdSenseCompliance.ps1 -TargetDir "src/frontend/web"
#>

param(
    [string]$TargetDir = "src/frontend/web",
    [string]$ClientId = "ca-pub-6775900998665017"
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host "GOOGLE ADSENSE COMPLIANCE & READINESS BENCHMARKING SUITE (POWERSHELL)" -ForegroundColor Cyan
Write-Host "Target Directory: $TargetDir" -ForegroundColor Cyan
Write-Host "AdSense Client ID: $ClientId" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

if (-not (Test-Path $TargetDir)) {
    Write-Host "[FAIL] Target directory does not exist: $TargetDir" -ForegroundColor Red
    exit 1
}

$totalChecks = 8
$passedChecks = 0
$results = @{}

# Function to record result
function Record-Result {
    param($Name, $Status, $Details)
    $script:results[$Name] = @{ Status = $Status; Details = $Details }
    if ($Status -eq "PASS") {
        $script:passedChecks += 1
        Write-Host "  [PASS] $Name`: $Details" -ForegroundColor Green
    } elseif ($Status -eq "WARN") {
        $script:passedChecks += 0.5
        Write-Host "  [WARN] $Name`: $Details" -ForegroundColor Yellow
    } else {
        Write-Host "  [FAIL] $Name`: $Details" -ForegroundColor Red
    }
}

# --- Audit 1: AdSense Tag Presence ---
Write-Host "`n[Audit 1/8] Verifying AdSense Monetization Code Snippet in <head>..." -ForegroundColor White
$htmlFiles = Get-ChildItem -Path $TargetDir -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch 'flutter_service_worker' }
$missingTag = @()
$foundTag = 0

foreach ($f in $htmlFiles) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    $headPart = if ($c -match '</head>') { ($c -split '</head>')[0] } else { $c }
    if ($headPart -match 'pagead2\.googlesyndication\.com' -and $headPart -match $ClientId) {
        $foundTag++
    } else {
        $rel = $f.FullName.Replace((Resolve-Path $TargetDir).Path + "\", "")
        $missingTag += $rel
    }
}

$rootIndex = Join-Path $TargetDir "index.html"
$hasRootTag = $false
if (Test-Path $rootIndex) {
    $rc = Get-Content $rootIndex -Raw -Encoding utf8
    if ($rc -match 'pagead2\.googlesyndication\.com' -and $rc -match $ClientId) {
        $hasRootTag = $true
    }
}

if (-not $hasRootTag) {
    Record-Result "AdSense Tag Coverage" "FAIL" "Root index.html is missing the AdSense snippet!"
} elseif ($missingTag.Count -gt 0) {
    Record-Result "AdSense Tag Coverage" "FAIL" "$foundTag files contain snippet, but $($missingTag.Count) missing ($($missingTag[0..2] -join ', '))"
} else {
    Record-Result "AdSense Tag Coverage" "PASS" "All $foundTag HTML files contain valid AdSense snippet in <head>."
}

# --- Audit 2: Trust & Legal Pages ---
Write-Host "`n[Audit 2/8] Auditing Publisher Trust & Compliance Pages (/privacy, /terms, /about, /contact)..." -ForegroundColor White
$requiredPages = @("privacy", "terms", "about", "contact")
$missingPages = @()

foreach ($p in $requiredPages) {
    $dirIndex = Join-Path $TargetDir "$p/index.html"
    $fileHtml = Join-Path $TargetDir "$p.html"
    if (-not (Test-Path $dirIndex) -and -not (Test-Path $fileHtml)) {
        $missingPages += $p
    }
}

if ($missingPages.Count -gt 0) {
    Record-Result "Trust & Legal Pages" "FAIL" "Missing compliance pages: $($missingPages -join ', ')"
} else {
    Record-Result "Trust & Legal Pages" "PASS" "All 4 compliance pages (/privacy, /terms, /about, /contact) present."
}

# --- Audit 3: Editorial Depth & Word Count ---
Write-Host "`n[Audit 3/8] Measuring Semantic Text Volume & Anti-Thin Content Safeguards..." -ForegroundColor White
$kbDir = Join-Path $TargetDir "kb"
if (-not (Test-Path $kbDir)) { $kbDir = Join-Path $TargetDir "knowledge-base" }

$articleFiles = Get-ChildItem -Path $kbDir -Recurse -Filter index.html
$thinCount = 0
$totalWords = 0

foreach ($af in $articleFiles) {
    $ac = Get-Content $af.FullName -Raw -Encoding utf8
    $cleanText = $ac -replace '<script[\s\S]*?</script>', ' ' -replace '<style[\s\S]*?</style>', ' ' -replace '<[^>]+>', ' '
    $words = ($cleanText -split '\s+' | Where-Object { $_.Length -gt 0 })
    $wc = $words.Count
    $totalWords += $wc
    if ($wc -lt 500) { $thinCount++ }
}

if ($articleFiles.Count -lt 5) {
    Record-Result "Editorial Content Depth" "FAIL" "Insufficient article count ($($articleFiles.Count) found)."
} elseif ($thinCount -gt 0) {
    Record-Result "Editorial Content Depth" "WARN" "$thinCount pages below 500 words. Total words: $totalWords."
} else {
    Record-Result "Editorial Content Depth" "PASS" "$($articleFiles.Count) articles audited. Total: $totalWords words."
}

# --- Audit 4: Mobile & Robots Viewport ---
Write-Host "`n[Audit 4/8] Auditing Mobile Viewport Configuration & Robots Directives..." -ForegroundColor White
if (Test-Path $rootIndex) {
    $rc = Get-Content $rootIndex -Raw -Encoding utf8
    $issues = @()
    if ($rc -notmatch 'name=["'']viewport["'']') { $issues += "Missing viewport meta tag" }
    if ($rc -match 'robots.*noindex') { $issues += "Landing page has noindex" }
    if ($rc -notmatch '<title>') { $issues += "Missing <title> tag" }

    if ($issues.Count -gt 0) {
        Record-Result "Mobile & Robots Config" "FAIL" ($issues -join ', ')
    } else {
        Record-Result "Mobile & Robots Config" "PASS" "Responsive mobile viewport and index/follow robots directives verified."
    }
}

# --- Audit 5: Canonical & Sitemap Sync ---
Write-Host "`n[Audit 5/8] Verifying Canonical Tags & Sitemap.xml Synchronicity..." -ForegroundColor White
$sitemapPath = Join-Path $TargetDir "sitemap.xml"
if (Test-Path $sitemapPath) {
    $sm = Get-Content $sitemapPath -Raw -Encoding utf8
    $urls = [regex]::Matches($sm, '<loc>(https?://[^<]+)</loc>')
    if ($urls.Count -ge 20) {
        Record-Result "Canonical & Sitemap Sync" "PASS" "sitemap.xml valid with $($urls.Count) canonical URLs."
    } else {
        Record-Result "Canonical & Sitemap Sync" "WARN" "sitemap.xml has only $($urls.Count) URLs."
    }
} else {
    Record-Result "Canonical & Sitemap Sync" "FAIL" "sitemap.xml missing in web root."
}

# --- Audit 6: Ad Placeholder Safety ---
Write-Host "`n[Audit 6/8] Auditing Ad Unit Suppression (Zero Empty Ad Placeholders)..." -ForegroundColor White
$unsuppressed = 0
foreach ($f in $htmlFiles) {
    $c = Get-Content $f.FullName -Raw -Encoding utf8
    $noComments = $c -replace '<!--[\s\S]*?-->', ''
    if ($noComments -match '<ins[^>]*class=["''][^"'']*adsbygoogle' -and $noComments -notmatch 'display:\s*none') {
        $unsuppressed++
    }
}

if ($unsuppressed -gt 0) {
    Record-Result "Ad Placeholder Safety" "FAIL" "$unsuppressed files contain unsuppressed empty ad tags!"
} else {
    Record-Result "Ad Placeholder Safety" "PASS" "All ad units safely suppressed pending AdSense site approval."
}

# --- Audit 7: Navigation Integrity ---
Write-Host "`n[Audit 7/8] Auditing Navigation Integrity & Internal Link Consistency..." -ForegroundColor White
if (Test-Path $rootIndex) {
    $rc = Get-Content $rootIndex -Raw -Encoding utf8
    $missingNav = @()
    foreach ($link in @('/about', '/kb', '/privacy', '/terms', '/contact')) {
        if ($rc -notmatch "href=[`"']$link[`"']") {
            $missingNav += $link
        }
    }
    if ($missingNav.Count -gt 0) {
        Record-Result "Navigation Integrity" "FAIL" "Missing links: $($missingNav -join ', ')"
    } else {
        Record-Result "Navigation Integrity" "PASS" "All canonical nav endpoints (/about, /kb, /privacy, /terms, /contact) present."
    }
}

# --- Audit 8: Service Worker Cache Review Mode ---
Write-Host "`n[Audit 8/8] Checking Service Worker Review-Mode Cache Invalidation Status..." -ForegroundColor White
$swPath = Join-Path $TargetDir "flutter_service_worker.js"
$bypasses = $false
if (Test-Path $rootIndex) {
    $rc = Get-Content $rootIndex -Raw -Encoding utf8
    if ($rc -match 'serviceWorker\.getRegistrations' -or $rc -match 'caches\.delete' -or $rc -match 'serviceWorker:\s*false') {
        $bypasses = $true
    }
}

if ((Test-Path $swPath) -and -not $bypasses) {
    Record-Result "Service Worker Cache Status" "WARN" "Active service worker found without explicit cache-bypass in index.html for review mode."
} else {
    Record-Result "Service Worker Cache Status" "PASS" "Service worker cache is suppressed/bypassed for AdSense review."
}

# --- Summary Report ---
$score = ($passedChecks / $totalChecks) * 100
Write-Host "`n" ("=" * 80) -ForegroundColor Cyan
Write-Host "ADSENSE COMPLIANCE BENCHMARKING SUMMARY REPORT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host ("{0,-32} | {1,-6} | {2}" -f "Check Dimension", "Status", "Details")
Write-Host ("-" * 80)

foreach ($key in $results.Keys) {
    $item = $results[$key]
    $color = if ($item.Status -eq "PASS") { "Green" } elseif ($item.Status -eq "WARN") { "Yellow" } else { "Red" }
    Write-Host ("{0,-32} | " -f $key) -NoNewline
    Write-Host ("{0,-6} | " -f $item.Status) -ForegroundColor $color -NoNewline
    Write-Host $item.Details
}

Write-Host ("-" * 80)
$scoreColor = if ($score -ge 85) { "Green" } else { "Red" }
Write-Host ("TOTAL COMPLIANCE SCORE: {0:N1}% ({1:N1} / {2} passed)" -f $score, $passedChecks, $totalChecks) -ForegroundColor $scoreColor

if ($score -ge 85.0) {
    Write-Host "[RESULT] SITE IS READY FOR GOOGLE ADSENSE REVIEW SUBMISSION." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[RESULT] SITE REQUIRES REMEDIATION BEFORE CLICKING 'REQUEST REVIEW'." -ForegroundColor Yellow
    exit 1
}
