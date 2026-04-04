const spService = require('../services/spService');

exports.acceptJob = async (req, res) => {
  try {
    const { providerId } = req.body;
    const { jobId } = req.params;

    await spService.acceptJob(jobId, providerId);
    res.status(200).json({ message: 'Job accepted successfully' });
  } catch (error) {
    console.error('Accept job error:', error);
    res.status(400).json({ error: error.message || 'Failed to accept job' });
  }
};

exports.updateJobStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const { jobId } = req.params;

    await spService.updateJobStatus(jobId, status);
    res.status(200).json({ message: `Job status updated to ${status}` });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: error.message || 'Failed to update job status' });
  }
};
