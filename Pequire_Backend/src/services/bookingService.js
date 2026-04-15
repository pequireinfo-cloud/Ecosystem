const mongoose = require('mongoose');
const Booking = require('../models/Booking');
const Provider = require('../models/Provider');

/**
 * Service to handle booking operations using MongoDB and Socket.io bridge logic.
 */
class BookingService {
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
    
    // Trigger notifications for nearby providers
    this.notifyNearbyProviders(newBooking).catch(err => console.error('Notification Error:', err));

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
}

module.exports = new BookingService();
