<#
.SYNOPSIS
    Advanced PowerShell scaffolder for Node.js REST API
.DESCRIPTION
    Creates production-grade Express + MongoDB + JWT API scaffold with full structure.
.PARAMETER RootPath
    Base folder to create the backend in.
.PARAMETER All
    Generates the complete structure and code.
.PARAMETER DryRun
    Shows plan only.
.PARAMETER Force
    Overwrites existing files.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath,

    [switch]$All,
    [switch]$DryRun,
    [switch]$Force
)

function Write-Log {
    param ([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Ensure-Directory {
    param([string]$Path)
    if (-Not (Test-Path $Path)) {
        if (-Not $DryRun) { New-Item -Path $Path -ItemType Directory | Out-Null }
        Write-Log "Created directory: $Path" "SUCCESS"
    }
}

function Write-File {
    param([string]$Path, [string]$Content)
    if ((Test-Path $Path) -and -Not $Force) {
        Write-Log "Skipped existing file (use -Force to overwrite): $Path" "WARNING"
    } else {
        if (-Not $DryRun) {
            $Content | Out-File -Encoding UTF8 -FilePath $Path -Force
        }
        Write-Log "Generated file: $Path" "SUCCESS"
    }
}

function Create-Backend-Scaffold {
    Write-Log "Starting Node.js REST API scaffolding..."

    $folders = @(
        "$RootPath",
        "$RootPath\controllers",
        "$RootPath\models",
        "$RootPath\routes",
        "$RootPath\middleware",
        "$RootPath\services"
    )

    foreach ($folder in $folders) {
        Ensure-Directory -Path $folder
    }

    # Files and templates
    Write-File "$RootPath\.env.example" @"
PORT=3000
MONGODB_URI=mongodb://localhost:27017/vedicmatch
JWT_SECRET=supersecretkey
KUNDLI_SERVICE_URL=http://kundli-service:5000/calculate
"@

    Write-File "$RootPath\server.js" @"
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const kundliRoutes = require('./routes/kundliRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api', kundliRoutes);

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB connected'))
.catch((err) => console.error('❌ MongoDB connection error:', err));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(\`✅ Server running on port \${PORT}\`));
"@

    Write-File "$RootPath\models\User.js" @"
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  birthDate: String,
  birthTime: String,
  birthPlace: String,
  kundliData: Object
});

module.exports = mongoose.model('User', userSchema);
"@

    Write-File "$RootPath\controllers\authController.js" @"
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    await User.create({ name, email, password: hashedPassword });
    res.status(201).json({ message: 'User registered' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) throw new Error('Invalid email');
    const match = await bcrypt.compare(password, user.password);
    if (!match) throw new Error('Invalid password');
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
    res.json({ token });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};
"@

    Write-File "$RootPath\controllers\kundliController.js" @"
const User = require('../models/User');
const axios = require('axios');

exports.generateKundli = async (req, res) => {
  try {
    const { birthDate, birthTime, birthPlace } = req.body;
    const response = await axios.post(process.env.KUNDLI_SERVICE_URL, { birthDate, birthTime, birthPlace });
    await User.findByIdAndUpdate(req.user.id, {
      birthDate,
      birthTime,
      birthPlace,
      kundliData: response.data
    });
    res.json({ kundli: response.data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
"@

    Write-File "$RootPath\middleware\authMiddleware.js" @"
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};
"@

    Write-File "$RootPath\routes\authRoutes.js" @"
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/register', authController.register);
router.post('/login', authController.login);

module.exports = router;
"@

    Write-File "$RootPath\routes\kundliRoutes.js" @"
const express = require('express');
const router = express.Router();
const kundliController = require('../controllers/kundliController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/generate-kundli', authMiddleware, kundliController.generateKundli);

module.exports = router;
"@

    Write-File "$RootPath\package.json" @"
{
  "name": "vedicmatch-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "bcrypt": "^5.0.1",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "mongoose": "^7.2.2",
    "axios": "^1.4.0"
  }
}
"@

    Write-File "$RootPath\Dockerfile" @"
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
"@

    Write-Log "✅ Node.js REST API scaffold complete." "SUCCESS"
}

# Run
Write-Log "------------------------------------------------------------"
Write-Log "✅ VedicMatchmaking Node.js Backend Scaffolder STARTED"
Write-Log "------------------------------------------------------------"

if ($All -or $true) {
    Create-Backend-Scaffold
}

Write-Log "------------------------------------------------------------"
Write-Log "✅ All tasks complete."
Write-Log "------------------------------------------------------------"
