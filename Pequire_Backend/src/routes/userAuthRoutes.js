const express = require('express');
const router = express.Router();
const userAuthController = require('../controllers/userAuthController');

// Route for OTP verification and login/signup
router.post('/verify-otp', userAuthController.verifyOtpAndLogin);

module.exports = router;
