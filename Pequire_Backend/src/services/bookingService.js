const { db, messaging } = require('../config/firebase');

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
    const { userId, serviceCategory, problemDescription, location, imageUrls } = bookingData;
    
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
      status: 'pending',
      location, // Should be { latitude, longitude }
      imageUrls: imageUrls || [],
      estimatedPrice: null,
      timeline: [{ status: 'REQUESTED', timestamp: new Date() }],
      createdAt: new Date()
    };

    await bookingRef.set(newBooking);

    // Trigger provider matching and notifications asynchronously
    this.notifyNearbyProviders(newBooking).catch(err => console.error('Notification Error:', err));

    return newBooking;
  }

  /**
   * Find and notify nearby providers.
   * @param {Object} booking 
   */
  async notifyNearbyProviders(booking) {
    if (!messaging || !db) return;

    // Simple proximity: Find SPs with same serviceCategory
    // In a real app, use GeoFirestore or coordinate range queries
    const providersSnapshot = await db.collection('service_providers')
      .where('category', '==', booking.serviceCategory)
      .where('isOnline', '==', true)
      .get();

    const tokens = [];
    providersSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.fcmToken) tokens.push(data.fcmToken);
    });

    if (tokens.length === 0) return;

    const message = {
      notification: {
        title: 'New Service Request!',
        body: `A new ${booking.serviceCategory} request is available near you.`
      },
      data: {
        bookingId: booking.bookingId,
        serviceCategory: booking.serviceCategory,
        type: 'NEW_BOOKING'
      },
      tokens: tokens
    };

    await messaging.sendMulticast(message);
    console.log(`Sent notifications to ${tokens.length} providers.`);
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
