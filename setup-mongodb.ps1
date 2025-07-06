# ------------------- CONFIG -------------------
$adminUser = "admin"
$adminPwd = "MyStrongPassword123!"
$appDb = "vedicmatch"
$appUser = "vedicAdmin"
$appPwd = "V3dic@SecurePwd!"
# ----------------------------------------------

# Auto-detect mongosh
$mongosh = (Get-Command mongosh.exe -ErrorAction SilentlyContinue)?.Source
if (-not $mongosh -or -not (Test-Path $mongosh)) {
    $mongosh = "C:\tools\mongosh\mongosh-2.5.3-win32-x64\bin\mongosh.exe"
    if (-not (Test-Path $mongosh)) {
        Write-Host "❌ mongosh not found. Please install it or update the path in the script." -ForegroundColor Red
        exit 1
    }
}

# Locate mongod.cfg
$possibleConfigs = @(
    "C:\ProgramData\MongoDB\mongod.cfg",
    "C:\Program Files\MongoDB\Server\8.0\bin\mongod.cfg",
    "C:\Program Files\MongoDB\Server\8.0\mongod.cfg"
)
$mongoConfigPath = $possibleConfigs | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $mongoConfigPath) {
    Write-Host "❌ Could not locate mongod.cfg. Please verify MongoDB installation." -ForegroundColor Red
    exit 1
}

# Ensure MongoDB service exists
Write-Host "🔍 Checking MongoDB service..."
if (-not (Get-Service -Name MongoDB -ErrorAction SilentlyContinue)) {
    Write-Host "❌ MongoDB service not found. Please install MongoDB and try again." -ForegroundColor Red
    exit 1
}

# Free up port 27017
Write-Host "`n📦 Checking for port 27017 usage..."
$connections = Get-NetTCPConnection -LocalPort 27017 -ErrorAction SilentlyContinue
if ($connections) {
    Write-Host "⚠️  Port 27017 in use. Attempting to stop process..."
    $pidsToStop = $connections | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($mongoProcId in $pidsToStop) {
        try {
            Stop-Process -Id $mongoProcId -Force -ErrorAction Stop
            Write-Host "✅ Stopped process $mongoProcId"
        } catch {
            Write-Host "⚠️  Could not stop process $mongoProcId"
        }
    }
    Start-Sleep -Seconds 2
}

# Start MongoDB (no auth yet)
Write-Host "`n🚀 Starting MongoDB temporarily without authentication..."
Start-Service -Name MongoDB -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5

# Create admin user
Write-Host "`n👤 Creating admin user..."
& $mongosh --quiet --eval @"
use admin;
db.createUser({
  user: '$adminUser',
  pwd: '$adminPwd',
  roles: [ { role: 'root', db: 'admin' } ]
});
"@

# Create app user
Write-Host "`n👤 Creating application user in database '$appDb'..."
& $mongosh -u $adminUser -p $adminPwd --authenticationDatabase admin --quiet --eval @"
use $appDb;
db.createUser({
  user: '$appUser',
  pwd: '$appPwd',
  roles: [ { role: 'readWrite', db: '$appDb' } ]
});
"@

# Enable authorization in config
Write-Host "`n🔐 Enabling authorization in mongod.cfg..."
$configText = Get-Content $mongoConfigPath -Raw
if ($configText -notmatch "security:\s*\n\s*authorization: enabled") {
    if ($configText -match "security:") {
        $configText = $configText -replace "(?ms)^security:.*?(?=^\S|\Z)", "security:`n  authorization: enabled`n"
    } else {
        $configText += "`nsecurity:`n  authorization: enabled`n"
    }
    Set-Content -Path $mongoConfigPath -Value $configText
    Write-Host "✅ Authorization enabled."
} else {
    Write-Host "🔒 Authorization already enabled."
}

# Restart MongoDB with auth
Write-Host "`n♻️ Restarting MongoDB with authentication..."
Stop-Service -Name MongoDB -Force
Start-Sleep -Seconds 3
Start-Service -Name MongoDB
Start-Sleep -Seconds 5

# Verify app user login
Write-Host "`n✅ Verifying app user login..."
$verify = & $mongosh -u $appUser -p $appPwd --authenticationDatabase $appDb --quiet --eval "db.runCommand({ connectionStatus: 1 })"
if ($verify -match '"ok"\s*:\s*1') {
    Write-Host "✅ MongoDB is secured and app user '$appUser' is working." -ForegroundColor Green
} else {
    Write-Host "❌ Login failed. Check credentials or mongod.cfg." -ForegroundColor Red
}

Write-Host "`n🎉 Setup complete!"
