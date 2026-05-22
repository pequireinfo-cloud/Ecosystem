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
    
    // Notify admin panel in real-time
    if (req.io) {
      req.io.emit('kyc_submitted', {
        id: provider._id,
        fullName: provider.fullName,
        kycStatus: provider.kycStatus,
        timestamp: new Date()
      });
    }

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

exports.updateProvider = async (req, res) => {
  try {
    const { id } = req.params;
    const { fullName, email, serviceType, expertise, city, status, kycStatus, documents, rejectionReason } = req.body;

    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (email !== undefined) updateData.email = email;
    if (serviceType !== undefined) updateData.serviceType = serviceType;
    if (expertise !== undefined) updateData.expertise = expertise;
    if (status !== undefined) updateData.status = status;
    if (kycStatus !== undefined) updateData.kycStatus = kycStatus;
    if (documents !== undefined) updateData.documents = documents;
    if (rejectionReason !== undefined) updateData.rejectionReason = rejectionReason;
    
    if (city !== undefined) {
      updateData.location = {
        address: city
      };
    }

    console.log(`Updating provider ${id} with:`, updateData);
    const provider = await Provider.findByIdAndUpdate(id, { $set: updateData }, { new: true });
    if (!provider) {
      return res.status(404).json({ error: 'Provider not found' });
    }
    
    // Also notify if kycStatus is updated or documents are submitted
    if (req.io && (kycStatus || documents)) {
      req.io.emit('kyc_submitted', {
        id: provider._id,
        fullName: provider.fullName,
        kycStatus: provider.kycStatus,
        timestamp: new Date()
      });
    }

    res.json(provider);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

