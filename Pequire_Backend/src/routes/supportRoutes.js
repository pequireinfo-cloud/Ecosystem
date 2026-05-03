const express = require('express');
const router = express.Router();
const { getSupportContent } = require('../controllers/supportController');

router.get('/:type', getSupportContent);

module.exports = router;
