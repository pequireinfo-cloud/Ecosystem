const express = require('express');
const router = express.Router();
const spController = require('../controllers/spController');

// Define API routes mapping to the controller
// POST /api/jobs/:jobId/accept
router.post('/:jobId/accept', spController.acceptJob);

// PUT /api/jobs/:jobId/status
router.put('/:jobId/status', spController.updateJobStatus);

module.exports = router;
