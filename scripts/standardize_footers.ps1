# standardize_footers.ps1 — Standardizes footers across all HTML files in src/frontend/web using regex

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir
$WebDir = Join-Path $RootDir "src\frontend\web"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$files = Get-ChildItem -Path $WebDir -Recurse -Filter *.html

$brandReplacement1 = @'
      <div class="footer-col footer-brand">
        <a href="/" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none;">
          <img src="/icons/Icon-48.png" width="28" height="28" alt="freeOCR.me Logo" style="border-radius: 6px; display: block;" onerror="this.onerror=null;this.src='/favicon.png';" />
          <span style="font-size: 18px; font-weight: 800; color: var(--heading, #0f172a); letter-spacing: -0.5px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
            freeOCR<span style="color: #6366f1;">.me</span>
          </span>
        </a>
        <p style="font-size: 0.875rem; color: var(--text-muted); line-height: 1.6; margin-top: 0.75rem;">
          100% Free Online AI OCR utility platform. Converts scanned documents and images into searchable PDFs and structured text with zero persistent cloud storage.
        </p>
      </div>
'@

$brandReplacement2 = @'
        <a href="/" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; margin-bottom: 0.5rem;">
          <img src="/icons/Icon-48.png" width="28" height="28" alt="freeOCR.me Logo" style="border-radius: 6px; display: block;" onerror="this.onerror=null;this.src='/favicon.png';" />
          <span style="font-size: 18px; font-weight: 800; color: var(--heading, #0f172a); letter-spacing: -0.5px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
            freeOCR<span style="color: #6366f1;">.me</span>
          </span>
        </a>
'@

$githubLink = "          <li><a href=`"https://github.com/IHKodifier/freeOcr`" target=`"_blank`" rel=`"noopener`">Source Code (GitHub)</a></li>"

$updatedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $modified = $false

    if ($content.Contains("<footer")) {
        # 1. Standardize Brand Column in KB technical guides
        $brandPattern1 = '(?s)<div class="footer-col">\s*<h4>freeOCR\.me</h4>\s*<p[^>]*>.*?100% Free Online AI OCR utility platform.*?</p>\s*</div>'
        if ($content -match $brandPattern1) {
            $content = [regex]::Replace($content, $brandPattern1, $brandReplacement1)
            $modified = $true
        }

        # 2. Standardize Brand Column in utility pages (h3 freeOCR.me)
        $brandPattern2 = '<h3>freeOCR\.me</h3>'
        if ($content -match $brandPattern2) {
            $content = [regex]::Replace($content, $brandPattern2, $brandReplacement2)
            $modified = $true
        }

        # 3. Add GitHub Repo Link to footer if not already present in footer
        $footerIdx = $content.IndexOf("<footer")
        $footerPart = $content.Substring($footerIdx)
        if (-not $footerPart.Contains("github.com/IHKodifier/freeOcr")) {
            if ($footerPart -match '<li><a href="/terms">Terms of Service</a></li>') {
                $content = $content.Substring(0, $footerIdx) + [regex]::Replace($footerPart, '(<li><a href="/terms">Terms of Service</a></li>)', "`$1`r`n$githubLink", 1)
                $modified = $true
            } elseif ($footerPart -match '<li><a href="/terms">Terms</a></li>') {
                $content = $content.Substring(0, $footerIdx) + [regex]::Replace($footerPart, '(<li><a href="/terms">Terms</a></li>)', "`$1`r`n$githubLink", 1)
                $modified = $true
            } elseif ($footerPart -match '<a href="/terms"[^>]*>Terms</a>') {
                $editorialGithub = '        <a href="https://github.com/IHKodifier/freeOcr" target="_blank" rel="noopener" style="color: var(--link-color);">Source Code (GitHub)</a>'
                $content = $content.Substring(0, $footerIdx) + [regex]::Replace($footerPart, '(<a href="/terms"[^>]*>Terms</a>)', "`$1`r`n$editorialGithub", 1)
                $modified = $true
            }
        }
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        $updatedCount++
    }
}

Write-Host "Standardized footers in $updatedCount files." -ForegroundColor Green
