const express = require('express');
const kundliRoutes = require('./kundli');

const app = express();
app.use(express.json());
app.use('/api/kundli', kundliRoutes);

const uri = process.env.MONGODB_URI;
app.listen(PORT, () => {
    console.log(`✅ Kundli microservice running on port ${PORT}`);
});
