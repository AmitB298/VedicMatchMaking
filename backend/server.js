const express = require('express');
require('dotenv').config();
const app = express();
app.use(express.json());
app.get('/api/health', (req, res) => res.send('✅ Node Backend running'));
app.listen(process.env.PORT || 3000, () => console.log('✅ Backend listening on port', process.env.PORT || 3000));
