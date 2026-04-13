const express = require('express');
const router = express.Router();
const providerController = require('../controllers/providerController');

router.get('/', providerController.getProviders);
router.put('/:id/status', providerController.toggleProviderStatus);

module.exports = router;
