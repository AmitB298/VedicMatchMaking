require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 3000;
const uri = process.env.MONGODB_URI;

if (!uri) {
  console.error('❌ ERROR: MONGODB_URI is not set in .env');
  process.exit(1);
}

mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// ✅ User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  displayName: String,
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  photoURL: String,
});
const User = mongoose.model('User', userSchema);

// ✅ Match Schema
const matchSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  matchId: String,
  gunaScore: Number,
  matchStatus: String,
  createdAt: { type: Date, default: Date.now },
});
const Match = mongoose.model('Match', matchSchema);

// ✅ Auth Middleware
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'No token provided' });
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.user = user;
    next();
  });
};

// ✅ Routes
app.get('/', (req, res) => res.send('Vedic Matchmaking API is live 🚀'));

app.post('/api/v1/register', async (req, res) => {
  const { email, displayName, password, photoURL } = req.body;
  const existingUser = await User.findOne({ email });
  if (existingUser) return res.status(400).json({ message: 'User already exists' });

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = new User({ email, displayName, password: hashedPassword, photoURL });
  await user.save();

  const token = jwt.sign({ email: user.email, id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ success: true, token, user: { email, displayName, photoURL } });
});

app.post('/api/v1/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (!user || !await bcrypt.compare(password, user.password)) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const token = jwt.sign({ email: user.email, id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ success: true, token, user: { email: user.email, displayName: user.displayName } });
});

app.post('/api/v1/save-match', authenticateToken, async (req, res) => {
  const { matchId, gunaScore, matchStatus } = req.body;
  const match = new Match({ userId: req.user.id, matchId, gunaScore, matchStatus });
  await match.save();
  res.json({ success: true, match });
});

// ✅ Single Listen
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
