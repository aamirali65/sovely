# ──────────────────────────────────────────────────────────
# Compress all audio to 48kbps mono MP3
# Install ffmpeg first: winget install ffmpeg
# Or download from: https://ffmpeg.org/download.html
# ──────────────────────────────────────────────────────────

$ffmpeg = "ffmpeg"
try { & $ffmpeg -version | Out-Null } catch {
  Write-Host "ffmpeg not found. Install it first:" -ForegroundColor Red
  Write-Host "  winget install ffmpeg" -ForegroundColor Yellow
  Write-Host "  or download from https://ffmpeg.org/download.html" -ForegroundColor Yellow
  exit 1
}

$src = "assets\sounds"
$bak = "assets\sounds_backup"
$totalOriginal = 0
$totalNew = 0

# Backup originals
if (!(Test-Path $bak)) { New-Item -ItemType Directory -Path $bak | Out-Null }
Copy-Item "$src\*.mp3" $bak

Write-Host "`nCompressing MP3 files to 48kbps mono..." -ForegroundColor Cyan

Get-ChildItem "$src\*.mp3" | ForEach-Object {
  $in  = $_.FullName
  $tmp = Join-Path $src "tmp_$($_.Name)"

  $origSize = $_.Length
  $totalOriginal += $origSize

  Write-Host "  $($_.Name)  ($([math]::Round($origSize/1KB)) KB)" -NoNewline

  # Re-encode to 48kbps mono, overwrite in-place via temp file
  & $ffmpeg -y -i $in -ac 1 -ar 44100 -b:a 48k $tmp 2>$null

  if ($LASTEXITCODE -eq 0) {
    Move-Item -Force $tmp $in
    $newSize = (Get-Item $in).Length
    $totalNew += $newSize
    $saved = $origSize - $newSize
    Write-Host " -> $([math]::Round($newSize/1KB)) KB (saved $([math]::Round($saved/1KB)) KB)" -ForegroundColor Green
  } else {
    Write-Host " FAILED" -ForegroundColor Red
    if (Test-Path $tmp) { Remove-Item $tmp }
  }
}

$totalOriginalMB = [math]::Round($totalOriginal/1MB, 1)
$totalNewMB = [math]::Round($totalNew/1MB, 1)
$savedMB = [math]::Round(($totalOriginal - $totalNew)/1MB, 1)

Write-Host "`nDone!" -ForegroundColor Cyan
Write-Host "  Before: $totalOriginalMB MB"
Write-Host "  After:  $totalNewMB MB"
Write-Host "  Saved:  $savedMB MB (backup in $bak)" -ForegroundColor Green
