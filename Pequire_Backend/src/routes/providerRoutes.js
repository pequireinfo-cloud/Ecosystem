const express = require('express');
const router = express.Router();
const providerController = require('../controllers/providerController');
const { protect } = require('../middleware/authMiddleware');
const { updateProviderFcmToken } = require('../controllers/notificationController');

router.get('/', providerController.getProviders);
router.put('/:id/status', providerController.toggleProviderStatus);
router.put('/:id/kyc', providerController.updateProviderKyc);
router.put('/:id', providerController.updateProvider);
router.get('/:id/reviews', providerController.getProviderReviews);
router.put('/update-fcm', protect, updateProviderFcmToken);

module.exports = router;
