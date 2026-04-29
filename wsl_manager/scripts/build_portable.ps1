# Build portable ZIP for WSL Manager
# Usage: .\scripts\build_portable.ps1
# Output: dist\WSLManager_portable.zip

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$BuildDir = Join-Path $ProjectRoot 'build\windows\x64\runner\Release'
$DistDir  = Join-Path $ProjectRoot 'dist'

Write-Host '==> flutter build windows --release' -ForegroundColor Cyan
Push-Location $ProjectRoot
flutter build windows --release
Pop-Location

if (-not (Test-Path $BuildDir)) {
    Write-Error "Build directory not found: $BuildDir"
    exit 1
}

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
$ZipPath = Join-Path $DistDir 'WSLManager_portable.zip'

Write-Host "==> Creating $ZipPath" -ForegroundColor Cyan
Compress-Archive -Path "$BuildDir\*" -DestinationPath $ZipPath -Force

$SizeKb = [math]::Round((Get-Item $ZipPath).Length / 1KB)
Write-Host "==> Done: $ZipPath ($SizeKb KB)" -ForegroundColor Green
