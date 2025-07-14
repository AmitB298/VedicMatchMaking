const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('✅ Service is running!');
});

app.listen(PORT, () => {
  console.log(`✅ Service listening on port ${PORT}`);
});
