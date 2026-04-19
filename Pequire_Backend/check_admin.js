const mongoose = require('mongoose');
const User = require('./src/models/User');

async function check() {
  try {
    await mongoose.connect('mongodb://localhost:27017/pequire');
    const admins = await User.find({ role: 'admin' });
    console.log('Admins found:', admins.length);
    admins.forEach(a => console.log(`- ${a.email} (${a.role})`));
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

check();
