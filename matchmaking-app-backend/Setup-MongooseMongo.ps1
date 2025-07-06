Param(
    [string]$RootPath = "."
)

Write-Host "🛠️  Starting Node.js + MongoDB setup via Mongoose..."

# Define folder paths
$configPath = Join-Path $RootPath "config"
$modelsPath = Join-Path $RootPath "models"
$routesPath = Join-Path $RootPath "routes"

# Create folders if missing
@($configPath, $modelsPath, $routesPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
        Write-Host "✅ Created folder:" $_
    }
}

# Create mongoose.js
$mongooseContent = @"
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect('mongodb://localhost:27017/vedic_matchmaking', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ MongoDB connected successfully!');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;
"@
$mongooseFile = Join-Path $configPath "mongoose.js"
Set-Content -Path $mongooseFile -Value $mongooseContent
Write-Host "✅ Created:" $mongooseFile

# Create Kundli.js model
$kundliModel = @"
const mongoose = require('mongoose');

const KundliSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  name: String,
  birth_date: Date,
  birth_time: String,
  birth_place: String,
  latitude: Number,
  longitude: Number,
  guna_score: Number,
  guna_breakdown: Object,
  dasha_koota_score: Number,
  kaal_sarp_dosha: String,
  mangal_dosha: String,
  navamsa: String,
  verdict: String,
}, { timestamps: true });

module.exports = mongoose.model('Kundli', KundliSchema);
"@
Set-Content -Path (Join-Path $modelsPath "Kundli.js") -Value $kundliModel
Write-Host "✅ Created: models/Kundli.js"

# Create User.js model
$userModel = @"
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: String,
  email: String,
  password: String,
  kundliId: { type: mongoose.Schema.Types.ObjectId, ref: 'Kundli' },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
"@
Set-Content -Path (Join-Path $modelsPath "User.js") -Value $userModel
Write-Host "✅ Created: models/User.js"

# Create Match.js model
$matchModel = @"
const mongoose = require('mongoose');

const MatchSchema = new mongoose.Schema({
  person1: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  person2: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  result: Object,
}, { timestamps: true });

module.exports = mongoose.model('Match', MatchSchema);
"@
Set-Content -Path (Join-Path $modelsPath "Match.js") -Value $matchModel
Write-Host "✅ Created: models/Match.js"

# Create kundliRoutes.js
$routesContent = @"
const express = require('express');
const router = express.Router();
const Kundli = require('../models/Kundli');

router.post('/save', async (req, res) => {
  try {
    const kundliData = req.body;
    const kundli = new Kundli(kundliData);
    await kundli.save();
    res.json({ status: 'success', data: kundli });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

router.get('/all', async (req, res) => {
  try {
    const kundlis = await Kundli.find();
    res.json({ status: 'success', data: kundlis });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

module.exports = router;
"@
Set-Content -Path (Join-Path $routesPath "kundliRoutes.js") -Value $routesContent
Write-Host "✅ Created: routes/kundliRoutes.js"

# Add connection usage to server.js if exists
$serverJs = Join-Path $RootPath "server.js"
if (Test-Path $serverJs) {
    $serverContent = Get-Content $serverJs -Raw
    if ($serverContent -notmatch "connectDB") {
        $updatedContent = "const connectDB = require('./config/mongoose');`n" + $serverContent
        $updatedContent = $updatedContent -replace "(app\.use\(express\.json\(\)\);)", "`$1`nconnectDB();"
        Set-Content -Path $serverJs -Value $updatedContent
        Write-Host "✅ Updated server.js to use connectDB()"
    } else {
        Write-Host "⚠️  server.js already includes connectDB() - skipping modification."
    }
} else {
    Write-Host "⚠️  server.js not found. Skipping auto-injection. Please manually add:"
    Write-Host "   const connectDB = require('./config/mongoose');"
    Write-Host "   connectDB();"
}

Write-Host "🎯 All done! MongoDB integration boilerplate is ready. 🚀"
