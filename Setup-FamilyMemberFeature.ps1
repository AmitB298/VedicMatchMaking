<#
.SYNOPSIS
  Sets up Family Member Registration & Login feature for VedicMatchMaking
  Creates folders, files, and starter content
  Logs all actions to setup-log.txt
#>

# Config
$ProjectRoot = "E:\VedicMatchMaking\matchmaking-app-backend"
$LogFile = Join-Path $ProjectRoot "setup-log.txt"

function Log {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $LogFile -Append
    Write-Host "✅ $message"
}

# Ensure Log File
New-Item -ItemType File -Path $LogFile -Force | Out-Null
Log "Setup started"

#1️⃣ Create needed folders
$folders = @(
    "routes",
    "controllers",
    "validators",
    "docs"
)

foreach ($folder in $folders) {
    $full = Join-Path $ProjectRoot $folder
    if (!(Test-Path $full)) {
        New-Item -ItemType Directory -Path $full | Out-Null
        Log "Created folder: $folder"
    } else {
        Log "Folder already exists: $folder"
    }
}

# 2️⃣ Generate routes/familyRoutes.js
$routesContent = @"
const express = require('express');
const router = express.Router();
const familyController = require('../controllers/familyController');

// Register
router.post('/register', familyController.registerFamily);

// Send OTP
router.post('/sendOtp', familyController.sendOtp);

// Verify OTP
router.post('/verifyOtp', familyController.verifyOtp);

// Login
router.post('/login', familyController.loginFamily);

module.exports = router;
"@
$routesFile = Join-Path $ProjectRoot "routes\familyRoutes.js"
$routesContent | Out-File $routesFile -Encoding utf8
Log "Created routes/familyRoutes.js"

# 3️⃣ Generate controllers/familyController.js
$controllerContent = @"
exports.registerFamily = (req, res) => {
    // TODO: Implement family registration logic
    res.json({ message: 'Family registered (stub)' });
};

exports.sendOtp = (req, res) => {
    // TODO: Implement OTP sending logic
    res.json({ message: 'OTP sent (stub)' });
};

exports.verifyOtp = (req, res) => {
    // TODO: Implement OTP verification logic
    res.json({ message: 'OTP verified (stub)' });
};

exports.loginFamily = (req, res) => {
    // TODO: Implement family login logic
    res.json({ message: 'Family login (stub)' });
};
"@
$controllerFile = Join-Path $ProjectRoot "controllers\familyController.js"
$controllerContent | Out-File $controllerFile -Encoding utf8
Log "Created controllers/familyController.js"

# 4️⃣ Create validators/familySchema.json
$schemaContent = @"
{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "FamilyMember",
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "phone": { "type": "string" },
    "relation": { "type": "string" },
    "linkedUserId": { "type": "string" },
    "email": { "type": ["string", "null"] },
    "language": { "type": "string" },
    "bio": { "type": ["string", "null"] },
    "gotra": { "type": ["string", "null"] },
    "profession": { "type": ["string", "null"] }
  },
  "required": ["name", "phone", "relation", "linkedUserId"]
}
"@
$schemaFile = Join-Path $ProjectRoot "validators\familySchema.json"
$schemaContent | Out-File $schemaFile -Encoding utf8
Log "Created validators/familySchema.json"

# 5️⃣ Generate docs/family-openapi.yaml
$openapiContent = @"
openapi: 3.0.0
info:
  title: Family Member API
  version: 1.0.0
paths:
  /api/family/register:
    post:
      summary: Register a family member
      requestBody:
        content:
          application/json:
            schema:
              \$ref: '../validators/familySchema.json'
      responses:
        '200':
          description: OK

  /api/family/sendOtp:
    post:
      summary: Send OTP
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                phone:
                  type: string
      responses:
        '200':
          description: OK

  /api/family/verifyOtp:
    post:
      summary: Verify OTP
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                phone:
                  type: string
                otp:
                  type: string
      responses:
        '200':
          description: OK

  /api/family/login:
    post:
      summary: Family member login
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                phone:
                  type: string
                otp:
                  type: string
      responses:
        '200':
          description: OK
"@
$openapiFile = Join-Path $ProjectRoot "docs\family-openapi.yaml"
$openapiContent | Out-File $openapiFile -Encoding utf8
Log "Created docs/family-openapi.yaml"

# 6️⃣ Create .env.example
$envContent = @"
# Family Member Feature
OTP_SERVICE_KEY=your-otp-service-key
MONGODB_URI=mongodb://localhost:27017/vedicmatchmaking
JWT_SECRET=your-secret
"@
$envFile = Join-Path $ProjectRoot ".env.example"
$envContent | Out-File $envFile -Encoding utf8
Log "Created .env.example"

# ✅ Complete
Log "Family Member Registration & Login setup completed!"
Write-Host "🎉 Setup finished! See log at $LogFile"
