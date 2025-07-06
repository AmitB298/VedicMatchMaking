param(
  [int]$port = 3000
)

$myPid = $PID
$pids = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess | Sort-Object -Unique

foreach ($targetPid in $pids) {
    if ($targetPid -eq $myPid) {
        Write-Host ("🚫 Skipping self-termination for PID: $targetPid") -ForegroundColor Magenta
        continue
    }

    try {
        Stop-Process -Id $targetPid -Force
        Write-Host ("✅ Killed process using port $port (PID: {0})" -f $targetPid) -ForegroundColor Green
    } catch {
        $errorMsg = $_.Exception.Message
        if (-not $errorMsg) {
            $errorMsg = $_ | Out-String
        }
        Write-Host ("⚠️ Failed to kill PID {0}: {1}" -f $targetPid, $errorMsg) -ForegroundColor Yellow
    }
}
