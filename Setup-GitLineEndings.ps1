<#
.SYNOPSIS
  Sets up line ending enforcement for the repo:
  - Creates/updates .editorconfig
  - Creates/updates .gitattributes
  - Installs pre-commit hook
#>

Write-Host "🔎 Verifying Git repository root..."
try {
    $repoRoot = (git rev-parse --show-toplevel).Trim()
    if (-not $repoRoot) {
        throw "Not inside a Git repository."
    }
    Write-Host "✅ Repo root: $repoRoot"
} catch {
    Write-Error "❌ ERROR: Not inside a Git repository."
    exit 1
}

# -----------------------------
# 1️⃣ Create/update .editorconfig
# -----------------------------
$editorConfig = @"
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.ps1]
end_of_line = crlf

[*.sh]
end_of_line = lf

[*.json]
end_of_line = lf

[*.yaml]
end_of_line = lf

[*.yml]
end_of_line = lf

[*.md]
end_of_line = lf

[*.js]
end_of_line = lf

[*.jsx]
end_of_line = lf

[*.ts]
end_of_line = lf

[*.tsx]
end_of_line = lf

[*.py]
end_of_line = lf

[*.kt]
end_of_line = lf

[*.kts]
end_of_line = lf

[*.gradle]
end_of_line = lf

[Dockerfile]
end_of_line = lf

[docker-compose.yml]
end_of_line = lf
"@

[System.IO.File]::WriteAllText("$repoRoot\.editorconfig", $editorConfig, [System.Text.Encoding]::UTF8)
Write-Host "✅ .editorconfig created or updated"


# -----------------------------
# 2️⃣ Create/update .gitattributes
# -----------------------------
$gitattributes = @"
* text=auto
*.ps1 text eol=crlf
*.sh text eol=lf
*.json text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
*.md text eol=lf
*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.py text eol=lf
*.kt text eol=lf
*.kts text eol=lf
*.gradle text eol=lf
Dockerfile text eol=lf
docker-compose.yml text eol=lf
"@

[System.IO.File]::WriteAllText("$repoRoot\.gitattributes", $gitattributes, [System.Text.Encoding]::UTF8)
Write-Host "✅ .gitattributes created or updated"


# -----------------------------
# 3️⃣ Install pre-commit hook
# -----------------------------
$hookPath = Join-Path $repoRoot ".git\hooks\pre-commit"
$preCommitScript = @"
#!/bin/sh
echo "🔍 Checking for CRLF in staged files..."
git diff --cached --check
if [ \$? -ne 0 ]; then
  echo "❌ ERROR: CRLF detected in staged files. Please fix line endings."
  exit 1
fi
"@

[System.IO.File]::WriteAllText($hookPath, $preCommitScript, [System.Text.Encoding]::UTF8)
Write-Host "✅ Pre-commit hook installed at $hookPath"

# -----------------------------
# 4️⃣ Make hook executable (for Git Bash / WSL / Linux)
# -----------------------------
try {
    git config core.hooksPath .git/hooks
    bash -c "chmod +x '$hookPath'" | Out-Null
    Write-Host "✅ Made pre-commit hook executable (if applicable)"
} catch {
    Write-Warning "⚠️ Could not set executable bit. Please ensure it's executable if on Linux/Mac/WSL."
}

# -----------------------------
# 5️⃣ Reminder to normalize existing files
# -----------------------------
Write-Host "`n💡 TIP:"
Write-Host "If you haven't yet, run:"
Write-Host "   git add --renormalize ."
Write-Host "   git commit -m \"Normalize all line endings\""

Write-Host "`n✅ Setup complete!"
