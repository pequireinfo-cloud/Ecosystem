const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// Define API routes mapping to the controller
// POST /api/bookings
router.get('/', bookingController.getAllBookings);
router.post('/', bookingController.createBooking);
router.get('/:id', bookingController.getBookingById);
router.get('/user/:userId', bookingController.getUserBookings);
router.get('/provider/:providerId', bookingController.getProviderBookings);

// Lifecycle routes
router.post('/:id/confirm-payment', bookingController.confirmPayment);
router.post('/:id/confirm-offline-payment', bookingController.confirmOfflinePayment);
router.put('/:id/accept', bookingController.acceptBooking);
router.post('/:id/verify-arrival', bookingController.verifyArrival);
router.post('/:id/diagnosis', bookingController.submitDiagnosis);
router.post('/:id/approve-diagnosis', bookingController.approveDiagnosis);
router.post('/:id/verify-work', bookingController.verifyWork);
router.post('/:id/feedback', bookingController.submitFeedback);
router.post('/:id/user-feedback', bookingController.submitUserFeedback);
router.post('/:id/cancel', bookingController.cancelBooking);
router.post('/:id/settle-commission', bookingController.settleCommission);

module.exports = router;
