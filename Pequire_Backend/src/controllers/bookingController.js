const bookingService = require('../services/bookingService');

exports.createBooking = async (req, res) => {
  try {
    const { userId, serviceCategory, problemDescription, location } = req.body;
    
    const newBooking = await bookingService.createBooking({
      userId,
      serviceCategory,
      problemDescription,
      location
    });

    res.status(201).json({ 
      message: 'Booking created successfully', 
      booking: newBooking 
    });
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ error: error.message || 'Failed to create booking' });
  }
};

exports.getUserBookings = async (req, res) => {
  try {
    const { userId } = req.params;
    const bookings = await bookingService.getUserBookings(userId);
    res.status(200).json(bookings);
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ error: error.message || 'Failed to retrieve bookings' });
  }
};
