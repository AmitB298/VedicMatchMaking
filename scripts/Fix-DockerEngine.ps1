Write-Host "🔧 Fixing Docker Engine startup..." -ForegroundColor Cyan

# Step 1: Kill Docker + WSL safely
Write-Host "⛔ Stopping Docker & WSL backend..."
Stop-Process -Name "Docker Desktop", "com.docker.backend", "com.docker.service", "Docker" -Force -ErrorAction SilentlyContinue
wsl --shutdown

# Step 2: Unregister docker-desktop (if present)
Write-Host "🧹 Unregistering docker-desktop WSL distro..."
wsl --unregister docker-desktop 2>$null
wsl --unregister docker-desktop-data 2>$null

# Step 3: Relaunch Docker GUI
Write-Host "🚀 Restarting Docker Desktop GUI..."
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Step 4: Wait for pipe to be created
$timeout = 60
$elapsed = 0
$pipePath = "\\.\pipe\dockerDesktopLinuxEngine"

Write-Host "⏳ Waiting for Docker Engine to initialize (up to $timeout seconds)..."
while (-not (Test-Path $pipePath) -and ($elapsed -lt $timeout)) {
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Host "⌛ [$elapsed s] Waiting for pipe..."
}

# Step 5: Test Docker status
if (Test-Path $pipePath) {
    Write-Host "✅ Docker Engine pipe found. Testing docker info..."
    try {
        docker info | Out-Host
        Write-Host "🎉 Docker Engine is running!"
    } catch {
        Write-Host "❌ Docker pipe exists but 'docker info' still failed." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker Engine pipe not found after $timeout seconds." -ForegroundColor Red
    Write-Host "📌 Try restarting your system OR reinstall Docker Desktop." -ForegroundColor Yellow
    Write-Host "💡 You can download the latest version from:"
    Write-Host "🔗 https://docs.docker.com/desktop/"
}
