<#
.SYNOPSIS
  Safely injects *valid*, production-grade Android Compose Login and Register screens.
  Makes backups first.
#>

Write-Host "🧭 VedicMatchMaking Android FINAL Auth Screen Injector" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------"

# Define paths
$basePath = ".\matchmaking-app-android\app\src\main\java\com\matchmaking\app\ui\screens"
$loginPath = Join-Path $basePath "LoginScreen.kt"
$registerPath = Join-Path $basePath "RegisterScreen.kt"

# Create target folder if missing
if (!(Test-Path $basePath)) {
    New-Item -Path $basePath -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created screens folder: $basePath" -ForegroundColor Green
}

function Backup-And-WriteFile($filePath, $content) {
    if (Test-Path $filePath) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupPath = "$filePath.bak.$timestamp"
        Copy-Item $filePath $backupPath
        Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Yellow
    }
    $content | Set-Content -Path $filePath -Encoding UTF8
    Write-Host "✅ Updated: $filePath" -ForegroundColor Green
}

# Valid Kotlin Content (no errors!)
$loginScreenContent = @"
package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun LoginScreen(navController: NavController, onLogin: (String, String) -> Unit) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Column(modifier = Modifier
        .fillMaxSize()
        .padding(16.dp)) {

        Text("Login", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(16.dp))

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

        Spacer(Modifier.height(16.dp))
        Button(
            onClick = { onLogin(email, password) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Login")
        }

        Spacer(Modifier.height(8.dp))
        TextButton(
            onClick = { navController.navigate("register") },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Don't have an account? Register")
        }
    }
}
"@

$registerScreenContent = @"
package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun RegisterScreen(navController: NavController, onRegister: (String, String, String) -> Unit) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }

    Column(modifier = Modifier
        .fillMaxSize()
        .padding(16.dp)) {

        Text("Register", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(16.dp))

        OutlinedTextField(
            value = displayName,
            onValueChange = { displayName = it },
            label = { Text("Display Name") },
            modifier = Modifier.fillMaxWidth()
        )

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

        Spacer(Modifier.height(16.dp))
        Button(
            onClick = { onRegister(email, password, displayName) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Register")
        }

        Spacer(Modifier.height(8.dp))
        TextButton(
            onClick = { navController.navigate("login") },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Already have an account? Login")
        }
    }
}
"@

# Inject files
Write-Host "`n🔧 Injecting LoginScreen.kt..." -ForegroundColor Cyan
Backup-And-WriteFile -filePath $loginPath -content $loginScreenContent

Write-Host "`n🔧 Injecting RegisterScreen.kt..." -ForegroundColor Cyan
Backup-And-WriteFile -filePath $registerPath -content $registerScreenContent

Write-Host "`n✅ Injection Complete. Your Android Compose screens are now production-grade!" -ForegroundColor Green
Write-Host "✨ Done!" -ForegroundColor Cyan
