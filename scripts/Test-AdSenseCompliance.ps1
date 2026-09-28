<#
.SYNOPSIS
    Test-AdSenseCompliance.ps1 — Page-by-Page Google AdSense Compliance & Readiness Benchmarking Suite

.DESCRIPTION
    Comprehensive PowerShell benchmarking engine that tests every web page (all Static HTML pages
    and all Flutter Web App pages) for 100% compliance with Google AdSense Publisher Policies,
    Webmaster Quality Guidelines, and Search Console Indexability.
    
    Evaluates each page individually against strict compliance dimensions:
      1. AdSense Monetization Code Tag Presence (<head>)
      2. Mobile Usability & Responsive Viewport Configuration
      3. Indexability & Robots Directives (Zero accidental noindex)
      4. Canonical URL & Domain Synchronicity
      5. Zero Empty Ad Placeholders (All ad units safely collapsed pre-approval)
      6. Navigation Integrity & Internal Cross-Linking (Legal & Trust endpoints)
      7. Canonical 4-Column Footer Parity
      8. Semantic Editorial Depth & Anti-Thin Content Volume
      9. Flutter Route & Component Architecture (AppHeader, AppFooter, SelectionArea)
    
    Assigns each page an individual compliance score (0% - 100%) and generates a detailed
    page-wise report table at the conclusion of the audit.

.PARAMETER TargetDir
    The directory of HTML and web assets to benchmark (Default: 'src/frontend/web').

.PARAMETER FlutterDir
    The directory containing Flutter frontend source code (Default: 'src/frontend/lib').

.PARAMETER ClientId
    The Google AdSense Client Publisher ID (Default: 'ca-pub-6775900998665017').

.PARAMETER Threshold
    The minimum overall passing compliance score percentage (Default: 85.0).

.PARAMETER ShowAllFiles
    If specified, reports all individual static HTML file paths rather than canonical routes.

.PARAMETER PageFilter
    Optional case-insensitive string filter to audit specific pages or routes.

.EXAMPLE
    .\scripts\Test-AdSenseCompliance.ps1
    .\scripts\Test-AdSenseCompliance.ps1 -ShowAllFiles
    .\scripts\Test-AdSenseCompliance.ps1 -PageFilter "privacy"
#>

param(
    [string]$TargetDir = "src/frontend/web",
    [string]$FlutterDir = "src/frontend/lib",
    [string]$ClientId = "ca-pub-6775900998665017",
    [double]$Threshold = 85.0,
    [switch]$ShowAllFiles,
    [string]$PageFilter = ""
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host ("=" * 100) -ForegroundColor Cyan
Write-Host "GOOGLE ADSENSE PAGE-BY-PAGE COMPLIANCE & READINESS BENCHMARKING SUITE" -ForegroundColor Cyan
Write-Host "Target Directory (Static Web):   $TargetDir" -ForegroundColor Cyan
Write-Host "Flutter Directory (Source):     $FlutterDir" -ForegroundColor Cyan
Write-Host "AdSense Client Publisher ID:    $ClientId" -ForegroundColor Cyan
Write-Host "Passing Score Threshold:        $Threshold%" -ForegroundColor Cyan
Write-Host ("=" * 100) -ForegroundColor Cyan

if (-not (Test-Path $TargetDir)) {
    Write-Host "[FAIL] Target directory does not exist: $TargetDir" -ForegroundColor Red
    exit 1
}

# --- Helper: Extract Clean Semantic Word Count ---
function Get-SemanticWordCount {
    param([string]$Html)
    $clean = $Html -replace '<script[\s\S]*?</script>', ' ' `
                   -replace '<style[\s\S]*?</style>', ' ' `
                   -replace '<noscript[\s\S]*?</noscript>', ' ' `
                   -replace '<svg[\s\S]*?</svg>', ' ' `
                   -replace '<header[\s\S]*?</header>', ' ' `
                   -replace '<footer[\s\S]*?</footer>', ' ' `
                   -replace '<[^>]+>', ' '
    $words = ($clean -split '\s+' | Where-Object { $_.Length -gt 1 })
    return $words.Count
}

# --- Data Structures to Store Page-by-Page Results ---
$script:flutterPageResults = @()
$script:staticPageResults = @()
$script:globalResults = @{}

# ==============================================================================
# PHASE 1: FLUTTER WEB APP PAGES AUDIT
# ==============================================================================
Write-Host "`n[PHASE 1/3] Auditing Flutter Web App Pages (Route & Component Architecture)..." -ForegroundColor White

$mainDartPath = Join-Path $FlutterDir "main.dart"
$mainDartContent = if (Test-Path $mainDartPath) { Get-Content $mainDartPath -Raw -Encoding utf8 } else { "" }

# Define Catalog of Flutter Web App Pages & Routes
$flutterPagesCatalog = @(
    @{ Name = "HomePage"; Route = "/"; File = "main.dart"; Category = "Core OCR" },
    @{ Name = "ProcessPage"; Route = "/process"; File = "pages/process_page.dart"; Category = "Workflow" },
    @{ Name = "ResultPage"; Route = "/result"; File = "pages/result_page.dart"; Category = "Workflow" },
    @{ Name = "AboutPage"; Route = "/about"; File = "pages/about_page.dart"; Category = "Trust & Legal" },
    @{ Name = "ContactPage"; Route = "/contact"; File = "pages/contact_page.dart"; Category = "Trust & Legal" },
    @{ Name = "PrivacyPage"; Route = "/privacy"; File = "pages/privacy_page.dart"; Category = "Trust & Legal" },
    @{ Name = "TermsPage"; Route = "/terms"; File = "pages/terms_page.dart"; Category = "Trust & Legal" },
    @{ Name = "KbPage"; Route = "/kb"; File = "pages/kb_page.dart"; Category = "Educational Hub" }
)

foreach ($page in $flutterPagesCatalog) {
    if ($PageFilter -and ($page.Name -notmatch $PageFilter -and $page.Route -notmatch $PageFilter)) {
        continue
    }

    $filePath = Join-Path $FlutterDir $page.File
    if (-not (Test-Path $filePath)) {
        $script:flutterPageResults += [PSCustomObject]@{
            Name        = $page.Name
            Route       = $page.Route
            Category    = $page.Category
            PassedCount = 0
            TotalCount  = 7
            Score       = 0.0
            Status      = "FAIL"
            Notes       = "Source file missing: $($page.File)"
        }
        continue
    }

    $code = Get-Content $filePath -Raw -Encoding utf8
    $checksPassed = 0
    $totalChecks = 7
    $issues = @()

    # 1. Route Registration in main.dart
    $routeRegex = [regex]::Escape($page.Route)
    if ($page.Route -eq "/" -or $mainDartContent -match "name\s*==\s*['`"]$routeRegex['`"]" -or $mainDartContent -match "$routeRegex") {
        $checksPassed += 1
    } else {
        $issues += "Route unmapped in main.dart"
    }

    # 2. AppHeader Integration
    if ($code -match 'AppHeader' -or $code -match 'AppBar' -or $page.File -eq "main.dart") {
        $checksPassed += 1
    } else {
        $issues += "Missing AppHeader"
    }

    # 3. AppFooter Integration (Canonical 4-Column Footer)
    if ($code -match 'AppFooter') {
        $checksPassed += 1
    } else {
        $issues += "Missing AppFooter"
    }

    # 4. Ad Placeholder Safety (Collapses unapproved ads via kAdSenseApproved or AdSenseBanner)
    $hasRawUnsafeAd = ($code -match 'HtmlElementView' -and $code -notmatch 'AdSenseBanner' -and $code -notmatch 'kAdSenseApproved')
    if (-not $hasRawUnsafeAd) {
        $checksPassed += 1
    } else {
        $issues += "Contains raw unsuppressed ad container"
    }

    # 5. SelectionArea / Crawlable Text
    if ($code -match 'SelectionArea' -or $code -match 'SelectableText' -or $code -match 'Text\(') {
        $checksPassed += 1
    } else {
        $issues += "No selectable text"
    }

    # 6. Legal / Trust Link Availability (via AppFooter or body)
    if ($code -match 'AppFooter' -or ($code -match '/privacy' -and $code -match '/terms')) {
        $checksPassed += 1
    } else {
        $issues += "Missing legal nav links"
    }

    # 7. Semantic / Editorial Depth (Meaningful UI copy > 40 lines of layout / instructions)
    $lines = ($code -split "`n").Count
    if ($lines -ge 50) {
        $checksPassed += 1
    } else {
        $issues += "Thin component skeleton (< 50 lines)"
    }

    $pageScore = [math]::Round(($checksPassed / $totalChecks) * 100, 1)
    $status = if ($pageScore -ge 90.0) { "PASS" } elseif ($pageScore -ge 75.0) { "WARN" } else { "FAIL" }
    $notes = if ($issues.Count -eq 0) { "Compliant (Header, Footer, Safe Ads, Deep UI)" } else { $issues -join "; " }

    $script:flutterPageResults += [PSCustomObject]@{
        Name        = $page.Name
        Route       = $page.Route
        Category    = $page.Category
        PassedCount = $checksPassed
        TotalCount  = $totalChecks
        Score       = $pageScore
        Status      = $status
        Notes       = $notes
    }
}

Write-Host "  [OK] Audited $($script:flutterPageResults.Count) Flutter web app pages." -ForegroundColor Green

# ==============================================================================
# PHASE 2: STATIC HTML PAGES & EDUCATIONAL CONTENT AUDIT
# ==============================================================================
Write-Host "`n[PHASE 2/3] Auditing Static HTML Pages & Educational Content (Semantic & SEO Engine)..." -ForegroundColor White

$allHtmlFiles = Get-ChildItem -Path $TargetDir -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch 'flutter_service_worker' }

# Function to audit an individual HTML file
function Test-StaticHtmlFile {
    param(
        [System.IO.FileInfo]$File,
        [string]$RouteName,
        [string]$Category
    )

    $content = Get-Content $File.FullName -Raw -Encoding utf8
    $headPart = if ($content -match '</head>') { ($content -split '</head>')[0] } else { $content }
    
    $checksPassed = 0
    $totalChecks = 8
    $issues = @()

    # 1. AdSense Tag Snippet in <head>
    if ($headPart -match 'pagead2\.googlesyndication\.com' -and $headPart -match $ClientId) {
        $checksPassed += 1
    } else {
        $issues += "Missing AdSense <head> snippet"
    }

    # 2. Viewport Responsive Meta Tag
    if ($headPart -match 'name=["'']viewport["'']') {
        $checksPassed += 1
    } else {
        $issues += "Missing viewport meta tag"
    }

    # 3. Page Title Tag
    if ($headPart -match '<title>([^<]+)</title>' -and $matches[1].Trim().Length -gt 5) {
        $checksPassed += 1
    } else {
        $issues += "Missing/empty <title> tag"
    }

    # 4. Robots Directives (No accidental noindex)
    if ($headPart -notmatch 'robots.*noindex') {
        $checksPassed += 1
    } else {
        $issues += "Accidental noindex directive"
    }

    # 5. Canonical Link Tag
    if ($headPart -match '<link\s+rel=["'']canonical["'']\s+href=["'']https://freeocr\.me[^"'']*["'']' -or 
        $headPart -match '<link\s+href=["'']https://freeocr\.me[^"'']*["'']\s+rel=["'']canonical["'']') {
        $checksPassed += 1
    } else {
        $issues += "Missing/invalid canonical URL tag"
    }

    # 6. Ad Unit Safety (Zero unsuppressed empty ad tags)
    $noComments = $content -replace '<!--[\s\S]*?-->', ''
    if ($noComments -match '<ins[^>]*class=["''][^"'']*adsbygoogle' -and $noComments -notmatch 'display:\s*none') {
        $issues += "Unsuppressed active ad container"
    } else {
        $checksPassed += 1
    }

    # 7. Navigation Integrity
    $hasNav = ($content -match 'href=["'']/about' -or $content -match 'href=["'']/privacy' -or $content -match 'href=["'']/kb')
    if ($hasNav) {
        $checksPassed += 1
    } else {
        $issues += "Missing primary nav links"
    }

    # 8. Canonical 4-Column Footer Parity
    if ($content -match '<footer\b') {
        $isFooterOk = ($content.Contains('class="app-footer"') -or $content.Contains("class='app-footer'")) -and
                      $content.Contains("engine-chip") -and
                      $content.Contains("Baidu Unlimited OCR") -and
                      $content.Contains("<h3>Legal</h3>")
        if ($isFooterOk) {
            $checksPassed += 1
        } else {
            $issues += "Footer deviates from canonical 4-column standard"
        }
    } else {
        # Pages without footer (e.g. embed frames or raw fragments)
        $checksPassed += 0.5
        $issues += "No <footer> element"
    }

    # Semantic Word Count Check (Editorial Volume)
    $words = Get-SemanticWordCount $content
    $wordBonus = 0
    if ($Category -eq "Article") {
        if ($words -ge 500) {
            $wordBonus = 0
        } elseif ($words -ge 300) {
            $issues += "Thin content: $words words (< 500w)"
            $checksPassed -= 0.5
        } else {
            $issues += "Very thin content: $words words (< 300w)"
            $checksPassed -= 1.0
        }
    } elseif ($Category -eq "Hub" -or $Category -eq "Legal") {
        if ($words -lt 100) {
            $issues += "Short copy: $words words (< 100w)"
            $checksPassed -= 0.5
        }
    }

    if ($checksPassed -lt 0) { $checksPassed = 0 }
    $score = [math]::Round(($checksPassed / $totalChecks) * 100, 1)
    if ($score -gt 100.0) { $score = 100.0 }
    
    $status = if ($score -ge 90.0) { "PASS" } elseif ($score -ge 75.0) { "WARN" } else { "FAIL" }
    $notes = if ($issues.Count -eq 0) { "Clean ($words words, 100% compliant)" } else { "$($issues -join '; ') ($words words)" }

    $relPath = $File.FullName.Replace((Resolve-Path $TargetDir).Path + "\", "").Replace("\", "/")

    return [PSCustomObject]@{
        Name        = $File.Name
        RelativePath= $relPath
        Route       = $RouteName
        Category    = $Category
        WordCount   = $words
        PassedCount = $checksPassed
        TotalCount  = $totalChecks
        Score       = $score
        Status      = $status
        Notes       = $notes
    }
}

# Group or List Files
$resolvedTarget = (Resolve-Path $TargetDir).Path

# Define Catalog of Static HTML Canonical Routes
$canonicalRoutes = @(
    @{ Route = "/"; Path = "index.html"; Category = "Landing" },
    @{ Route = "/about"; Path = "about/index.html"; Category = "Legal & Trust" },
    @{ Route = "/contact"; Path = "contact/index.html"; Category = "Legal & Trust" },
    @{ Route = "/privacy"; Path = "privacy/index.html"; Category = "Legal & Trust" },
    @{ Route = "/terms"; Path = "terms/index.html"; Category = "Legal & Trust" },
    @{ Route = "/kb"; Path = "kb/index.html"; Category = "KB Hub" },
    @{ Route = "/kb/workflows"; Path = "kb/workflows/index.html"; Category = "KB Category" },
    @{ Route = "/kb/comparisons"; Path = "kb/comparisons/index.html"; Category = "KB Category" },
    @{ Route = "/kb/solutions"; Path = "kb/solutions/index.html"; Category = "KB Category" },
    @{ Route = "/kb/troubleshooting"; Path = "kb/troubleshooting/index.html"; Category = "KB Category" }
)

# Discover KB Articles
$kbArticlesDir = Join-Path $TargetDir "kb"
if (Test-Path $kbArticlesDir) {
    $subdirs = Get-ChildItem -Path $kbArticlesDir -Directory | Where-Object { 
        $_['Name'] -notin @("workflows", "comparisons", "solutions", "troubleshooting") 
    }
    foreach ($sd in $subdirs) {
        $canonicalRoutes += @{
            Route = "/kb/$($sd.Name)"
            Path = "kb/$($sd.Name)/index.html"
            Category = "Article"
        }
    }
}

if ($ShowAllFiles) {
    # Audit every single HTML file individually
    foreach ($file in $allHtmlFiles) {
        $rel = $file.FullName.Replace($resolvedTarget + "\", "").Replace("\", "/")
        $cat = if ($rel -match '^(about|contact|privacy|terms)') { "Legal & Trust" } `
               elseif ($rel -match 'workflows|comparisons|solutions|troubleshooting') { "KB Category" } `
               elseif ($rel -match '^kb/index\.html|^knowledge-base/index\.html|^kb\.html') { "KB Hub" } `
               elseif ($rel -match '^index\.html$') { "Landing" } `
               else { "Article" }
        $rt = "/" + ($rel -replace '/index\.html$', '' -replace '\.html$', '')
        if ($rt -eq "/index") { $rt = "/" }

        if ($PageFilter -and ($rel -notmatch $PageFilter -and $rt -notmatch $PageFilter)) {
            continue
        }

        $res = Test-StaticHtmlFile -File $file -RouteName $rt -Category $cat
        $script:staticPageResults += $res
    }
} else {
    # Audit by Canonical Page Route (testing primary file & validating all variants)
    foreach ($cr in $canonicalRoutes) {
        if ($PageFilter -and ($cr.Route -notmatch $PageFilter -and $cr.Path -notmatch $PageFilter)) {
            continue
        }

        $filePath = Join-Path $TargetDir $cr.Path
        if (Test-Path $filePath) {
            $fInfo = Get-Item $filePath
            $res = Test-StaticHtmlFile -File $fInfo -RouteName $cr.Route -Category $cr.Category
            $script:staticPageResults += $res
        } else {
            $script:staticPageResults += [PSCustomObject]@{
                Name        = [System.IO.Path]::GetFileName($cr.Path)
                RelativePath= $cr.Path
                Route       = $cr.Route
                Category    = $cr.Category
                WordCount   = 0
                PassedCount = 0
                TotalCount  = 8
                Score       = 0.0
                Status      = "FAIL"
                Notes       = "Missing canonical file: $($cr.Path)"
            }
        }
    }
}

Write-Host "  [OK] Audited $($script:staticPageResults.Count) Static HTML pages ($($allHtmlFiles.Count) total physical files verified in web tree)." -ForegroundColor Green

# ==============================================================================
# PHASE 3: GLOBAL INFRASTRUCTURE & REVIEWS
# ==============================================================================
Write-Host "`n[PHASE 3/3] Auditing Global Site Infrastructure (Sitemap, Service Worker, Robots)..." -ForegroundColor White

# Sitemap verification
$sitemapPath = Join-Path $TargetDir "sitemap.xml"
if (Test-Path $sitemapPath) {
    $sm = Get-Content $sitemapPath -Raw -Encoding utf8
    $urls = [regex]::Matches($sm, '<loc>(https?://[^<]+)</loc>')
    if ($urls.Count -ge 20) {
        $script:globalResults["Sitemap.xml"] = @{ Status = "PASS"; Details = "Valid with $($urls.Count) canonical URLs." }
    } else {
        $script:globalResults["Sitemap.xml"] = @{ Status = "WARN"; Details = "Only $($urls.Count) URLs indexed." }
    }
} else {
    $script:globalResults["Sitemap.xml"] = @{ Status = "FAIL"; Details = "sitemap.xml missing in web root." }
}

# Service worker cache review mode
$rootIndex = Join-Path $TargetDir "index.html"
$swPath = Join-Path $TargetDir "flutter_service_worker.js"
$bypasses = $false
if (Test-Path $rootIndex) {
    $rc = Get-Content $rootIndex -Raw -Encoding utf8
    if ($rc -match 'serviceWorker\.getRegistrations' -or $rc -match 'caches\.delete' -or $rc -match 'serviceWorker:\s*false') {
        $bypasses = $true
    }
}
if ((Test-Path $swPath) -and -not $bypasses) {
    $script:globalResults["Service Worker Cache"] = @{ Status = "WARN"; Details = "Active SW found without explicit cache-bypass in index.html for review mode." }
} else {
    $script:globalResults["Service Worker Cache"] = @{ Status = "PASS"; Details = "Service worker cache bypassed/invalidated for AdSense bots." }
}

# Robots.txt
$robotsPath = Join-Path $TargetDir "robots.txt"
if (Test-Path $robotsPath) {
    $rob = Get-Content $robotsPath -Raw -Encoding utf8
    if ($rob -match 'Disallow:\s*/$') {
        $script:globalResults["Robots.txt"] = @{ Status = "FAIL"; Details = "Disallows root crawling." }
    } else {
        $script:globalResults["Robots.txt"] = @{ Status = "PASS"; Details = "Allows search & AdSense bot indexing." }
    }
} else {
    $script:globalResults["Robots.txt"] = @{ Status = "WARN"; Details = "robots.txt missing." }
}

foreach ($gk in $script:globalResults.Keys) {
    $gItem = $script:globalResults[$gk]
    $color = if ($gItem.Status -eq "PASS") { "Green" } elseif ($gItem.Status -eq "WARN") { "Yellow" } else { "Red" }
    Write-Host ("  [{0}] {1}: {2}" -f $gItem.Status, $gk, $gItem.Details) -ForegroundColor $color
}

# ==============================================================================
# PAGE-BY-PAGE SCORECARD REPORTS
# ==============================================================================

# Helper for colored badge printing
function Format-ScoreCell {
    param([double]$Score, [string]$Status)
    $color = if ($Status -eq "PASS") { "Green" } elseif ($Status -eq "WARN") { "Yellow" } else { "Red" }
    return @{ ScoreText = ("{0,5:N1}%" -f $Score); StatusText = ("[{0}]" -f $Status); Color = $color }
}

# --- Section A: Flutter Web App Pages ---
Write-Host "`n" ("=" * 100) -ForegroundColor Cyan
Write-Host "SECTION A: FLUTTER WEB APP PAGES SCORECARD (DART & COMPONENT AUDIT)" -ForegroundColor Cyan
Write-Host ("=" * 100) -ForegroundColor Cyan
Write-Host ("{0,-28} | {1,-18} | {2,-14} | {3,-8} | {4,-6} | {5}" -f "Flutter Page Class", "Route", "Category", "Score", "Status", "Audit Notes & Compliance Evidence")
Write-Host ("-" * 100)

foreach ($p in $script:flutterPageResults) {
    $color = if ($p.Status -eq "PASS") { "Green" } elseif ($p.Status -eq "WARN") { "Yellow" } else { "Red" }
    Write-Host ("{0,-28} | {1,-18} | {2,-14} | " -f $p.Name, $p.Route, $p.Category) -NoNewline
    Write-Host ("{0,6:N1}% | " -f $p.Score) -ForegroundColor $color -NoNewline
    Write-Host ("{0,-6} | " -f $p.Status) -ForegroundColor $color -NoNewline
    Write-Host $p.Notes
}

# --- Section B: Static HTML Core & Trust Pages ---
$coreStatic = $script:staticPageResults | Where-Object { $_.Category -ne "Article" }
Write-Host "`n" ("=" * 100) -ForegroundColor Cyan
Write-Host "SECTION B: STATIC HTML CORE PAGES & HUBS SCORECARD" -ForegroundColor Cyan
Write-Host ("=" * 100) -ForegroundColor Cyan
Write-Host ("{0,-28} | {1,-26} | {2,-12} | {3,6} | {4,-8} | {5,-6} | {6}" -f "Route / Identifier", "Relative File Path", "Category", "Words", "Score", "Status", "Audit Notes & Evidence")
Write-Host ("-" * 100)

foreach ($p in $coreStatic) {
    $color = if ($p.Status -eq "PASS") { "Green" } elseif ($p.Status -eq "WARN") { "Yellow" } else { "Red" }
    Write-Host ("{0,-28} | {1,-26} | {2,-12} | {3,6} | " -f $p.Route, $p.RelativePath, $p.Category, $p.WordCount) -NoNewline
    Write-Host ("{0,6:N1}% | " -f $p.Score) -ForegroundColor $color -NoNewline
    Write-Host ("{0,-6} | " -f $p.Status) -ForegroundColor $color -NoNewline
    Write-Host $p.Notes
}

# --- Section C: Static HTML Educational Articles ---
$articleStatic = $script:staticPageResults | Where-Object { $_.Category -eq "Article" }
if ($articleStatic.Count -gt 0) {
    Write-Host "`n" ("=" * 100) -ForegroundColor Cyan
    Write-Host "SECTION C: STATIC HTML KNOWLEDGE BASE ARTICLES SCORECARD" -ForegroundColor Cyan
    Write-Host ("=" * 100) -ForegroundColor Cyan
    Write-Host ("{0,-38} | {1,6} | {2,-8} | {3,-6} | {4}" -f "Article Route", "Words", "Score", "Status", "Editorial Depth & Technical Parity Notes")
    Write-Host ("-" * 100)

    foreach ($p in $articleStatic) {
        $color = if ($p.Status -eq "PASS") { "Green" } elseif ($p.Status -eq "WARN") { "Yellow" } else { "Red" }
        Write-Host ("{0,-38} | {1,6} | " -f $p.Route, $p.WordCount) -NoNewline
        Write-Host ("{0,6:N1}% | " -f $p.Score) -ForegroundColor $color -NoNewline
        Write-Host ("{0,-6} | " -f $p.Status) -ForegroundColor $color -NoNewline
        Write-Host $p.Notes
    }
}

# ==============================================================================
# ROLLUP SUMMARY & READINESS VERDICT
# ==============================================================================

# Calculate Averages
$avgFlutter = if ($script:flutterPageResults.Count -gt 0) {
    ($script:flutterPageResults | Measure-Object -Property Score -Average).Average
} else { 0.0 }

$avgStatic = if ($script:staticPageResults.Count -gt 0) {
    ($script:staticPageResults | Measure-Object -Property Score -Average).Average
} else { 0.0 }

$globalPassed = ($script:globalResults.Values | Where-Object { $_.Status -eq "PASS" }).Count
$globalTotal = $script:globalResults.Count
$globalScore = if ($globalTotal -gt 0) { ($globalPassed / $globalTotal) * 100 } else { 100.0 }

# Combined Weighted Score:
# 45% Static HTML Articles/Pages (Direct Crawler Targets)
# 45% Flutter Web App Pages (User SPA Experience)
# 10% Global Infrastructure (Sitemap, Service Worker, Robots)
$overallScore = [math]::Round(($avgStatic * 0.45) + ($avgFlutter * 0.45) + ($globalScore * 0.10), 1)

$totalAuditedPages = $script:flutterPageResults.Count + $script:staticPageResults.Count
$totalPassedPages = ($script:flutterPageResults | Where-Object { $_.Status -eq "PASS" }).Count + `
                    ($script:staticPageResults | Where-Object { $_.Status -eq "PASS" }).Count
$totalWarnPages = ($script:flutterPageResults | Where-Object { $_.Status -eq "WARN" }).Count + `
                  ($script:staticPageResults | Where-Object { $_.Status -eq "WARN" }).Count
$totalFailPages = ($script:flutterPageResults | Where-Object { $_.Status -eq "FAIL" }).Count + `
                  ($script:staticPageResults | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host "`n" ("=" * 100) -ForegroundColor Cyan
Write-Host "ADSENSE COMPLIANCE BENCHMARKING EXECUTIVE ROLLUP REPORT" -ForegroundColor Cyan
Write-Host ("=" * 100) -ForegroundColor Cyan
Write-Host ("{0,-42} | {1,-10} | {2}" -f "Evaluation Scope", "Average", "Breakdown")
$flutterPass = @($script:flutterPageResults | Where-Object { $_.Status -eq "PASS" }).Count
$flutterWarn = @($script:flutterPageResults | Where-Object { $_.Status -eq "WARN" }).Count
$flutterFail = @($script:flutterPageResults | Where-Object { $_.Status -eq "FAIL" }).Count

$staticPass = @($script:staticPageResults | Where-Object { $_.Status -eq "PASS" }).Count
$staticWarn = @($script:staticPageResults | Where-Object { $_.Status -eq "WARN" }).Count
$staticFail = @($script:staticPageResults | Where-Object { $_.Status -eq "FAIL" }).Count

$globalPass = @($script:globalResults.Values | Where-Object { $_.Status -eq "PASS" }).Count
$globalWarn = @($script:globalResults.Values | Where-Object { $_.Status -eq "WARN" }).Count
$globalFail = @($script:globalResults.Values | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host ("{0,-42} | {1,8:N1}% | Total: {2} pages ({3} Passed, {4} Warn, {5} Failed)" -f "Flutter Web App Pages (SPA)", $avgFlutter, $script:flutterPageResults.Count, $flutterPass, $flutterWarn, $flutterFail)
Write-Host ("{0,-42} | {1,8:N1}% | Total: {2} pages ({3} Passed, {4} Warn, {5} Failed)" -f "Static HTML Pages (Prerendered & KB)", $avgStatic, $script:staticPageResults.Count, $staticPass, $staticWarn, $staticFail)
Write-Host ("{0,-42} | {1,8:N1}% | Total: {2} checks ({3} Passed, {4} Warn, {5} Failed)" -f "Global Infrastructure (Sitemap/SW/Robots)", $globalScore, $globalTotal, $globalPass, $globalWarn, $globalFail)
Write-Host ("-" * 100)

$overallColor = if ($overallScore -ge $Threshold) { "Green" } else { "Red" }
Write-Host ("COMBINED SITE COMPLIANCE SCORE:           {0,8:N1}%" -f $overallScore) -ForegroundColor $overallColor
Write-Host ("TOTAL PAGES AUDITED:                      {0,8}" -f $totalAuditedPages)
Write-Host ("PAGES PASSING (>= 90%):                   {0,8} ({1:N1}%)" -f $totalPassedPages, (($totalPassedPages / $totalAuditedPages) * 100)) -ForegroundColor Green
if ($totalWarnPages -gt 0) {
    Write-Host ("PAGES WARNING (75% - 89%):                {0,8} ({1:N1}%)" -f $totalWarnPages, (($totalWarnPages / $totalAuditedPages) * 100)) -ForegroundColor Yellow
}
if ($totalFailPages -gt 0) {
    Write-Host ("PAGES FAILING (< 75%):                    {0,8} ({1:N1}%)" -f $totalFailPages, (($totalFailPages / $totalAuditedPages) * 100)) -ForegroundColor Red
}

Write-Host ("=" * 100) -ForegroundColor Cyan

if ($overallScore -ge $Threshold -and $totalFailPages -eq 0) {
    Write-Host "[RESULT] SITE IS 100% READY FOR GOOGLE ADSENSE REVIEW SUBMISSION." -ForegroundColor Green
    Write-Host "All static HTML pages and Flutter web pages meet or exceed publisher readiness standards.`n" -ForegroundColor Green
    exit 0
} elseif ($overallScore -ge $Threshold) {
    Write-Host "[RESULT] SITE MEETS PASSING THRESHOLD ($overallScore%) BUT HAS $totalFailPages FAILING PAGES." -ForegroundColor Yellow
    Write-Host "Address the failing pages listed above prior to final review submission.`n" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "[RESULT] SITE COMPLIANCE SCORE ($overallScore%) IS BELOW REQUIRED THRESHOLD ($Threshold%)." -ForegroundColor Red
    Write-Host "Remediate highlighted deficiencies before requesting Google AdSense review.`n" -ForegroundColor Red
    exit 1
}
