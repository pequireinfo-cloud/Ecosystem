const mongoose = require('mongoose');
const Booking = require('../models/Booking');
const Provider = require('../models/Provider');

/**
 * Service to handle booking operations using MongoDB and real-time bridges.
 */
class BookingService {
  constructor() {
    this.io = null;
    this.firestore = null;
    try {
      const admin = require('firebase-admin');
      if (admin.apps.length === 0) {
        // Mock init if no key is found, avoid crash
        admin.initializeApp({
          projectId: 'pequire-provider-mock'
        });
      }
      this.firestore = admin.firestore();
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
    const { userId, serviceType, problemDescription, location, estimatedPrice } = bookingData;
    
    const newBooking = new Booking({
      bookingId: Math.random().toString(36).substring(2, 10).toUpperCase(),
      userId,
      serviceType,
      problemDescription,
      status: 'pending',
      location,
      estimatedPrice,
      timeline: [{ status: 'pending', timestamp: new Date() }]
    });

    await newBooking.save();
    
    // Trigger real-time notifications
    this.notifyNearbyProviders(newBooking).catch(err => console.error('Notification Error:', err));
    
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
   * Find and notify nearby providers via MongoDB geospatial query.
   */
  async notifyNearbyProviders(booking) {
    console.log(`Searching for providers for category: ${booking.serviceType}`);
    
    const providers = await Provider.find({
      serviceType: booking.serviceType,
      status: 'Online',
      location: {
        $near: {
          $geometry: { type: "Point", coordinates: [booking.location.longitude, booking.location.latitude] },
          $maxDistance: 10000 // 10km radius
        }
      }
    });

    console.log(`Found ${providers.length} nearby online providers.`);
    // Real-time: Emit to socket.io rooms here in future enhancement
  }

  /**
   * Provider accepts booking. Generates Arrival OTP.
   */
  async acceptBooking(bookingId, providerId) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.status = 'accepted';
    booking.providerId = providerId;
    booking.arrivalOtp = this._generateOtp();
    booking.timeline.push({ status: 'accepted', timestamp: new Date() });
    
    await booking.save();
    this._broadcastStatusUpdate(booking);
    this._syncToFirestore(booking);
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
    return booking;
  }

  /**
   * Submit Feedback.
   */
  async submitFeedback(bookingId, rating, feedback) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.rating = rating;
    booking.feedback = feedback;
    await booking.save();
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
