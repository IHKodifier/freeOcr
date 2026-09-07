<#
.SYNOPSIS
    Generates a valid PDF file of an exact specified size in megabytes (MB).
.PARAMETER SizeMB
    Target file size in MB (e.g. 105 for testing >100MB limit). Default: 105.
.PARAMETER OutFile
    Output filename or path. Default: test_105mb.pdf.
.EXAMPLE
    .\scripts\generate_test_pdf.ps1 -SizeMB 105
#>
param(
    [double]$SizeMB = 105.0,
    [string]$OutFile = "test_105mb.pdf"
)

$targetBytes = [int64]($SizeMB * 1024 * 1024)

# Base valid PDF template structure
$header = [System.Text.Encoding]::ASCII.GetBytes("%PDF-1.4`n%`xE2`xE3`xCF`xD3`n")

$bodyText = @"
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>
endobj
4 0 obj
<< /Length 73 >>
stream
BT
/F1 24 Tf
100 700 Td
(freeOCR.me Test Document) Tj
0 -30 Td
($($SizeMB) MB Limit Testing Payload) Tj
ET
endstream
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj

"@
$body = [System.Text.Encoding]::ASCII.GetBytes($bodyText)

$xrefText = @"
xref
0 6
0000000000 65535 f 
0000000015 00000 n 
0000000068 00000 n 
0000000125 00000 n 
0000000250 00000 n 
0000000375 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
450
%%EOF

"@
$xref = [System.Text.Encoding]::ASCII.GetBytes($xrefText)

$baseLen = $header.Length + $body.Length + $xref.Length
$paddingNeeded = $targetBytes - $baseLen

$fs = [System.IO.File]::Create($OutFile)
$fs.Write($header, 0, $header.Length)
$fs.Write($body, 0, $body.Length)

if ($paddingNeeded -gt 3) {
    $padHeader = [System.Text.Encoding]::ASCII.GetBytes("% ")
    $fs.Write($padHeader, 0, $padHeader.Length)
    
    $chunkSize = 1024 * 1024 # 1MB chunks
    $chunk = New-Object byte[] $chunkSize
    for ($i = 0; $i -lt $chunkSize; $i++) { $chunk[$i] = 48 } # '0'
    
    $remaining = $paddingNeeded - 3
    while ($remaining -gt 0) {
        $writeSize = [int][Math]::Min($remaining, $chunkSize)
        $fs.Write($chunk, 0, $writeSize)
        $remaining -= $writeSize
    }
    
    $padNewline = [System.Text.Encoding]::ASCII.GetBytes("`n")
    $fs.Write($padNewline, 0, $padNewline.Length)
}

$fs.Write($xref, 0, $xref.Length)
$fs.Close()

$actualSize = (Get-Item $OutFile).Length
Write-Host "Generated test PDF successfully:" -ForegroundColor Green
Write-Host "  Path:        $((Get-Item $OutFile).FullName)"
Write-Host "  Target Size: $SizeMB MB ($($targetBytes.ToString('N0')) bytes)"
Write-Host "  Actual Size: $([Math]::Round($actualSize / 1MB, 2)) MB ($($actualSize.ToString('N0')) bytes)"
