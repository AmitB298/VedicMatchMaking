# SyncFullSetup.ps1 - Automates full backend/frontend sync test and validation

$backendPath = "E:\VedicMatchMaking\matchmaking-app-backend"
$webPath     = "E:\VedicMatchMaking\vedicmatchweb"
$userService = "$webPath\src\services\userService.ts"
$webApiPath  = "$webPath\src\services\api.ts"
$backendUrl  = "http://192.168.1.4:3000"

# Step 1: Ensure API client exists
if (-Not (Test-Path $webApiPath)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $webApiPath)
  Set-Content $webApiPath @"
import axios from 'axios';

const api = axios.create({
  baseURL: '$backendUrl',
});

export default api;
"@
  Write-Host "✅ Created api.ts"
} else {
  Write-Host "✅ api.ts exists"
}

# Step 2: Ensure userService.ts with fetchUsers
if (-Not (Test-Path $userService)) {
  Set-Content $userService @"
import api from './api';

export const fetchUsers = async () => {
  const response = await api.get('/users');
  return response.data;
};
"@
  Write-Host "✅ Created userService.ts with fetchUsers"
} else {
  Write-Host "✅ userService.ts already exists"
}

# Step 3: Start Backend
Write-Host "\n🚀 Starting backend..."
Start-Process -NoNewWindow -WorkingDirectory $backendPath -FilePath "npm" -ArgumentList "run", "dev"
Start-Sleep -Seconds 5

# Step 4: Start Web
Write-Host "\n🚀 Starting web app..."
try {
    $pid = (Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue).OwningProcess
    if ($pid) {
        Write-Host "⚠️ Port 3000 in use, web will ask to switch..."
    }
} catch {}
Start-Process -WorkingDirectory $webPath -FilePath "npm" -ArgumentList "start"

# Step 5: Info for Android Devs
Write-Host "\n📱 Ensure Android is pointing to $backendUrl"
Write-Host "🔗 If using emulator, use http://10.0.2.2:3000 instead"
Write-Host "\n📂 In Android's UserApi.kt, ensure you have:\n"
Write-Host "interface UserApi {`n    @GET(\"/users\")`n    suspend fun getUsers(): List<User>`n}"

Write-Host "\n🌐 Open http://localhost:3000 in your browser to test web"
