const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const uri = process.env.MONGODB_URI;
const client = new MongoClient(uri);
client.connect().then(() => {
  console.log('✅ MongoDB connected');
  const app = express();
  const db = client.db('vedicmatch');
  app.use(cors(), express.json());
  app.post('/api/v1/login', async (req, res) => {
    const { mobile } = req.body;
    if (!mobile) return res.status(400).json({ error: 'Mobile number required' });
    const user = await db.collection('users').findOne({ mobile: String(mobile) });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'Login successful', user });
  });
  app.post('/api/v1/users', async (req, res) => {
    const { name, email, mobile } = req.body;
    const result = await db.collection('users').insertOne({ name, email, mobile: String(mobile) });
    res.status(201).json({ insertedId: result.insertedId });
  });
  app.get('/api/v1/health', (_, res) => res.json({ status: 'ok' }));
  app.listen(3000, '0.0.0.0', () => console.log('🚀 API Gateway on 3000'));
}).catch(err => {
  console.error('❌ MongoDB connection failed:', err);
  process.exit(1);
});
