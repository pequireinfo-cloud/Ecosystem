const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./src/models/User');
require('dotenv').config();

const users = [
  {
    name: 'Rahul Sharma',
    email: 'rahul@example.com',
    password: 'password123',
    phoneNumber: '9876543210',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Priya Patel',
    email: 'priya@example.com',
    password: 'password123',
    phoneNumber: '9876543211',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Amit Kumar',
    email: 'amit@example.com',
    password: 'password123',
    phoneNumber: '9876543212',
    role: 'user',
    status: 'active',
    kycStatus: 'pending'
  },
  {
    name: 'Sneha Gupta',
    email: 'sneha@example.com',
    password: 'password123',
    phoneNumber: '9876543213',
    role: 'user',
    status: 'inactive',
    kycStatus: 'not_started'
  },
  {
    name: 'Vikram Singh',
    email: 'vikram@example.com',
    password: 'password123',
    phoneNumber: '9876543214',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Anjali Desai',
    email: 'anjali@example.com',
    password: 'password123',
    phoneNumber: '9876543215',
    role: 'user',
    status: 'active',
    kycStatus: 'rejected'
  },
  {
    name: 'Deepak Reddy',
    email: 'deepak@example.com',
    password: 'password123',
    phoneNumber: '9876543216',
    role: 'user',
    status: 'active',
    kycStatus: 'pending'
  },
  {
    name: 'Meera Iyer',
    email: 'meera@example.com',
    password: 'password123',
    phoneNumber: '9876543217',
    role: 'user',
    status: 'inactive',
    kycStatus: 'not_started'
  },
  {
    name: 'Karan Mehra',
    email: 'karan@example.com',
    password: 'password123',
    phoneNumber: '9876543218',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Sonia Verma',
    email: 'sonia@example.com',
    password: 'password123',
    phoneNumber: '9876543219',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Rajesh Koothrapali',
    email: 'rajesh@example.com',
    password: 'password123',
    phoneNumber: '9876543220',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Sheldon Cooper',
    email: 'sheldon@example.com',
    password: 'password123',
    phoneNumber: '9876543221',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Leonard Hofstadter',
    email: 'leonard@example.com',
    password: 'password123',
    phoneNumber: '9876543222',
    role: 'user',
    status: 'active',
    kycStatus: 'pending'
  },
  {
    name: 'Penny Hofstadter',
    email: 'penny@example.com',
    password: 'password123',
    phoneNumber: '9876543223',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Howard Wolowitz',
    email: 'howard@example.com',
    password: 'password123',
    phoneNumber: '9876543224',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Bernadette Rostenkowski',
    email: 'bernadette@example.com',
    password: 'password123',
    phoneNumber: '9876543225',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Amy Farrah Fowler',
    email: 'amy@example.com',
    password: 'password123',
    phoneNumber: '9876543226',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Stuart Bloom',
    email: 'stuart@example.com',
    password: 'password123',
    phoneNumber: '9876543227',
    role: 'user',
    status: 'inactive',
    kycStatus: 'not_started'
  },
  {
    name: 'Barry Kripke',
    email: 'barry@example.com',
    password: 'password123',
    phoneNumber: '9876543228',
    role: 'user',
    status: 'blocked',
    kycStatus: 'rejected'
  },
  {
    name: 'Wil Wheaton',
    email: 'wil@example.com',
    password: 'password123',
    phoneNumber: '9876543229',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Leslie Winkle',
    email: 'leslie@example.com',
    password: 'password123',
    phoneNumber: '9876543230',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Beverly Hofstadter',
    email: 'beverly@example.com',
    password: 'password123',
    phoneNumber: '9876543231',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Mary Cooper',
    email: 'mary@example.com',
    password: 'password123',
    phoneNumber: '9876543232',
    role: 'user',
    status: 'active',
    kycStatus: 'verified'
  },
  {
    name: 'Zack Johnson',
    email: 'zack@example.com',
    password: 'password123',
    phoneNumber: '9876543233',
    role: 'user',
    status: 'active',
    kycStatus: 'pending'
  },
  {
    name: 'Debbie Wolowitz',
    email: 'debbie@example.com',
    password: 'password123',
    phoneNumber: '9876543234',
    role: 'user',
    status: 'blocked',
    kycStatus: 'not_started'
  }
];


const seedUsers = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/pequire');
    console.log('Connected to MongoDB');

    // Clear existing users (only those with role 'user')
    await User.deleteMany({ role: 'user' });
    console.log('Cleared existing users');

    // Hash passwords and save
    const salt = await bcrypt.genSalt(10);
    for (let u of users) {
      u.password = await bcrypt.hash(u.password, salt);
    }

    await User.insertMany(users);
    console.log('Users seeded successfully');

    mongoose.connection.close();
  } catch (err) {
    console.error('Error seeding users:', err);
    process.exit(1);
  }
};

seedUsers();
