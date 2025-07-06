# Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "------------------------------------------------------------"
Write-Host "✅ Adding MongoDB files and folders to .gitignore..."
Write-Host "------------------------------------------------------------"

$gitignorePath = ".gitignore"

$linesToAdd = @(
    "",
    "# Ignore MongoDB data and journals",
    "matchmaking-app-backend/data/",
    "*.wt",
    "*.lock",
    "*.bson",
    "/journal",
    "*.turtle"
)

foreach ($line in $linesToAdd) {
    Add-Content -Path $gitignorePath -Value $line
}

Write-Host "✅ .gitignore updated."

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ Removing tracked MongoDB files from the index..."
Write-Host "------------------------------------------------------------"

git rm --cached -r "matchmaking-app-backend/data"

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ Committing changes..."
Write-Host "------------------------------------------------------------"

git add .gitignore
git commit -m "Remove MongoDB data directory and add .gitignore rules"

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "✅ Pushing to remote..."
Write-Host "------------------------------------------------------------"

git push

Write-Host "✅ Done!"
