const express = require('express');
const router = express.Router();
const userAuthController = require('../controllers/userAuthController');

// Unified Authentication via Descope
// This handles both One-Tap and Manual OTP (as both result in a Descope session token)
router.post('/verify-descope', userAuthController.verifyDescopeToken);

module.exports = router;
