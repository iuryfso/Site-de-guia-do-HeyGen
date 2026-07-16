# Extract text more thoroughly from PDF using stream decoding
$pdfPath = Get-ChildItem -Path "c:\Users\user\Desktop\Site de guia do HeyGen" -Filter "*.pdf" | Select-Object -First 1 -ExpandProperty FullName
$bytes = [System.IO.File]::ReadAllBytes($pdfPath)
$text = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($bytes)

# Find all BT...ET text blocks
$textBlocks = [regex]::Matches($text, 'BT\s*(.*?)\s*ET', [System.Text.RegularExpressions.RegexOptions]::Singleline)
Write-Host "Found $($textBlocks.Count) text blocks"

$allText = @()
foreach($block in $textBlocks) {
    $content = $block.Groups[1].Value
    # Extract text from Tj and TJ operators
    $tjMatches = [regex]::Matches($content, '\(([^\)]*)\)\s*Tj')
    foreach($tj in $tjMatches) {
        $val = $tj.Groups[1].Value
        if ($val.Length -gt 0) {
            $allText += $val
        }
    }
    # Also extract from TJ arrays
    $tjArrayMatches = [regex]::Matches($content, '\[([^\]]*)\]\s*TJ')
    foreach($tja in $tjArrayMatches) {
        $arrayContent = $tja.Groups[1].Value
        $innerTexts = [regex]::Matches($arrayContent, '\(([^\)]*)\)')
        $line = ""
        foreach($it in $innerTexts) {
            $line += $it.Groups[1].Value
        }
        if ($line.Length -gt 0) {
            $allText += $line
        }
    }
}

$allText | Out-File -FilePath "c:\Users\user\Desktop\Site de guia do HeyGen\pdf_text_v2.txt" -Encoding UTF8
Write-Host "Extracted $($allText.Count) text lines"

# Also look for page count and image references
$pageCount = ([regex]::Matches($text, '/Type\s*/Page[^s]')).Count
Write-Host "Estimated pages: $pageCount"

$imageRefs = ([regex]::Matches($text, '/Subtype\s*/Image')).Count
Write-Host "Image references: $imageRefs"

# Check for FlateDecode streams
$flateStreams = ([regex]::Matches($text, '/FlateDecode')).Count
Write-Host "FlateDecode streams: $flateStreams"
