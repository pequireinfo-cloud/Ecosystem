const { db } = require('../config/firebase');

exports.createBooking = async (req, res) => {
  try {
    const { userId, serviceCategory, problemDescription, location } = req.body;
    
    if (!db) {
      return res.status(500).json({ error: 'Firebase DB not initialized' });
    }

    const bookingRef = db.collection('bookings').doc();
    
    const newBooking = {
      bookingId: bookingRef.id,
      userId,
      providerId: null, // Unassigned
      serviceCategory,
      problemDescription,
      status: 'REQUESTED',
      location,
      estimatedPrice: null, // Will be set later or by AI
      timeline: [{ status: 'REQUESTED', timestamp: new Date() }],
      createdAt: new Date()
    };

    await bookingRef.set(newBooking);

    // TODO: Trigger Notification to nearby SPs matching serviceCategory

    res.status(201).json({ message: 'Booking created successfully', booking: newBooking });
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ error: 'Failed to create booking' });
  }
};

exports.getUserBookings = async (req, res) => {
  try {
    const { userId } = req.params;
    if (!db) return res.status(500).json({ error: 'Firebase DB not initialized' });

    const snapshot = await db.collection('bookings').where('userId', '==', userId).get();
    let bookings = [];
    snapshot.forEach(doc => {
      bookings.push(doc.data());
    });

    res.status(200).json(bookings);
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ error: 'Failed to retrieve bookings' });
  }
};
