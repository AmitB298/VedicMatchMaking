const InviteCode = require('../models/InviteCode');

exports.createInviteCode = async (req, res) => {
  try {
    const { code, userId, expiresAt } = req.body;
    const newCode = new InviteCode({
      code,
      userId,
      expiresAt
    });
    await newCode.save();
    res.status(201).json({ success: true, data: newCode });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.validateInviteCode = async (req, res) => {
  try {
    const { code } = req.params;
    const invite = await InviteCode.findOne({ code });
    if (!invite) {
      return res.status(404).json({ success: false, message: 'Invite code not found' });
    }
    if (invite.expiresAt && invite.expiresAt < new Date()) {
      return res.status(400).json({ success: false, message: 'Invite code expired' });
    }
    res.json({ success: true, data: invite });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};