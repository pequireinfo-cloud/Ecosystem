const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { admin } = require('../config/firebase');

// Configure Memory Storage (buffer)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    if (!admin || !admin.apps.length) {
      throw new Error('Firebase Admin not initialized. Cannot upload to cloud storage.');
    }

    const bucket = admin.storage().bucket();
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(req.file.originalname);
    const filename = `uploads/${req.file.fieldname}-${uniqueSuffix}${ext}`;
    
    const fileUpload = bucket.file(filename);

    // Save buffer to Firebase Storage
    await fileUpload.save(req.file.buffer, {
      metadata: {
        contentType: req.file.mimetype,
      },
      public: true, // Make file publicly accessible
    });

    // Get the public URL
    const fileUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

    res.status(200).json({
      success: true,
      url: fileUrl,
      filename: filename
    });
  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({ error: error.message || 'File upload failed' });
  }
});

module.exports = router;
