const bookingService = require('../services/bookingService');

exports.createBooking = async (req, res) => {
  try {
    const { userId, serviceType, problemDescription, location, estimatedPrice } = req.body;
    const newBooking = await bookingService.createBooking({ userId, serviceType, problemDescription, location, estimatedPrice });
    res.status(201).json({ message: 'Booking created successfully', booking: newBooking });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.acceptBooking = async (req, res) => {
  try {
    const { providerId } = req.body;
    const booking = await bookingService.acceptBooking(req.params.id, providerId);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.verifyArrival = async (req, res) => {
  try {
    const { otp } = req.body;
    const booking = await bookingService.verifyArrival(req.params.id, otp);
    res.status(200).json(booking);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.submitDiagnosis = async (req, res) => {
  try {
    const booking = await bookingService.submitDiagnosis(req.params.id, req.body);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.approveDiagnosis = async (req, res) => {
  try {
    const booking = await bookingService.approveDiagnosis(req.params.id);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.verifyWork = async (req, res) => {
  try {
    const { otp } = req.body;
    const booking = await bookingService.verifyWork(req.params.id, otp);
    res.status(200).json(booking);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.submitFeedback = async (req, res) => {
  try {
    const { rating, feedback } = req.body;
    const booking = await bookingService.submitFeedback(req.params.id, rating, feedback);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.submitUserFeedback = async (req, res) => {
  try {
    const { rating, feedback } = req.body;
    const booking = await bookingService.submitUserFeedback(req.params.id, rating, feedback);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.cancelBooking = async (req, res) => {
  try {
    const { cancelledBy } = req.body; // 'user' or 'provider'
    const booking = await bookingService.cancelBooking(req.params.id, cancelledBy);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.settleCommission = async (req, res) => {
  try {
    const booking = await bookingService.settleCommission(req.params.id);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAllBookings = async (req, res) => {
  try {
    const bookings = await bookingService.getAllBookings();
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getBookingById = async (req, res) => {
  try {
    const booking = await bookingService.getBookingById(req.params.id);
    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getUserBookings = async (req, res) => {
  try {
    const bookings = await bookingService.getUserBookings(req.params.userId);
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
gfjgjjhhjfcfhhgtth