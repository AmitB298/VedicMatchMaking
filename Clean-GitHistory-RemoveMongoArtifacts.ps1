# Strict mode for safety
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ Git Repo Deep Cleaner: Remove MongoDB Artifacts"
Write-Host "------------------------------------------------------------"

# Confirm git-filter-repo exists
Write-Host "✅ Checking for git-filter-repo..."
git filter-repo --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: git-filter-repo not installed."
    exit 1
}

Write-Host "✅ git-filter-repo is installed."

Write-Host ""
Write-Host "✅ Backing up existing repo (safety first)..."
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolder = "..\VedicMatchMakingBackup_$timestamp"
git clone --mirror .git $backupFolder
Write-Host "✅ Backup saved to $backupFolder"

Write-Host ""
Write-Host "✅ Starting git-filter-repo to remove MongoDB artifacts..."
git filter-repo `
    --invert-paths `
    --path "matchmaking-app-backend/data/" `
    --path "*.wt" `
    --path "*.lock" `
    --path "*.bson" `
    --path "journal" `
    --path "*.turtle"

Write-Host ""
Write-Host "✅ git-filter-repo completed."
Write-Host ""
Write-Host "✅ Cleaning and repacking repository..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ History cleaned locally!"
Write-Host "------------------------------------------------------------"
Write-Host ""
Write-Host "✅ FINAL STEP REQUIRED:"
Write-Host ""
Write-Host "➡️ You MUST force-push the cleaned history to GitHub:"
Write-Host ""
Write-Host "    git push --force origin master"
Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ Done!"
Write-Host "------------------------------------------------------------"
