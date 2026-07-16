# Extract images from PDF using raw binary parsing
$pdfPath = Get-ChildItem -Path "c:\Users\user\Desktop\Site de guia do HeyGen" -Filter "*.pdf" | Select-Object -First 1 -ExpandProperty FullName
$outputDir = "c:\Users\user\Desktop\Site de guia do HeyGen\images"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$bytes = [System.IO.File]::ReadAllBytes($pdfPath)
Write-Host "PDF size: $($bytes.Length) bytes"

# Search for JPEG signatures (FFD8FF)
$imageCount = 0
for ($i = 0; $i -lt $bytes.Length - 3; $i++) {
    if ($bytes[$i] -eq 0xFF -and $bytes[$i+1] -eq 0xD8 -and $bytes[$i+2] -eq 0xFF) {
        # Found JPEG start, now find end (FFD9)
        for ($j = $i + 3; $j -lt $bytes.Length - 1; $j++) {
            if ($bytes[$j] -eq 0xFF -and $bytes[$j+1] -eq 0xD9) {
                $length = $j - $i + 2
                if ($length -gt 5000) {  # Only save images larger than 5KB
                    $imageCount++
                    $imageBytes = New-Object byte[] $length
                    [Array]::Copy($bytes, $i, $imageBytes, 0, $length)
                    $outputFile = Join-Path $outputDir "image_$imageCount.jpg"
                    [System.IO.File]::WriteAllBytes($outputFile, $imageBytes)
                    Write-Host "Saved image_$imageCount.jpg ($length bytes)"
                }
                $i = $j + 1
                break
            }
        }
    }
}

# Search for PNG signatures (89504E47)
for ($i = 0; $i -lt $bytes.Length - 8; $i++) {
    if ($bytes[$i] -eq 0x89 -and $bytes[$i+1] -eq 0x50 -and $bytes[$i+2] -eq 0x4E -and $bytes[$i+3] -eq 0x47) {
        # Found PNG start, now find IEND chunk
        for ($j = $i + 8; $j -lt $bytes.Length - 8; $j++) {
            if ($bytes[$j] -eq 0x49 -and $bytes[$j+1] -eq 0x45 -and $bytes[$j+2] -eq 0x4E -and $bytes[$j+3] -eq 0x44) {
                $length = $j - $i + 8  # Include IEND CRC
                if ($length -gt 5000) {
                    $imageCount++
                    $imageBytes = New-Object byte[] $length
                    [Array]::Copy($bytes, $i, $imageBytes, 0, $length)
                    $outputFile = Join-Path $outputDir "image_$imageCount.png"
                    [System.IO.File]::WriteAllBytes($outputFile, $imageBytes)
                    Write-Host "Saved image_$imageCount.png ($length bytes)"
                }
                $i = $j + 7
                break
            }
        }
    }
}

Write-Host "Total images extracted: $imageCount"
