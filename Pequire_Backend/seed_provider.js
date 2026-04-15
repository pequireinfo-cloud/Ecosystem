const mongoose = require('mongoose');
const Provider = require('./src/models/Provider');

async function seed() {
  await mongoose.connect('mongodb://localhost:27017/pequire');
  console.log('Connected to MongoDB');

  const mockProvider = {
    fullName: 'Rahul Sharma',
    email: 'rahul.sharma@example.com',
    phoneNumber: '+91 9876543210',
    serviceType: 'Electrical Works',
    status: 'Online',
    kycStatus: 'Verified',
    rating: 4.9,
    location: {
      latitude: 28.6139,
      longitude: 77.2090,
      address: 'Connaught Place, New Delhi'
    }
  };

  await Provider.deleteMany({ email: mockProvider.email });
  const created = await Provider.create(mockProvider);
  console.log('Mock Provider Created:', created._id);

  await mongoose.disconnect();
}

seed().catch(err => console.error(err));
