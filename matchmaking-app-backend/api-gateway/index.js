const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

io.on('connection', (socket) => {
  console.log('✅ User connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('❌ User disconnected:', socket.id);
  });
});

app.get('/', (req, res) => res.send('API Gateway with Socket.IO'));
server.listen(3000, () => console.log('🚀 API Gateway running on port 3000'));
