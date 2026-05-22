const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Get users with pagination, search, and stats
router.get('/', async (req, res) => {
  try {
    const page = req.query.page;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const filter = req.query.filter || 'all';

    // 1. Compute stats across the entire user base (where role === 'user')
    const [total, active, verified, pending] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      User.countDocuments({ role: 'user', status: 'active' }),
      User.countDocuments({ role: 'user', kycStatus: 'verified' }),
      User.countDocuments({ role: 'user', kycStatus: 'pending' })
    ]);

    const stats = { total, active, verified, pending };

    // 2. Build filtering query
    const query = { role: 'user' };
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phoneNumber: { $regex: search, $options: 'i' } }
      ];
    }

    if (filter && filter !== 'all') {
      if (['verified', 'pending', 'rejected'].includes(filter)) {
        query.kycStatus = filter;
      } else {
        query.status = filter;
      }
    }

    // 3. Return all if page is not specified (backward compatibility)
    if (!page) {
      const users = await User.find(query).sort({ createdAt: -1 });
      return res.json({ users, stats, total: users.length });
    }

    const activePage = parseInt(page) || 1;
    const skip = (activePage - 1) * limit;

    const totalFiltered = await User.countDocuments(query);
    const users = await User.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.json({
      users,
      stats,
      total: totalFiltered,
      page: activePage,
      limit,
      totalPages: Math.ceil(totalFiltered / limit)
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
