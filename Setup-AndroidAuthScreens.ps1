<#
.SYNOPSIS
Sets up Android Registration and Login screens with Google & Facebook placeholders.

.PARAMETER ProjectPath
Root path of your Android project (e.g. E:\VedicCouple\matchmaking-app-android)
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Android Auth Screens Setup"
Write-Host "------------------------------------------------------------"

# Validate
if (!(Test-Path $ProjectPath)) {
    Write-Error "❌ ERROR: Provided path does not exist: $ProjectPath"
    exit 1
}

# Create target folder
$authFolder = Join-Path $ProjectPath "app/src/main/java/com/yourapp/ui/auth"
New-Item -ItemType Directory -Force -Path $authFolder | Out-Null

# RegistrationScreen.kt
$registrationScreen = @"
package com.yourapp.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun RegistrationScreen(navController: NavController) {
    var emailOrPhone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(modifier = Modifier.padding(16.dp)) {
        Text("Register", style = MaterialTheme.typography.h4)
        Spacer(modifier = Modifier.height(16.dp))
        OutlinedTextField(
            value = emailOrPhone,
            onValueChange = { emailOrPhone = it },
            label = { Text("Email or Phone") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { /* TODO: Handle registration */ }, modifier = Modifier.fillMaxWidth()) {
            Text("Register")
        }
        Spacer(modifier = Modifier.height(16.dp))
        SocialLoginButtons(onGoogleClick = {}, onFacebookClick = {})
    }
}
"@
$registrationScreen | Set-Content -Encoding UTF8 (Join-Path $authFolder "RegistrationScreen.kt")
Write-Host "✅ RegistrationScreen.kt written."

# LoginScreen.kt
$loginScreen = @"
package com.yourapp.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun LoginScreen(navController: NavController) {
    var emailOrPhone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(modifier = Modifier.padding(16.dp)) {
        Text("Login", style = MaterialTheme.typography.h4)
        Spacer(modifier = Modifier.height(16.dp))
        OutlinedTextField(
            value = emailOrPhone,
            onValueChange = { emailOrPhone = it },
            label = { Text("Email or Phone") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { /* TODO: Handle login */ }, modifier = Modifier.fillMaxWidth()) {
            Text("Login")
        }
        Spacer(modifier = Modifier.height(16.dp))
        SocialLoginButtons(onGoogleClick = {}, onFacebookClick = {})
    }
}
"@
$loginScreen | Set-Content -Encoding UTF8 (Join-Path $authFolder "LoginScreen.kt")
Write-Host "✅ LoginScreen.kt written."

# SocialLoginButtons.kt
$socialButtons = @"
package com.yourapp.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun SocialLoginButtons(
    onGoogleClick: () -> Unit,
    onFacebookClick: () -> Unit
) {
    Column {
        Button(onClick = onGoogleClick, modifier = Modifier.fillMaxWidth()) {
            Text("Continue with Google")
        }
        Spacer(modifier = Modifier.height(8.dp))
        Button(onClick = onFacebookClick, modifier = Modifier.fillMaxWidth()) {
            Text("Continue with Facebook")
        }
    }
}
"@
$socialButtons | Set-Content -Encoding UTF8 (Join-Path $authFolder "SocialLoginButtons.kt")
Write-Host "✅ SocialLoginButtons.kt written."

Write-Host "------------------------------------------------------------"
Write-Host "✅ Android Auth Screens setup complete!"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "   1. Add navigation to RegistrationScreen and LoginScreen."
Write-Host "   2. Integrate Google Sign-In and Facebook SDK."
Write-Host "------------------------------------------------------------"
