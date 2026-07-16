$pdfPath = Get-ChildItem -Path "c:\Users\user\Desktop\Site de guia do HeyGen" -Filter "*.pdf" | Select-Object -First 1 -ExpandProperty FullName
Write-Host "Found PDF: $pdfPath"

if ($pdfPath) {
    $bytes = [System.IO.File]::ReadAllBytes($pdfPath)
    Write-Host "Read $($bytes.Length) bytes"
    $text = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($bytes)
    
    # Extract text between parentheses (PDF text objects)
    $matches = [regex]::Matches($text, '(?<=\()([^\)]{2,})(?=\))')
    $result = @()
    foreach($m in $matches) {
        $val = $m.Value
        # Filter out binary/garbage content
        if ($val -match '[A-Za-z]' -and $val.Length -lt 500 -and $val -notmatch '[\x00-\x08]') {
            $result += $val
        }
    }
    $result | Out-File -FilePath "c:\Users\user\Desktop\Site de guia do HeyGen\pdf_text.txt" -Encoding UTF8
    Write-Host "Extracted $($result.Count) text segments"
} else {
    Write-Host "No PDF found"
}
