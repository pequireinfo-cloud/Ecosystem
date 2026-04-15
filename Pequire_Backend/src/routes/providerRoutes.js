const express = require('express');
const router = express.Router();
const providerController = require('../controllers/providerController');

router.get('/', providerController.getProviders);
router.put('/:id/status', providerController.toggleProviderStatus);
router.put('/:id/kyc', providerController.updateProviderKyc);

module.exports = router;
