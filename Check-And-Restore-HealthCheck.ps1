<#
.SYNOPSIS
  Checks if Run-AllHealthChecks.ps1 exists.
  If missing, restores from Run-AllHealthChecks-BROKEN.ps1 if found.
.DESCRIPTION
  - Checks if main healthcheck runner exists
  - If missing, copies the backup automatically
  - Gives clear instructions if backup is also missing
#>

param(
    [string]$MainFile = "Run-AllHealthChecks.ps1",
    [string]$BackupFile = "Run-AllHealthChecks-BROKEN.ps1"
)

Write-Host "🧭 Checking for $MainFile in $(Get-Location)"

if (Test-Path $MainFile) {
    Write-Host "✅ $MainFile already exists. Nothing to do."
    exit 0
}

Write-Warning "⚠️ $MainFile is missing!"

# Check for backup
if (Test-Path $BackupFile) {
    Write-Host "✅ Found backup: $BackupFile"
    try {
        Copy-Item -Path $BackupFile -Destination $MainFile -Force
        Write-Host "✅ Restored $MainFile from $BackupFile"
    } catch {
        Write-Error "❌ Failed to copy backup. Error: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Warning "⚠️ No backup file ($BackupFile) found."
    Write-Host ""
    Write-Host "❗ ACTION REQUIRED:"
    Write-Host " - Recreate $MainFile manually."
    Write-Host " - Or provide a backup file named $BackupFile."
    exit 1
}

Write-Host "✅ Done."
exit 0
