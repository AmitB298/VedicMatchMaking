# Define the actual path where docker.exe is located
$dockerBinPath = "E:\VedicMatchMaking\Docker\resources\bin"

Write-Host "🔎 Checking if Docker path is in the system PATH..."

# Get the current system-level PATH variable
$machinePath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

if ($machinePath -notlike "*$dockerBinPath*") {
    Write-Host "🛠️  Docker path not found in PATH. Adding it now..."
    $newPath = "$machinePath;$dockerBinPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
    Write-Host "✅ Docker path added to system PATH:"
    Write-Host "   $dockerBinPath"
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: You need to restart PowerShell (or your PC) for this change to take effect."
} else {
    Write-Host "✅ Docker path is already in PATH."
}
