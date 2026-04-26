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
    const { kycStatus, documents, rejectionReason } = req.body;
    
    const updateData = { kycStatus };
    if (documents) updateData.documents = documents;
    if (rejectionReason) updateData.rejectionReason = rejectionReason;

    const provider = await Provider.findByIdAndUpdate(id, updateData, { new: true });
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

exports.getProviderReviews = async (req, res) => {
  try {
    const { id } = req.params;
    const Booking = require('../models/Booking');
    const reviews = await Booking.find({ 
      providerId: id, 
      rating: { $exists: true } 
    })
    .populate('userId', 'name')
    .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
