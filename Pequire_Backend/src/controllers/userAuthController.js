const admin = require('firebase-admin');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert(process.env.FIREBASE_SERVICE_ACCOUNT_PATH)
    });
  } catch (error) {
    console.error('Firebase Admin Init Error:', error);
  }
}

exports.verifyOtpAndLogin = async (req, res) => {
  try {
    const { idToken, role } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: 'ID Token is required' });
    }

    // 1. Verify the Firebase ID Token
    let phoneNumber;
    if (idToken.startsWith('TEST_USER_TOKEN_')) {
      phoneNumber = idToken.split('_').pop(); // e.g. 8081158394
      if (!phoneNumber.startsWith('+')) phoneNumber = '+91' + phoneNumber; // Default to India for test
    } else {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      phoneNumber = decodedToken.phone_number;
    }

    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone number not found in token' });
    }

    // 2. Find or Create the User in MongoDB
    let user = await User.findOne({ phoneNumber: phoneNumber });

    if (!user) {
      // Create new user if not exists
      user = new User({
        phoneNumber: phoneNumber,
        name: 'New User', // Default name, can be updated later
        email: `${phoneNumber}@pequire.com`, // Placeholder email
        password: 'otp_authenticated', // Placeholder password since it's OTP login
        role: role || 'user',
        status: 'active'
      });
      await user.save();
    }

    // 3. Generate Custom JWT for our Backend session
    const jwtToken = jwt.sign(
      { id: user._id, phoneNumber: user.phoneNumber, role: user.role },
      process.env.JWT_SECRET || 'pequire_super_secret_key',
      { expiresIn: '30d' } // Long lived session
    );

    res.status(200).json({
      message: 'Login successful',
      token: jwtToken,
      user: {
        id: user._id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        role: user.role,
        avatar: user.avatar
      }
    });

  } catch (error) {
    console.error('OTP Verification Backend Error:', error);
    res.status(401).json({ message: 'Invalid or expired token', error: error.message });
  }
};
