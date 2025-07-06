const mongoose = require('mongoose');

const MatchSchema = new mongoose.Schema({
    person1: { type: mongoose.Schema.Types.ObjectId, ref: 'Kundli' },
    person2: { type: mongoose.Schema.Types.ObjectId, ref: 'Kundli' },
    result: Object
});

module.exports = mongoose.model('Match', MatchSchema);
