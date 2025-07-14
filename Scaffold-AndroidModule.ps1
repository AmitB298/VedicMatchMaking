param(
    [string]$RootPath
)
$path = Join-Path $RootPath "android"
New-Item -ItemType Directory -Path $path -Force | Out-Null

Set-Content -Path "$path\README.md" -Value @"
# Android Kundli Module
- Build with Jetpack Compose
- Consumes Node backend REST API
- Displays advanced Kundli data in beautiful, modern UI
"@

Write-Host "✅ Android App Module scaffold complete."
