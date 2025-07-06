param (
    [int]$port = 3000
)

Write-Host "🛑 Killing process on port $port..."
$pid = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
       Select-Object -ExpandProperty OwningProcess -First 1

if ($pid) {
    Stop-Process -Id $pid -Force
    Write-Host "✅ Port $port cleared (PID: $pid)"
} else {
    Write-Host "ℹ️ No process found on port $port"
}

Write-Host "🐳 Starting backend Docker stack..."
docker-compose -f .\docker-compose.yml up --build
