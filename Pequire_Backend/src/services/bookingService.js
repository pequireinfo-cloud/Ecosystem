const mongoose = require('mongoose');
const Booking = require('../models/Booking');
const Provider = require('../models/Provider');
const User = require('../models/User');
const matchingService = require('./MatchingService');
const RewardService = require('./rewardService');
const { sendPushNotification } = require('../utils/NotificationUtils');

/**
 * Service to handle booking operations using MongoDB and real-time bridges.
 */
class BookingService {
  constructor() {
    this.io = null;
    this.firestore = null;
    try {
      const { admin } = require('../config/firebase');
      if (admin && admin.apps.length > 0) {
        this.firestore = admin.firestore();
      }
    } catch (e) {
      console.warn('Firebase Admin not initialized - real-time Provider updates will skip Firestore sync.');
    }
  }

  setIO(io) {
    this.io = io;
  }
  /**
   * Create a new booking.
   */
  async createBooking(bookingData) {
    const { userId, serviceType, problemDescription, location, estimatedPrice, paymentTiming } = bookingData;
    
    const newBooking = new Booking({
      bookingId: Math.random().toString(36).substring(2, 10).toUpperCase(),
      userId,
      serviceType,
      problemDescription,
      status: 'pending',
      location,
      estimatedPrice,
      paymentTiming: paymentTiming || 'postpaid',
      timeline: [{ status: 'pending', timestamp: new Date() }]
    });

    await newBooking.save();
    
    if (newBooking.paymentTiming !== 'prepaid') {
      // Postpaid: Trigger real-time notifications immediately
      this.notifyNearbyProviders(newBooking).catch(err => console.error('Notification Error:', err));
    } else {
      console.log(`Prepaid Booking ${newBooking.bookingId}: Waiting for payment confirmation before matching.`);
    }
    
    // Broadcast to Admin and User
    if (this.io) {
      this.io.emit('new_booking', newBooking);
      console.log('Socket: Emitted new_booking for', newBooking.bookingId);
    }

    // Sync to Firestore for Provider App
    this._syncToFirestore(newBooking);

    return newBooking;
  }

  /**
   * Find and notify nearby providers via Smart Matching Engine.
   */
  async notifyNearbyProviders(booking) {
    console.log(`Matching: Triggering engine for category: ${booking.serviceType}`);
    
    // Step 1, 2, 4: Hard Filters + Ranking + Fallback Radius
    const { providers, searchRadius, fallbackCount } = await matchingService.findBestProviders(booking);

    if (providers.length === 0) {
      this.io?.emit('no_provider_found', { bookingId: booking.bookingId });
      return;
    }

    // Update booking metadata with matching results
    booking.matchingMetadata = {
      notifiedProviderIds: providers.slice(0, 3).map(p => p._id),
      searchRadiusKm: searchRadius / 1000,
      matchingScores: providers.slice(0, 3).map(p => ({ providerId: p._id, score: p.matchingScore })),
      fallbacksUsed: fallbackCount
    };
    await booking.save();

    // Step 3: Dispatch Logic (Mode B: Simultaneous Top 3)
    console.log(`Matching: Notifying Top ${Math.min(3, providers.length)} providers.`);
    
    providers.slice(0, 3).forEach(provider => {
      if (this.io) {
        // Emit to the specific provider's room or general channel
        this.io.emit('new_assignment', {
          bookingId: booking._id,
          publicId: booking.bookingId,
          score: provider.matchingScore,
          distance: provider.currentDistanceKm
        });
      }

      // Send Push Notification to Provider
      sendPushNotification({
        providerId: provider._id,
        title: 'New Service Request!',
        body: `A new ${booking.serviceType} request is available nearby. Tap to view.`,
        type: 'booking_created',
        data: { bookingId: booking._id.toString() }
      });
    });

    // Real-time: Sync to Firestore for the Provider App view
    this._syncToFirestore(booking);
  }

  /**
   * Confirm Payment (Online/Prepaid/Postpaid)
   */
  async confirmPayment(bookingId, paymentData) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.paymentStatus = 'paid';
    booking.paymentMethod = 'online';
    booking.timeline.push({ status: booking.status, timestamp: new Date(), note: 'Payment confirmed online' });
    
    await booking.save();
    this._syncToFirestore(booking);

    if (booking.paymentTiming === 'prepaid' && booking.status === 'pending') {
      // Now that they've paid, start matching
      this.notifyNearbyProviders(booking).catch(err => console.error('Notification Error:', err));
    } else if (booking.paymentTiming === 'postpaid') {
      // Notify SP that payment was received
      if (this.io && booking.providerId) {
        this.io.emit('payment_received', {
          bookingId: booking._id,
          publicId: booking.bookingId,
          amount: booking.finalPrice || booking.estimatedPrice
        });
      }
    }

    return booking;
  }

  /**
   * Confirm Offline Payment (Provider App Cash collection)
   */
  async confirmOfflinePayment(bookingId) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.paymentStatus = 'paid';
    booking.paymentMethod = 'offline';
    booking.timeline.push({ status: booking.status, timestamp: new Date(), note: 'Payment received offline (cash)' });
    
    await booking.save();
    this._syncToFirestore(booking);

    // Notify User
    if (this.io) {
      this.io.to(booking.bookingId).emit('offline_payment_confirmed', booking);
    }

    return booking;
  }

  /**
   * Provider accepts booking. Generates Arrival OTP.
   */
  async acceptBooking(bookingId, providerId) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    if (booking.status !== 'pending') {
      throw new Error('Booking already accepted by another provider');
    }

    booking.status = 'accepted';
    booking.providerId = providerId;
    booking.arrivalOtp = this._generateOtp();
    booking.timeline.push({ status: 'accepted', timestamp: new Date() });
    
    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
    
    // Notify User
    sendPushNotification({
      userId: booking.userId,
      title: 'Booking Accepted!',
      body: 'A provider has accepted your service request and is on the way.',
      type: 'booking_accepted',
      data: { bookingId: booking._id.toString() }
    });
    
    return booking;
  }

  /**
   * Verify Arrival OTP (Transition to diagnosing).
   */
  async verifyArrival(bookingId, otp) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');
    if (booking.arrivalOtp !== otp) throw new Error('Invalid Arrival OTP');

    booking.status = 'diagnosing';
    booking.timeline.push({ status: 'at_location', timestamp: new Date() });
    
    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
    
    // Notify User
    sendPushNotification({
      userId: booking.userId,
      title: 'Provider Arrived',
      body: 'Your provider has arrived at the location.',
      type: 'booking_arrived',
      data: { bookingId: booking._id.toString() }
    });

    return booking;
  }

  /**
   * Provider submits diagnosis and final price.
   */
  async submitDiagnosis(bookingId, diagnosisData) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.status = 'waiting_approval';
    booking.diagnosis = {
      appliance: diagnosisData.appliance,
      problem: diagnosisData.problem,
      suggestedSolution: diagnosisData.solution
    };
    booking.finalPrice = diagnosisData.price;
    booking.timeline.push({ status: 'diagnosed', timestamp: new Date() });

    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
    return booking;
  }

  /**
   * User approves the diagnosis. Generates Work OTP.
   */
  async approveDiagnosis(bookingId) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.status = 'working';
    booking.workOtp = this._generateOtp();
    booking.timeline.push({ status: 'working', timestamp: new Date() });

    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
    return booking;
  }

  /**
   * Verify Work OTP (Completion).
   */
  async verifyWork(bookingId, otp) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');
    if (booking.workOtp !== otp) throw new Error('Invalid Work OTP');

    booking.status = 'completed';
    booking.timeline.push({ status: 'completed', timestamp: new Date() });

    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
    
    // Notify User
    sendPushNotification({
      userId: booking.userId,
      title: 'Service Completed',
      body: 'Your service has been marked as completed. Please leave a review!',
      type: 'booking_completed',
      data: { bookingId: booking._id.toString() }
    });
    
    return booking;
  }

  /**
   * Submit Feedback.
   */
  async submitFeedback(bookingId, rating, feedback) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.rating = rating;
    booking.review = feedback; // Ensure we use 'review' as per schema
    await booking.save();

    // Recalculate Provider's Average Rating
    if (booking.providerId) {
      const provider = await Provider.findById(booking.providerId);
      if (provider) {
        const stats = await Booking.aggregate([
          { $match: { providerId: provider._id, rating: { $exists: true } } },
          { $group: { _id: null, avgRating: { $avg: "$rating" }, totalReviews: { $sum: 1 } } }
        ]);

        if (stats.length > 0) {
          provider.rating = parseFloat(stats[0].avgRating.toFixed(1));
          provider.reviewCount = stats[0].totalReviews;
          await provider.save();
        }
      }
    }

    // UPDATE USER STREAK: User completed whole process till rating
    if (booking.userId) {
      const user = await User.findById(booking.userId);
      if (user) {
        user.currentStreak += 1;
        if (user.currentStreak > (user.highestStreak || 0)) {
          user.highestStreak = user.currentStreak;
        }
        await user.save();
        
        // CHECK REWARDS
        await RewardService.checkAndAward(user, 'user');
      }
    }

    return booking;
  }

  /**
   * Submit User Feedback (SP rating User).
   */
  async submitUserFeedback(bookingId, rating, feedback) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.userRating = rating;
    booking.userReview = feedback;
    await booking.save();

    // Recalculate User's Average Rating
    if (booking.userId) {
      const user = await User.findById(booking.userId);
      if (user) {
        const stats = await Booking.aggregate([
          { $match: { userId: user._id, userRating: { $exists: true } } },
          { $group: { _id: null, avgRating: { $avg: "$userRating" }, totalReviews: { $sum: 1 } } }
        ]);

        if (stats.length > 0) {
          user.rating = parseFloat(stats[0].avgRating.toFixed(1));
          user.reviewCount = stats[0].totalReviews;
          await user.save();
        }
      }
    }

    // UPDATE PROVIDER STREAK: SP completed whole process till rating
    // If offline payment, only increment if commission is already paid
    let canIncrementStreak = true;
    if (booking.paymentMethod === 'offline' && booking.commissionStatus !== 'paid') {
      canIncrementStreak = false;
    }

    if (canIncrementStreak && booking.providerId) {
      const provider = await Provider.findById(booking.providerId);
      if (provider) {
        provider.currentStreak += 1;
        if (provider.currentStreak > (provider.highestStreak || 0)) {
          provider.highestStreak = provider.currentStreak;
        }
        await provider.save();

        // CHECK REWARDS
        await RewardService.checkAndAward(provider, 'provider');
      }
    }

    return booking;
  }

  /**
   * Settle Commission for Offline Payments (Required for SP Streak)
   */
  async settleCommission(bookingId) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    if (booking.paymentMethod !== 'offline') {
      throw new Error('Only offline bookings need commission settlement');
    }

    if (booking.commissionStatus === 'paid') {
      return booking; // Already paid
    }

    booking.commissionStatus = 'paid';
    await booking.save();

    // If SP already rated the user, increment the streak now
    if (booking.userRating && booking.providerId) {
      const provider = await Provider.findById(booking.providerId);
      if (provider) {
        provider.currentStreak += 1;
        if (provider.currentStreak > (provider.highestStreak || 0)) {
          provider.highestStreak = provider.currentStreak;
        }
        await provider.save();

        // CHECK REWARDS
        await RewardService.checkAndAward(provider, 'provider');
      }
    }

    return booking;
  }

  /**
   * Cancel Booking and Reset Streaks
   */
  async cancelBooking(bookingId, cancelledBy) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    if (booking.status === 'completed' || booking.status === 'cancelled') {
      throw new Error('Booking cannot be cancelled now');
    }

    booking.status = 'cancelled';
    booking.cancelledBy = cancelledBy;
    await booking.save();

    // Reset User's Streak if they cancelled
    if (cancelledBy === 'user' && booking.userId) {
      const user = await User.findById(booking.userId);
      if (user) {
        user.currentStreak = 0;
        await user.save();
      }
    }

    // Reset Provider's Streak if they cancelled
    if (cancelledBy === 'provider' && booking.providerId) {
      const provider = await Provider.findById(booking.providerId);
      if (provider) {
        provider.currentStreak = 0;
        await provider.save();
      }
    }

    return booking;
  }

  /**
   * Retrieval Methods
   */
  async getAllBookings() {
    return await Booking.find().sort({ createdAt: -1 });
  }

  async getBookingById(id) {
    return await Booking.findById(id).populate('providerId');
  }

  async getUserBookings(userId) {
    return await Booking.find({ userId }).sort({ createdAt: -1 });
  }

  async getProviderBookings(providerId) {
    return await Booking.find({ providerId }).populate('userId').sort({ createdAt: -1 });
  }

  _generateOtp() {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  _broadcastStatusUpdate(booking) {
    if (this.io) {
      this.io.emit('booking_status_update', {
        id: booking._id,
        bookingId: booking.bookingId,
        status: booking.status,
        providerId: booking.providerId
      });
      // Also notify the specific user room
      this.io.to(booking.bookingId).emit('status_received', booking);
    }
  }

  async _syncToFirestore(booking) {
    if (!this.firestore) return;
    try {
      await this.firestore.collection('bookings').doc(booking._id.toString()).set({
        bookingId: booking.bookingId,
        userId: booking.userId,
        status: booking.status,
        serviceType: booking.serviceType,
        address: booking.address || 'Nearby',
        location: {
          latitude: booking.location.latitude,
          longitude: booking.location.longitude
        },
        estimatedPrice: booking.estimatedPrice,
        finalPrice: booking.finalPrice,
        providerId: booking.providerId,
        updatedAt: new Date()
      }, { merge: true });
      console.log('Firestore: Synced booking', booking.bookingId);
    } catch (e) {
      console.error('Firestore Sync Error:', e.message);
    }
  }
}

module.exports = new BookingService();
