const express = require("express");
const router = express.Router();
const { generateKundli } = require("../kundliService");

router.post("/generate", (req, res) => {
    const { birthDate, birthTime, latitude, longitude } = req.body;

    generateKundli(birthDate, birthTime, latitude, longitude, (error, kundliData) => {
        if (error) {
            return res.status(500).send({ error: "Error generating Kundli" });
        }
        res.json(kundliData);
    });
});

module.exports = router;
