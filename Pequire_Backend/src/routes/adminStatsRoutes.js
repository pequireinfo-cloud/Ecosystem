const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Provider = require('../models/Provider'); // Assuming Provider model exists
const Booking = require('../models/Booking'); // Assuming Booking model exists

router.get('/', async (req, res) => {
  try {
    // Note: In a real app, you'd have proper aggregations. 
    // For now, we fetch counts.
    
    let totalProviders = 0;
    try {
      totalProviders = await Provider.countDocuments();
    } catch (e) {
      console.log('Provider model check failed, using 0');
    }

    const totalUsers = await User.countDocuments({ role: 'user' });
    
    let totalBookings = 0;
    let totalRevenue = 0;
    try {
      totalBookings = await Booking.countDocuments();
      const bookings = await Booking.find({ status: 'completed' });
      totalRevenue = bookings.reduce((sum, b) => sum + (b.totalAmount || 0), 0);
    } catch (e) {
      console.log('Booking model check failed, using 0');
    }

    res.json({
      totalProviders,
      totalUsers,
      totalBookings,
      totalRevenue
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
