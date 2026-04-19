const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Get all users with stats
router.get('/', async (req, res) => {
  try {
    const users = await User.find({ role: 'user' }).sort({ createdAt: -1 });
    
    const stats = {
      total: users.length,
      active: users.filter(u => u.status === 'active').length,
      verified: users.filter(u => u.kycStatus === 'verified').length,
      pending: users.filter(u => u.kycStatus === 'pending').length
    };

    res.json({ users, stats });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
