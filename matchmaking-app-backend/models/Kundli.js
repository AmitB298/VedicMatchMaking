const mongoose = require('mongoose');

const KundliSchema = new mongoose.Schema({
    name: String,
    birth_date: String,
    birth_time: String,
    birth_place: String,
    latitude: Number,
    longitude: Number,
    match_result: Object
});

module.exports = mongoose.model('Kundli', KundliSchema);
