const mongoose = require('mongoose');
const User = require('./src/models/User');
const bcrypt = require('bcryptjs');

async function seedAdmin() {
  try {
    await mongoose.connect('mongodb://localhost:27017/pequire');
    console.log('Connected to MongoDB');

    const email = 'admin@pequire.com';
    const password = 'admin123';
    
    // Check if admin already exists
    const existingAdmin = await User.findOne({ email });
    if (existingAdmin) {
      console.log('Admin already exists. Deleting it for re-seeding...');
      await User.deleteOne({ email });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const admin = new User({
      fullName: 'Anurag Admin',
      email: email,
      password: hashedPassword,
      phoneNumber: '+91 0000000000',
      role: 'admin',
      profilePicture: 'https://i.pravatar.cc/150?img=12'
    });

    await admin.save();
    console.log('Admin user seeded successfully!');
    console.log('Email: admin@pequire.com');
    console.log('Password: admin123');

    process.exit();
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
}

seedAdmin();
