param(
  [Parameter(Mandatory)]
  [string]$AndroidProjectPath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Android Auth Integration Automation"
Write-Host "------------------------------------------------------------"

# Validate project path exists
if (-Not (Test-Path $AndroidProjectPath)) {
    Write-Error "❌ ERROR: The provided AndroidProjectPath does not exist: $AndroidProjectPath"
    exit 1
}

# Build correct paths
$gradleFile = Join-Path $AndroidProjectPath "app\build.gradle"

if (-Not (Test-Path $gradleFile)) {
    Write-Error "❌ ERROR: Couldn't find app/build.gradle at expected location:"
    Write-Error "   $gradleFile"
    Write-Host "✅ HINT: Use this command to verify:"
    Write-Host "    Get-ChildItem -Recurse $AndroidProjectPath | Select-String build.gradle"
    exit 1
}

Write-Host "✅ Dependencies will be added to: $gradleFile"

# Append Google & Facebook SDK
try {
    Add-Content -Path $gradleFile -Value "`nimplementation 'com.google.android.gms:play-services-auth:21.0.0'"
    Add-Content -Path $gradleFile -Value "`nimplementation 'com.facebook.android:facebook-login:latest.release'"
    Write-Host "✅ Dependencies added to build.gradle"
} catch {
    Write-Error "❌ ERROR writing to build.gradle: $_"
    exit 1
}

# Validate ViewModel path
$vmFile = Join-Path $AndroidProjectPath "app\src\main\java\com\yourapp\viewmodel\AuthViewModel.kt"
$vmDir  = Split-Path $vmFile -Parent

if (-Not (Test-Path $vmDir)) {
    Write-Host "⚠️  ViewModel folder does not exist. Creating:"
    New-Item -ItemType Directory -Path $vmDir -Force | Out-Null
}

# Write dummy ViewModel
@"
package com.yourapp.viewmodel

import androidx.lifecycle.ViewModel

class AuthViewModel : ViewModel() {
    // TODO: Integrate Google and Facebook sign-in
}
"@ | Out-File $vmFile -Encoding utf8

Write-Host "✅ AuthViewModel.kt written"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "   1. Sync Gradle in Android Studio."
Write-Host "   2. Add GoogleSignInClient initialization."
Write-Host "   3. Implement FacebookSdk initialization in Application."
Write-Host "------------------------------------------------------------"
Write-Host "✅ Android Auth Automation complete!"
