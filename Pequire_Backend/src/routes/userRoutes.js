const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile, updateUserPreferences } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, updateUserProfile);
router.put('/preferences', protect, updateUserPreferences);

module.exports = router;
