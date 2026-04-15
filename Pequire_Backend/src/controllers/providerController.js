const Provider = require('../models/Provider');

exports.toggleProviderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // e.g., 'Blocked' or 'Offline'
    
    const provider = await Provider.findByIdAndUpdate(id, { status }, { new: true });
    res.json(provider);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateProviderKyc = async (req, res) => {
  try {
    const { id } = req.params;
    const { kycStatus } = req.body; // 'Verified' or 'Rejected'
    const provider = await Provider.findByIdAndUpdate(id, { kycStatus }, { new: true });
    res.json(provider);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getProviders = async (req, res) => {
    try {
        const providers = await Provider.find();
        res.json(providers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
