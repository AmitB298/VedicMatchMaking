# Safe-Run-Compose.ps1
$composeFilePath = "E:\VedicMatchMaking\matchmaking-app-backend\docker-compose.yml"
$dockerExePath = "E:\VedicMatchMaking\Docker\resources\bin\docker.exe"
$servicesRoot = "E:\VedicMatchMaking\services"

if (!(Test-Path $composeFilePath)) {
    Write-Error "❌ docker-compose.yml not found at: $composeFilePath"
    exit 1
}

# Restore backup if it exists
$backupPath = "$composeFilePath.bak"
if (Test-Path $backupPath) {
    Copy-Item $backupPath $composeFilePath -Force
    Write-Host "🧩 Restored original docker-compose.yml from backup"
}

# Fix build paths and create missing folders
$content = Get-Content $composeFilePath
$fixedLines = @()

foreach ($line in $content) {
    if ($line -match "^\s*build:\s*['""]?\.\/([^'""]+)['""]?") {
        $serviceName = $matches[1]
        $expectedPath = Join-Path $servicesRoot $serviceName
        if (!(Test-Path $expectedPath)) {
            New-Item -ItemType Directory -Path $expectedPath -Force | Out-Null
            New-Item -Path "$expectedPath\Dockerfile" -ItemType File -Value "FROM node:18-alpine\nWORKDIR /app\nCOPY . .\nCMD [\"node\"]" -Force | Out-Null
            Write-Warning "⚠️ Missing build context: './$serviceName'. Creating dummy at '$expectedPath'"
        }
        $fixedLines += $line -replace "\.\/$serviceName", "../services/$serviceName"
    } elseif ($line -match "version:\s*'3.9'") {
        $fixedLines += "# version removed for compatibility"
    } else {
        $fixedLines += $line
    }
}

# Save fixed file
Set-Content $composeFilePath $fixedLines
Write-Host "✅ All missing build paths fixed or stubbed."

# Run Docker Compose
try {
    & "$dockerExePath" compose -f $composeFilePath up -d --build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🚀 Docker Compose ran successfully."
    } else {
        Write-Error "❌ Docker Compose failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "💥 Exception: $_"
}
