// adminController.js
const User = require('../models/User');

exports.banUser = async (req, res) => {
    try {
        const userId = req.params.id;
        await User.updateOne({ _id: userId }, { status: 'banned' });
        res.status(200).json({ message: 'User banned' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getStats = async (req, res) => {
    try {
        const stats = await User.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]);
        res.status(200).json(stats);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
