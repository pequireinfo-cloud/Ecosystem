const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// Define API routes mapping to the controller
// POST /api/bookings
router.post('/', bookingController.createBooking);

// GET /api/bookings/user/:userId
router.get('/user/:userId', bookingController.getUserBookings);

module.exports = router;
