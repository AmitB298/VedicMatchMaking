const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");

const kundliRoutes = require("./routes/kundli");

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use("/api/kundli", kundliRoutes);

const uri = process.env.MONGODB_URI;

app.listen(PORT, () => {
    console.log(Server is running on port );
});


