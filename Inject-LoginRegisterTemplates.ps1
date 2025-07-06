param(
    [string]$WebPath = ".\matchmaking-app-web\src\screens",
    [string]$AndroidPath = ".\matchmaking-app-android\app\src\main\java"
)

Write-Host ""
Write-Host "🧭 VedicMatchMaking Login/Register Template Injector" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------"

# Define target files and templates
$targets = @(
    @{ Name = "Web LoginScreen.tsx"; Path = Join-Path $WebPath "LoginScreen.tsx"; Type = "web"; Kind = "login" },
    @{ Name = "Web RegisterScreen.tsx"; Path = Join-Path $WebPath "RegisterScreen.tsx"; Type = "web"; Kind = "register" },
    @{ Name = "Android LoginScreen.kt"; Path = Join-Path $AndroidPath "LoginScreen.kt"; Type = "android"; Kind = "login" },
    @{ Name = "Android RegisterScreen.kt"; Path = Join-Path $AndroidPath "RegisterScreen.kt"; Type = "android"; Kind = "register" }
)

# Template definitions
function Get-WebTemplate($kind) {
    if ($kind -eq "login") {
        return @"
import React, { useState } from 'react';
import axios from 'axios';

export default function LoginScreen() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await axios.post('/api/v1/login', { email, password });
            localStorage.setItem('token', res.data.token);
            alert('Login successful!');
        } catch (err) {
            alert('Login failed!');
        }
    };

    return (
        <div className="max-w-md mx-auto mt-10 p-6 rounded-lg shadow-lg bg-white">
            <h1 className="text-2xl mb-4">Login</h1>
            <form onSubmit={handleSubmit}>
                <input className="border p-2 mb-4 w-full" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
                <input type="password" className="border p-2 mb-4 w-full" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
                <button className="bg-blue-600 text-white rounded p-2 w-full">Login</button>
            </form>
        </div>
    );
}
"@
    } else {
        return @"
import React, { useState } from 'react';
import axios from 'axios';

export default function RegisterScreen() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [displayName, setDisplayName] = useState('');
    const [photoURL, setPhotoURL] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await axios.post('/api/v1/register', { email, password, displayName, photoURL });
            localStorage.setItem('token', res.data.token);
            alert('Registration successful!');
        } catch (err) {
            alert('Registration failed!');
        }
    };

    return (
        <div className="max-w-md mx-auto mt-10 p-6 rounded-lg shadow-lg bg-white">
            <h1 className="text-2xl mb-4">Register</h1>
            <form onSubmit={handleSubmit}>
                <input className="border p-2 mb-4 w-full" placeholder="Display Name" value={displayName} onChange={e => setDisplayName(e.target.value)} />
                <input className="border p-2 mb-4 w-full" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
                <input type="password" className="border p-2 mb-4 w-full" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
                <input className="border p-2 mb-4 w-full" placeholder="Photo URL" value={photoURL} onChange={e => setPhotoURL(e.target.value)} />
                <button className="bg-green-600 text-white rounded p-2 w-full">Register</button>
            </form>
        </div>
    );
}
"@
    }
}

function Get-AndroidTemplate($kind) {
    $header = @"
package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
"@

    $start = @"

@Composable
fun ${kind}Screen() {
    var email by remember { mutableStateOf(\"\") }
    var password by remember { mutableStateOf(\"\") }
"@

    $extraFields = ""
    if ($kind -eq "register") {
        $extraFields = @"
    var displayName by remember { mutableStateOf(\"\") }
    var photoURL by remember { mutableStateOf(\"\") }
"@
    }

    $body = @"

    Column(modifier = Modifier.padding(16.dp)) {
        Text(text = \"${kind.Capitalize()} Screen\", style = MaterialTheme.typography.h5)
        Spacer(modifier = Modifier.height(8.dp))
"@

    $registerFields = ""
    if ($kind -eq "register") {
        $registerFields = @"
        OutlinedTextField(value = displayName, onValueChange = { displayName = it }, label = { Text(\"Display Name\") })
        Spacer(modifier = Modifier.height(8.dp))
"@
    }

    $emailPasswordFields = @"
        OutlinedTextField(value = email, onValueChange = { email = it }, label = { Text(\"Email\") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text(\"Password\") }, visualTransformation = PasswordVisualTransformation())
"@

    $photoUrlField = ""
    if ($kind -eq "register") {
        $photoUrlField = @"
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = photoURL, onValueChange = { photoURL = it }, label = { Text(\"Photo URL\") })
"@
    }

    $footer = @"
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { /* TODO: Call ViewModel to submit */ }) {
            Text(text = \"${kind.Capitalize()}\")
        }
    }
}
"@

    return $header + $start + $extraFields + $body + $registerFields + $emailPasswordFields + $photoUrlField + $footer
}

# Main processing
foreach ($t in $targets) {
    if (Test-Path $t.Path) {
        Write-Host ""
        Write-Host "⚠️  Found existing file: $($t.Path)" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to overwrite it with a production-ready template? (Y/N)"
        if ($choice -eq 'Y') {
            Copy-Item $t.Path "$($t.Path).bak" -Force
            Write-Host "✅ Backup created at: $($t.Path).bak" -ForegroundColor Green

            if ($t.Type -eq "web") {
                Get-WebTemplate $t.Kind | Out-File $t.Path -Encoding utf8
            } else {
                Get-AndroidTemplate $t.Kind | Out-File $t.Path -Encoding utf8
            }

            Write-Host "✅ Template injected into: $($t.Path)" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ Skipped: $($t.Path)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ ERROR: File not found: $($t.Path)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 Injection Complete. Your screens are now ready to customize." -ForegroundColor Cyan
Write-Host "✨ Done!" -ForegroundColor Cyan
