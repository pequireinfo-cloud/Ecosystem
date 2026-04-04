const { db } = require('../config/firebase');

/**
 * Service to handle booking operations.
 */
class BookingService {
  /**
   * Create a new booking in Firestore.
   * @param {Object} bookingData 
   * @returns {Promise<Object>}
   */
  async createBooking(bookingData) {
    const { userId, serviceCategory, problemDescription, location } = bookingData;
    
    if (!db) {
      throw new Error('Firebase DB not initialized');
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
      estimatedPrice: null,
      timeline: [{ status: 'REQUESTED', timestamp: new Date() }],
      createdAt: new Date()
    };

    await bookingRef.set(newBooking);
    return newBooking;
  }

  /**
   * Get bookings for a specific user.
   * @param {string} userId 
   * @returns {Promise<Array>}
   */
  async getUserBookings(userId) {
    if (!db) {
      throw new Error('Firebase DB not initialized');
    }

    const snapshot = await db.collection('bookings').where('userId', '==', userId).get();
    let bookings = [];
    snapshot.forEach(doc => {
      bookings.push(doc.data());
    });

    return bookings;
  }
}

module.exports = new BookingService();
