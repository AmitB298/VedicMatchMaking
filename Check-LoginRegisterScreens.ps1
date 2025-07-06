param(
    [string]$WebPath = ".\matchmaking-app-web\src\screens",
    [string]$AndroidPath = ".\matchmaking-app-android\app\src\main\java"
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking Login/Register Screen Validator" -ForegroundColor Cyan
Write-Host "---------------------------------------------------------"

# 1. Define target files
$targets = @(
    @{ Name = "Web LoginScreen.tsx"; Path = Join-Path $WebPath "LoginScreen.tsx" },
    @{ Name = "Web RegisterScreen.tsx"; Path = Join-Path $WebPath "RegisterScreen.tsx" },
    @{ Name = "Android LoginScreen.kt"; Path = Join-Path $AndroidPath "LoginScreen.kt" },
    @{ Name = "Android RegisterScreen.kt"; Path = Join-Path $AndroidPath "RegisterScreen.kt" }
)

# 2. Check and Report
$missing = @()
foreach ($t in $targets) {
    if (Test-Path $t.Path) {
        Write-Host "✅ Found: $($t.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $($t.Name)" -ForegroundColor Red
        $missing += $t
    }
}

# 3. Auto-generate placeholder option
if ($missing.Count -gt 0) {
    Write-Host ""
    $choice = Read-Host "⚠️  Some screens are missing. Do you want to auto-generate basic placeholders? (Y/N)"
    if ($choice -eq 'Y') {
        foreach ($m in $missing) {
            $dir = Split-Path $m.Path
            if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            if ($m.Name -like "*tsx") {
                @"
import React from 'react';
export default function $(Split-Path $m.Path -LeafBase)() {
    return <div>$(Split-Path $m.Path -LeafBase) Placeholder</div>;
}
"@ | Out-File $m.Path -Encoding utf8
            }
            elseif ($m.Name -like "*kt") {
                @"
package com.matchmaking.app.ui.screens

import androidx.compose.material.Text
import androidx.compose.runtime.Composable

@Composable
fun $(Split-Path $m.Path -LeafBase)() {
    Text(text = \"$(Split-Path $m.Path -LeafBase) Placeholder\")
}
"@ | Out-File $m.Path -Encoding utf8
            }
            Write-Host "✅ Created placeholder: $($m.Path)" -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host "✅ All missing screens generated successfully!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📊 Validation Complete. Ready for development." -ForegroundColor Cyan
Write-Host "✨ Done!" -ForegroundColor Cyan
