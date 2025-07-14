const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Root route
app.get('/', (req, res) => {
  res.json({ message: 'API Gateway is running' });
});

// ✅ Healthcheck route
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok' });
});

// ✅ Start HTTP server
const server = http.createServer(app);

// ✅ Attach WebSocket
const io = new Server(server, { cors: { origin: "*" } });
io.on('connection', (socket) => {
  console.log('🔔 New WebSocket connection');
});

// ✅ Listen
server.listen(3000, () => console.log('🚀 API Gateway listening on port 3000'));
