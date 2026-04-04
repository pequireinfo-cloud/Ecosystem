const { db } = require('../config/firebase');

exports.acceptJob = async (req, res) => {
  try {
    const { providerId } = req.body;
    const { jobId } = req.params;

    if (!db) return res.status(500).json({ error: 'Firebase DB not initialized' });

    const bookingRef = db.collection('bookings').doc(jobId);
    
    // Use a transaction to ensure no double-booking
    await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) {
        throw new Error('Booking does not exist');
      }

      const bookingData = bookingDoc.data();
      if (bookingData.status !== 'REQUESTED') {
        throw new Error('Booking is no longer available');
      }

      const newTimeline = [...bookingData.timeline, { status: 'ACCEPTED', timestamp: new Date() }];

      transaction.update(bookingRef, {
        providerId,
        status: 'ACCEPTED',
        timeline: newTimeline
      });
      
      // Update SP profile
      const spRef = db.collection('service_providers').doc(providerId);
      transaction.update(spRef, { activeJobId: jobId });
    });

    res.status(200).json({ message: 'Job accepted successfully' });

  } catch (error) {
    console.error('Accept job error:', error);
    res.status(400).json({ error: error.message || 'Failed to accept job' });
  }
};

exports.updateJobStatus = async (req, res) => {
  try {
    const { status } = req.body; // ON_THE_WAY, ARRIVED, STARTED, COMPLETED
    const { jobId } = req.params;

    if (!db) return res.status(500).json({ error: 'Firebase DB not initialized' });

    const bookingRef = db.collection('bookings').doc(jobId);
    const bookingDoc = await bookingRef.get();

    if (!bookingDoc.exists) return res.status(404).json({ error: 'Booking not found' });

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

    res.status(200).json({ message: `Job status updated to ${status}` });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: 'Failed to update job status' });
  }
};
