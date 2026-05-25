const User = require('../models/User');
const Provider = require('../models/Provider');
const jwt = require('jsonwebtoken');
const descopeSdk = require('@descope/node-sdk');
const DescopeClient = descopeSdk.default || descopeSdk.DescopeClient || descopeSdk;

// Initialize Descope Client
let descopeClient;
try {
  descopeClient = DescopeClient({
    projectId: process.env.DESCOPE_PROJECT_ID || 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5'
  });
} catch (e) {
  console.error('FAILED TO INITIALIZE DESCOPE CLIENT:', e);
}

// @desc    Verify Descope Token and Login/Register
// @route   POST /api/auth/user/verify-descope
// @access  Public
exports.verifyDescopeToken = async (req, res) => {
  try {
    const { sessionToken, role = 'user' } = req.body;

    if (!sessionToken) {
      return res.status(400).json({
        success: false,
        message: 'Descope session token is required'
      });
    }

    // 1. Verify the session token with Descope
    let authDetails;
    try {
      authDetails = await descopeClient.validateSession(sessionToken);
    } catch (error) {
      console.error('Descope Validation Error:', error);
      return res.status(401).json({
        success: false,
        message: 'Invalid Descope session'
      });
    }

    // 2. Extract user info from Descope authDetails
    const loginId = authDetails.token.sub;
    const loginIds = authDetails.token.loginIds || [];
    const phoneFromLoginIds = loginIds.find(id => id.startsWith('+')) || loginIds[0];
    const phoneNumber = authDetails.token.phone || phoneFromLoginIds || loginId;

    let account;
    let isNew = false;

    if (role === 'provider') {
      account = await Provider.findOne({ phoneNumber });
      if (!account) {
        console.log(`Creating new provider with phone: ${phoneNumber}`);
        account = await Provider.create({
          phoneNumber,
          fullName: 'New Partner',
          serviceType: 'Carpentry',
          status: 'Offline',
          location: { geo: { type: 'Point', coordinates: [0, 0] } }
        });
        isNew = true;
      }
    } else {
      account = await User.findOne({ phoneNumber });
      if (!account) {
        console.log(`Creating new user with phone: ${phoneNumber}`);
        account = await User.create({
          phoneNumber,
          name: 'New User',
          role: 'user'
        });
        isNew = true;
      }
    }

    // 4. Generate our own JWT for the Ecosystem
    const token = jwt.sign(
      { id: account._id, role: role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(200).json({
      success: true,
      token,
      user: {
        id: account._id,
        phoneNumber: account.phoneNumber,
        role: role,
        name: account.name || account.fullName,
        nickname: account.nickname,
        email: account.email,
        dob: account.dob,
        gender: account.gender,
        country: account.country,
        address: account.address,
        preferences: account.preferences,
        currentStreak: account.currentStreak,
        rewardPoints: account.rewardPoints,
        isNewUser: isNew,
        kycStatus: account.kycStatus
      }
    });

  } catch (error) {
    console.error('Verify Descope Error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during verification'
    });
  }
};

// @desc    Verify OTP Code directly on Backend
// @route   POST /api/auth/user/verify-otp
// @access  Public
exports.verifyOtpCode = async (req, res) => {
  try {
    const { phoneNumber, otp, role = 'user' } = req.body;

    if (!phoneNumber || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and OTP are required'
      });
    }

    console.log(`Backend verifying OTP for ${phoneNumber}...`);

    // 1. Verify the OTP code with Descope (Try SMS first, then WhatsApp)
    let authResponse;
    try {
      // Try verifying via SMS
      authResponse = await descopeClient.otp.verify.sms(phoneNumber, otp);
      console.log('Descope OTP Verification successful (SMS)');
    } catch (smsError) {
      console.log('SMS Verification failed, trying WhatsApp...');
      try {
        // Try verifying via WhatsApp
        authResponse = await descopeClient.otp.verify.whatsapp(phoneNumber, otp);
        console.log('Descope OTP Verification successful (WhatsApp)');
      } catch (whatsappError) {
        console.error('Descope OTP Verification Error (All Channels):', whatsappError);
        return res.status(401).json({
          success: false,
          message: 'Invalid OTP or expired'
        });
      }
    }

    // 2. Extract user info from authResponse
    // Use optional chaining to handle different SDK response structures
    const phone = authResponse?.user?.phone || authResponse?.data?.user?.phone || phoneNumber;

    let account;
    let isNew = false;

    if (role === 'provider') {
      account = await Provider.findOne({ phoneNumber: phone });
      if (!account) {
        account = await Provider.create({
          phoneNumber: phone,
          fullName: 'New Partner',
          status: 'Offline',
          location: { geo: { type: 'Point', coordinates: [0, 0] } }
        });
        isNew = true;
      }
    } else {
      account = await User.findOne({ phoneNumber: phone });
      if (!account) {
        account = await User.create({
          phoneNumber: phone,
          name: 'New User',
          role: 'user'
        });
        isNew = true;
      }
    }

    const token = jwt.sign(
      { id: account._id, role: role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(200).json({
      success: true,
      token,
      user: {
        id: account._id,
        phoneNumber: account.phoneNumber,
        role: role,
        name: account.name || account.fullName,
        isNewUser: isNew
      }
    });

  } catch (error) {
    console.error('Backend OTP Verification Error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during verification'
    });
  }
};

// Note: Manual OTP endpoints (send-whatsapp-otp, verify-whatsapp-otp) 
// are now handled DIRECTLY by the Descope SDK on the mobile side.
// The backend only needs to verify the final session token.
