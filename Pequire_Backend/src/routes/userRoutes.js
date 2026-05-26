const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile, updateUserPreferences } = require('../controllers/userController');
const { updateUserFcmToken } = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, updateUserProfile);
router.put('/preferences', protect, updateUserPreferences);
router.put('/update-fcm', protect, updateUserFcmToken);

module.exports = router;
