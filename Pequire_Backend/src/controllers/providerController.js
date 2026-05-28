const Provider = require('../models/Provider');
const KycRecord = require('../models/KycRecord');

// Helper function to handle KYC database archival and client socket notifications
const handleKycVerificationStorageAndNotification = async (provider, req) => {
  if (!provider) return;

  // 1. Database Archival
  if (provider.kycStatus === 'Verified' || provider.kycStatus === 'Rejected') {
    try {
      await KycRecord.findOneAndUpdate(
        { providerId: provider._id },
        {
          providerId: provider._id,
          fullName: provider.fullName,
          phoneNumber: provider.phoneNumber,
          documents: provider.documents,
          status: provider.kycStatus,
          rejectionReason: provider.rejectionReason || null,
          verifiedAt: new Date()
        },
        { upsert: true, new: true }
      );
      console.log(`[KYC Admin] Persisted KycRecord for provider ${provider._id} with status: ${provider.kycStatus}`);
    } catch (err) {
      console.error(`[KYC Admin] Error saving KycRecord for ${provider._id}:`, err.message);
    }
  }

  // 2. Real-time Notification to Provider App via Socket.io
  if (req.io) {
    const roomName = provider._id.toString();
    req.io.to(roomName).emit('kyc_status_updated', {
      providerId: provider._id,
      status: provider.kycStatus,
      rejectionReason: provider.rejectionReason || null,
      timestamp: new Date()
    });
    console.log(`[KYC Admin] Socket broadcast 'kyc_status_updated' to room '${roomName}'`);
  }
};

exports.toggleProviderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // e.g., 'Blocked' or 'Offline'
    
    const provider = await Provider.findByIdAndUpdate(id, { status }, { new: true });
    
    if (req.io) {
      req.io.emit('provider_status_updated', {
        providerId: provider._id,
        status: provider.status,
        fullName: provider.fullName,
        serviceType: provider.serviceType,
        rating: provider.rating,
        hourlyRate: provider.hourlyRate
      });
    }

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
    
    if (kycStatus === 'Verified') {
      updateData.rejectionReason = null;
    } else if (rejectionReason !== undefined) {
      updateData.rejectionReason = rejectionReason;
    }

    const provider = await Provider.findByIdAndUpdate(id, updateData, { new: true });
    
    // Archiving in DB and notifying provider app
    await handleKycVerificationStorageAndNotification(provider, req);

    // Notify admin panel list of the update in real-time
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
    const page = parseInt(req.query.page);
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const filter = req.query.filter || 'All';

    // If not requested by admin or no page specified, return all providers as an array for backward compatibility
    if (!page && !req.originalUrl.includes('/admin/')) {
      const providers = await Provider.find().sort({ createdAt: -1 });
      return res.json(providers);
    }

    const activePage = page || 1;
    const skip = (activePage - 1) * limit;

    // 1. Build Query
    const query = {};

    // Search condition
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { serviceType: { $regex: search, $options: 'i' } },
        { phoneNumber: { $regex: search, $options: 'i' } }
      ];
    }

    // Filter conditions
    if (filter === 'Pending KYC') {
      query.kycStatus = { $in: ['Pending', 'In Review'] };
    } else if (filter === 'Active') {
      query.status = { $in: ['Online', 'Offline', 'Busy'] };
    } else if (filter === 'Blocked') {
      query.status = 'Blocked';
    } else if (filter === 'Online') {
      query.status = 'Online';
    }

    // 2. Fetch data with pagination
    const total = await Provider.countDocuments(query);
    const providers = await Provider.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.json({
      providers,
      total,
      page: activePage,
      limit,
      totalPages: Math.ceil(total / limit)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

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
    const { fullName, email, serviceType, expertise, city, status, kycStatus, documents, rejectionReason, latitude, longitude } = req.body;

    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (email !== undefined) updateData.email = email;
    if (serviceType !== undefined) updateData.serviceType = serviceType;
    if (expertise !== undefined) updateData.expertise = expertise;
    if (status !== undefined) updateData.status = status;
    if (kycStatus !== undefined) updateData.kycStatus = kycStatus;
    if (documents !== undefined) updateData.documents = documents;
    
    if (kycStatus === 'Verified') {
      updateData.rejectionReason = null;
    } else if (rejectionReason !== undefined) {
      updateData.rejectionReason = rejectionReason;
    }

    if (latitude !== undefined && longitude !== undefined) {
      updateData['location.latitude'] = latitude;
      updateData['location.longitude'] = longitude;
      updateData['location.geo'] = {
        type: 'Point',
        coordinates: [longitude, latitude] // GeoJSON expects [longitude, latitude]
      };
    }
    
    if (city !== undefined) {
      updateData['location.address'] = city;
    }

    console.log(`Updating provider ${id} with:`, updateData);
    const provider = await Provider.findByIdAndUpdate(id, { $set: updateData }, { new: true });
    if (!provider) {
      return res.status(404).json({ error: 'Provider not found' });
    }
    
    // Archiving in DB and notifying provider app
    await handleKycVerificationStorageAndNotification(provider, req);

    // Also notify if kycStatus is updated or documents are submitted
    if (req.io && (kycStatus || documents)) {
      req.io.emit('kyc_submitted', {
        id: provider._id,
        fullName: provider.fullName,
        kycStatus: provider.kycStatus,
        timestamp: new Date()
      });
    }

    if (req.io && status !== undefined) {
      req.io.emit('provider_status_updated', {
        providerId: provider._id,
        status: provider.status,
        fullName: provider.fullName,
        serviceType: provider.serviceType,
        rating: provider.rating,
        hourlyRate: provider.hourlyRate
      });
    }

    res.json(provider);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


