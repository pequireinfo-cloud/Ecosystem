const admin = require('firebase-admin');

// IMPORTANT: The user needs to download their serviceAccountKey.json from Firebase Console
// Project Settings > Service Accounts > Generate New Private Key
// Place it in the backend folder or use environment variables.

try {
  const path = require('path');
  const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path.resolve(__dirname, '../../serviceAccountKey.json');
  
  if (serviceAccountPath) {
    const resolvedPath = path.resolve(serviceAccountPath);
    
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(resolvedPath),
        storageBucket: 'pequire-a5303.appspot.com'
      });
      console.log('✅ Firebase Admin Initialized successfully.');
    } else {
      console.log('ℹ️ Firebase Admin already initialized.');
    }
  } else {
    console.warn('⚠️ WARN: Firebase Service Account not found. Push notifications may not work.');
  }
} catch (error) {
  console.error('❌ Firebase Admin Initialization Error:', error.message);
}

const db = admin.apps.length ? admin.firestore() : null;
const messaging = admin.apps.length ? admin.messaging() : null;

module.exports = { admin, db, messaging };
