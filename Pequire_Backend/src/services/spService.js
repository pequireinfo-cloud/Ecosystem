const { db } = require('../config/firebase');

/**
 * Service to handle Service Provider (SP) operations.
 */
class SpService {
  /**
   * Accept a job by an SP.
   * @param {string} jobId 
   * @param {string} providerId 
   * @returns {Promise<void>}
   */
  async acceptJob(jobId, providerId) {
    if (!db) throw new Error('Firebase DB not initialized');

    const bookingRef = db.collection('bookings').doc(jobId);
    
    await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) throw new Error('Booking does not exist');

      const bookingData = bookingDoc.data();
      if (bookingData.status !== 'REQUESTED') {
        throw new Error('Booking is no longer available');
      }

      const newTimeline = [
        ...bookingData.timeline, 
        { status: 'ACCEPTED', timestamp: new Date() }
      ];

      transaction.update(bookingRef, {
        providerId,
        status: 'ACCEPTED',
        timeline: newTimeline
      });
      
      const spRef = db.collection('service_providers').doc(providerId);
      transaction.update(spRef, { activeJobId: jobId });
    });
  }

  /**
   * Update the status of a job.
   * @param {string} jobId 
   * @param {string} status 
   * @returns {Promise<void>}
   */
  async updateJobStatus(jobId, status) {
    if (!db) throw new Error('Firebase DB not initialized');

    const bookingRef = db.collection('bookings').doc(jobId);
    const bookingDoc = await bookingRef.get();

    if (!bookingDoc.exists) throw new Error('Booking not found');

    const bookingData = bookingDoc.data();
    const newTimeline = [...bookingData.timeline, { status, timestamp: new Date() }];

    await bookingRef.update({
      status,
      timeline: newTimeline
    });

    // If COMPLETED, free up the SP
    if (status === 'COMPLETED' || status === 'PAID') {
        const spRef = db.collection('service_providers').doc(bookingData.providerId);
        await spRef.update({ activeJobId: null });
    }
  }
}

module.exports = new SpService();
