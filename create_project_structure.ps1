
# create_project_structure.ps1
# PowerShell script to create folder and file structure for VedicMatchMaking web, Android, and backend
# Author: Grok 3 (xAI)
# Date: June 20, 2025
# Purpose: Automate setup of matchmaking app structure with React, Jetpack Compose, and Node.js
# Usage: Save as create_project_structure.ps1 and run: .\create_project_structure.ps1
# Requirements: PowerShell 5.1+, write permissions in current directory

# Check write permissions
$currentDir = Get-Location
try {
    $testFile = Join-Path $currentDir "test_write.txt"
    New-Item -Path $testFile -ItemType File -ErrorAction Stop | Out-Null
    Remove-Item -Path $testFile -ErrorAction Stop
}
catch {
    Write-Error "Error: No write permissions in $currentDir. Run as Administrator or change directory."
    exit 1
}

# Define root directory
$rootDir = "VedicMatchMaking"
try {
    if (-not (Test-Path $rootDir)) {
        New-Item -ItemType Directory -Path $rootDir -ErrorAction Stop | Out-Null
    }
    Set-Location -Path $rootDir -ErrorAction Stop
}
catch {
    Write-Error "Error creating or accessing $rootDir : $_"
    exit 1
}

# -----------------------------
# WEB STRUCTURE (React + TypeScript)
# -----------------------------
$webDir = "web"
$webFolders = @(
    "src/screens",
    "src/services",
    "src/utils",
    "src/interfaces",
    "tests/e2e",
    "tests/load"
)
$webFiles = @{
    "src/screens/MatchScreen.tsx" = @"
import React from 'react';
const MatchScreen: React.FC = () => <div>Match Screen</div>;
export default MatchScreen;
"@
    "src/screens/ChatScreen.tsx" = @"
import React from 'react';
const ChatScreen: React.FC<{ otherUserId: string }> = ({ otherUserId }) => <div>Chat Screen with {otherUserId}</div>;
export default ChatScreen;
"@
    "src/services/userService.ts" = @"
import { User } from '../interfaces/User';
export const userService = {
  getUser: async (userId: string): Promise<User> => ({ id: userId, name: '' }),
};
"@
    "src/utils/chatStorage.ts" = @"
import { Message } from '../interfaces/Message';
export const getQueuedMessages = (otherUserId: string): Message[] | null => null;
export const saveQueuedMessages = (otherUserId: string, messages: Message[]) => {};
"@
    "src/interfaces/User.ts" = @"
export interface User {
  id: string;
  name: string;
  photoUrl?: string;
}
"@
    "src/interfaces/Match.ts" = @"
export interface Match {
  id: string;
  name: string;
  caste?: string;
}
"@
    "src/interfaces/Message.ts" = @"
export interface Message {
  senderId: string;
  content: string;
  timestamp: number;
}
"@
    "src/i18n.js" = @"
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
i18n.use(initReactI18next).init({
  resources: { en: { translation: {} }, hi: { translation: {} } },
  lng: 'en',
  fallbackLng: 'en',
});
export default i18n;
"@
    "tests/e2e/matchScreen.test.js" = @"
const puppeteer = require('puppeteer');
describe('MatchScreen E2E', () => {
  it('should display match card', async () => {});
});
"@
    "tests/e2e/chatScreen.test.js" = @"
const puppeteer = require('puppeteer');
describe('ChatScreen E2E', () => {
  it('should display chat', async () => {});
});
"@
    "tests/e2e/connectionToChat.test.js" = @"
const puppeteer = require('puppeteer');
describe('Connection to Chat Flow E2E', () => {
  it('should complete flow', async () => {});
});
"@
    "tests/load/loadTest.js" = @"
import http from 'k6/http';
export default function () {
  http.get('http://localhost:8080/chats');
}
"@
    "package.json" = @"
{
  "name": "vedic-matchmaking-web",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-i18next": "^13.0.0",
    "date-fns": "^3.0.0",
    "socket.io-client": "^4.7.0"
  },
  "devDependencies": {
    "@testing-library/react": "^14.0.0",
    "jest": "^29.0.0",
    "puppeteer": "^21.0.0"
  }
}
"@
}

try {
    New-Item -ItemType Directory -Path $webDir -ErrorAction Stop | Out-Null
    Set-Location -Path $webDir -ErrorAction Stop
    foreach ($folder in $webFolders) {
        New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    }
    foreach ($file in $webFiles.GetEnumerator()) {
        Set-Content -Path $file.Key -Value $file.Value -ErrorAction Stop
    }
    Set-Location -Path ../..
}
catch {
    Write-Error "Error setting up web structure: $_"
    exit 1
}

# -----------------------------
# ANDROID STRUCTURE (Jetpack Compose + Kotlin)
# -----------------------------
$androidDir = "android"
$androidFolders = @(
    "app/src/main/java/com/matchmaking/app/ui/screens",
    "app/src/main/java/com/matchmaking/app/ui/state",
    "app/src/main/java/com/matchmaking/app/viewmodel",
    "app/src/main/java/com/matchmaking/app/core/network",
    "app/src/main/java/com/matchmaking/app/user/data/model",
    "app/src/main/java/com/matchmaking/app/user/repository",
    "app/src/main/res/values",
    "app/src/main/res/values-hi",
    "app/src/test/java/com/matchmaking/app"
)
$androidFiles = @{
    "app/src/main/java/com/matchmaking/app/ui/screens/MatchScreen.kt" = @"
package com.matchmaking.app.ui.screens
import androidx.compose.runtime.Composable
@Composable
fun MatchScreen() {}
"@
    "app/src/main/java/com/matchmaking/app/ui/screens/ChatScreen.kt" = @"
package com.matchmaking.app.ui.screens
import androidx.compose.runtime.Composable
@Composable
fun ChatScreen(otherUserId: String) {}
"@
    "app/src/main/java/com/matchmaking/app/ui/state/MatchUiState.kt" = @"
package com.matchmaking.app.ui.state
sealed class MatchUiState {
    object Loading : MatchUiState()
}
"@
    "app/src/main/java/com/matchmaking/app/ui/state/ChatUiState.kt" = @"
package com.matchmaking.app.ui.state
sealed class ChatUiState {
    object Loading : ChatUiState()
}
"@
    "app/src/main/java/com/matchmaking/app/viewmodel/MatchViewModel.kt" = @"
package com.matchmaking.app.viewmodel
import androidx.lifecycle.ViewModel
class MatchViewModel : ViewModel() {}
"@
    "app/src/main/java/com/matchmaking/app/viewmodel/ChatViewModel.kt" = @"
package com.matchmaking.app.viewmodel
import androidx.lifecycle.ViewModel
class ChatViewModel : ViewModel() {}
"@
    "app/src/main/java/com/matchmaking/app/core/network/SocketManager.kt" = @"
package com.matchmaking.app.core.network
object SocketManager {
    fun connect() {}
}
"@
    "app/src/main/java/com/matchmaking/app/user/data/model/User.kt" = @"
package com.matchmaking.app.user.data.model
data class User(val id: String, val name: String)
"@
    "app/src/main/java/com/matchmaking/app/user/repository/IUserRepository.kt" = @"
package com.matchmaking.app.user.repository
interface IUserRepository {}
"@
    "app/src/main/res/values/strings.xml" = @"
<resources>
    <string name="app_name">VedicMatchMaking</string>
</resources>
"@
    "app/src/main/res/values-hi/strings.xml" = @"
<resources>
    <string name="app_name">वैदिक मंगनी</string>
</resources>
"@
    "app/src/test/java/com/matchmaking/app/ChatScreenTest.kt" = @"
package com.matchmaking.app
class ChatScreenTest {}
"@
    "app/build.gradle" = @"
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'dagger.hilt.android.plugin'

android {
    compileSdk 33
    defaultConfig {
        applicationId 'com.matchmaking.app'
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName '1.0'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.10.0'
    implementation 'androidx.activity:activity-compose:1.7.0'
    implementation 'androidx.compose.material3:material3:1.1.0'
    implementation 'com.google.dagger:hilt-android:2.44'
    implementation 'io.coil-kt:coil-compose:2.4.0'
}
"@
}

try {
    New-Item -ItemType Directory -Path $androidDir -ErrorAction Stop | Out-Null
    Set-Location -Path $androidDir -ErrorAction Stop
    foreach ($folder in $androidFolders) {
        New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    }
    foreach ($file in $androidFiles.GetEnumerator()) {
        Set-Content -Path $file.Key -Value $file.Value -ErrorAction Stop
    }
    Set-Location -Path ../..
}
catch {
    Write-Error "Error setting up Android structure: $_"
    exit 1
}

# -----------------------------
# BACKEND STRUCTURE (Node.js + Microservices)
# -----------------------------
$backendDir = "backend"
$backendFolders = @(
    "services/matchmaking-service/src/controllers",
    "services/matchmaking-service/src/models",
    "services/matchmaking-service/src/lib",
    "services/matchmaking-service/src/tests",
    "services/chat-service/src/controllers",
    "services/chat-service/src/models",
    "services/chat-service/src/lib",
    "services/chat-service/src/tests"
)
$backendFiles = @{
    "services/matchmaking-service/src/controllers/matchController.js" = @"
const Match = require('../models/Match');
module.exports = {
  getMatches: async (req, res) => {},
};
"@
    "services/matchmaking-service/src/controllers/connectionController.js" = @"
const Connection = require('../models/Connection');
module.exports = {
  sendConnectionRequest: async (req, res) => {},
};
"@
    "services/matchmaking-service/src/models/User.js" = @"
const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({});
module.exports = mongoose.model('User', userSchema);
"@
    "services/matchmaking-service/src/models/Match.js" = @"
const mongoose = require('mongoose');
const matchSchema = new mongoose.Schema({});
module.exports = mongoose.model('Match', matchSchema);
"@
    "services/matchmaking-service/src/models/Connection.js" = @"
const mongoose = require('mongoose');
const connectionSchema = new mongoose.Schema({});
module.exports = mongoose.model('Connection', connectionSchema);
"@
    "services/matchmaking-service/src/lib/logger.js" = @"
const logger = {
  info: (msg) => console.log(msg),
};
module.exports = logger;
"@
    "services/matchmaking-service/src/lib/socket.js" = @"
const io = require('socket.io')();
module.exports = { getIo: () => io };
"@
    "services/matchmaking-service/src/tests/connectionController.test.js" = @"
const request = require('supertest');
describe('Connection Controller', () => {
  it('should send connection request', async () => {});
});
"@
    "services/matchmaking-service/package.json" = @"
{
  "name": "matchmaking-service",
  "version": "1.0.0",
  "dependencies": {
    "mongoose": "^7.0.0",
    "redis": "^4.6.0",
    "socket.io": "^4.7.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "supertest": "^6.3.0"
  }
}
"@
    "services/chat-service/src/controllers/chatController.js" = @"
const Chat = require('../models/Chat');
module.exports = {
  sendMessage: async (req, res) => {},
};
"@
    "services/chat-service/src/models/Chat.js" = @"
const mongoose = require('mongoose');
const chatSchema = new mongoose.Schema({});
module.exports = mongoose.model('Chat', chatSchema);
"@
    "services/chat-service/src/lib/logger.js" = @"
const logger = {
  info: (msg) => console.log(msg),
};
module.exports = logger;
"@
    "services/chat-service/src/lib/socket.js" = @"
const io = require('socket.io')();
module.exports = { getIo: () => io };
"@
    "services/chat-service/src/tests/chatController.test.js" = @"
const request = require('supertest');
describe('Chat Controller', () => {
  it('should send message', async () => {});
});
"@
    "services/chat-service/src/tests/loadTest.js" = @"
import http from 'k6/http';
export default function () {
  http.get('http://localhost:8080/chats');
}
"@
    "services/chat-service/package.json" = @"
{
  "name": "chat-service",
  "version": "1.0.0",
  "dependencies": {
    "mongoose": "^7.0.0",
    "redis": "^4.6.0",
    "socket.io": "^4.7.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "supertest": "^6.3.0",
    "k6": "^0.44.0"
  }
}
"@
    "docker-compose.yml" = @"
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    ports:
      - '27017:27017'
  redis:
    image: redis:latest
    ports:
      - '6379:6379'
"@
}

try {
    New-Item -ItemType Directory -Path $backendDir -ErrorAction Stop | Out-Null
    Set-Location -Path $backendDir -ErrorAction Stop
    foreach ($folder in $backendFolders) {
        New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    }
    foreach ($file in $backendFiles.GetEnumerator()) {
        Set-Content -Path $file.Key -Value $file.Value -ErrorAction Stop
    }
    Set-Location -Path ..
}
catch {
    Write-Error "Error setting up backend structure: $_"
    exit 1
}

# -----------------------------
# GIT INITIALIZATION (Optional)
# -----------------------------
$gitInit = Read-Host "Initialize Git repository? (y/n)"
if ($gitInit -eq 'y' -or $gitInit -eq 'Y') {
    try {
        git init | Out-Null
        Set-Content -Path ".gitignore" -Value @"
node_modules/
build/
.gradle/
.idea/
*.iml
"@
        Write-Host "Git repository initialized with .gitignore"
    }
    catch {
        Write-Warning "Failed to initialize Git repository: $_"
    }
}

Write-Host "Project structure created successfully in $rootDir"
Write-Host "Next steps:"
Write-Host "1. Web: cd web && npm install"
Write-Host "2. Android: Open android in Android Studio"
Write-Host "3. Backend: cd backend && docker-compose up"
```