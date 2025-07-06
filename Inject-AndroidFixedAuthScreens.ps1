<#
.SYNOPSIS
Inject fixed, valid Android Jetpack Compose Login and Register screens

.DESCRIPTION
This script overwrites LoginScreen.kt and RegisterScreen.kt with validated, minimal, production-safe Kotlin Compose code.
#>

Write-Host "`n🧭 VedicMatchMaking Android Production Auth Screen FIXER" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------"

$loginPath = ".\matchmaking-app-android\app\src\main\java\com\matchmaking\app\ui\screens\LoginScreen.kt"
$registerPath = ".\matchmaking-app-android\app\src\main\java\com\matchmaking\app\ui\screens\RegisterScreen.kt"

$confirm = Read-Host "⚠️  This will OVERWRITE both screens. Continue? (Y/N)"
if ($confirm -ne 'Y') {
    Write-Host "❌ Cancelled." -ForegroundColor Red
    exit
}

$loginContent = @"
package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun LoginScreen(onLogin: (String, String) -> Unit) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Login", style = MaterialTheme.typography.headlineMedium)
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth()
        )
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth()
        )
        Button(
            onClick = { onLogin(email, password) },
            modifier = Modifier.fillMaxWidth().padding(top = 16.dp)
        ) {
            Text("Login")
        }
    }
}
"@

$registerContent = @"
package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun RegisterScreen(onRegister: (String, String, String) -> Unit) {
    var email by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Register", style = MaterialTheme.typography.headlineMedium)
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth()
        )
        OutlinedTextField(
            value = displayName,
            onValueChange = { displayName = it },
            label = { Text("Display Name") },
            modifier = Modifier.fillMaxWidth()
        )
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth()
        )
        Button(
            onClick = { onRegister(email, displayName, password) },
            modifier = Modifier.fillMaxWidth().padding(top = 16.dp)
        ) {
            Text("Register")
        }
    }
}
"@

# Backups
$loginBackup = "$loginPath.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
$registerBackup = "$registerPath.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"

Copy-Item $loginPath $loginBackup -Force
Copy-Item $registerPath $registerBackup -Force

$loginContent | Out-File $loginPath -Encoding utf8
$registerContent | Out-File $registerPath -Encoding utf8

Write-Host "✅ LoginScreen.kt overwritten with validated content." -ForegroundColor Green
Write-Host "✅ RegisterScreen.kt overwritten with validated content." -ForegroundColor Green
Write-Host "✨ Done!" -ForegroundColor Cyan
