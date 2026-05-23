const express = require('express');
const cors = require('cors');
const http = require('http');
const path = require('path');
const { Server } = require('socket.io');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
require('dotenv').config();

// Allowed CORS origins
const allowedOrigins = process.env.ALLOWED_ORIGINS 
  ? process.env.ALLOWED_ORIGINS.split(',') 
  : [
      'http://localhost:5173',
      'https://admin.pequire.com',
      'https://pequire.com',
      'https://www.pequire.com'
    ];

const corsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps)
    if (!origin) return callback(null, true);
    if (allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes('*')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
};

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      if (allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes('*')) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Export io for use in services
module.exports = { app, server, io };

// Rate limiters
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // limit each IP to 200 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests from this IP, please try again after 15 minutes.' }
});

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour window
  max: 20, // limit each IP to 20 auth attempts per hour
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many login or OTP attempts from this IP, please try again after an hour.' }
});

const uploadLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 15, // limit each IP to 15 uploads per 15 minutes
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many upload attempts, please try again later.' }
});

// Apply Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" } // Allow frontends to access static assets from uploads/
}));
app.use(cors(corsOptions));
app.use(express.json({ limit: '10kb' })); // Limit request payloads to 10kb
app.use(express.urlencoded({ extended: true, limit: '10kb' }));
app.use(mongoSanitize()); // Prevent NoSQL injection attacks

// Apply Rate Limiters
app.use('/api/', globalLimiter);
app.use('/api/auth/user/login', authLimiter);
app.use('/api/auth/user/register', authLimiter);
app.use('/api/auth/user/send-otp', authLimiter);
app.use('/api/admin/auth/login', authLimiter);
app.use('/api/upload', uploadLimiter);

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Attach socket.io to request for use in controllers
app.use((req, res, next) => {
  req.io = io;
  next();
});

const bookingRoutes = require('./src/routes/bookingRoutes');
const jobRoutes = require('./src/routes/spRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');
const serviceRoutes = require('./src/routes/serviceRoutes');
const providerRoutes = require('./src/routes/providerRoutes');
const adminAuthRoutes = require('./src/routes/adminAuthRoutes');
const userAuthRoutes = require('./src/routes/userAuthRoutes');
const userRoutes = require('./src/routes/userRoutes');
const adminUserRoutes = require('./src/routes/adminUserRoutes');
const adminStatsRoutes = require('./src/routes/adminStatsRoutes');
const connectDB = require('./src/config/db');

// Connect to MongoDB
connectDB();

// Initialize Real-time Service
const bookingService = require('./src/services/bookingService');
bookingService.setIO(io);

// Routes
app.use('/api/bookings', bookingRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/admin/providers', providerRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/auth/user', userAuthRoutes);
app.use('/api/users', userRoutes);
app.use('/api/support', require('./src/routes/supportRoutes'));
app.use('/api/admin/users', adminUserRoutes);
app.use('/api/admin/stats', adminStatsRoutes);
app.use('/api/upload', require('./src/routes/uploadRoutes'));

app.get('/', (req, res) => {
  res.json({ message: 'Pequire Backend API is running' });
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date(),
    version: '1.0.0'
  });
});

app.get('/api/config', (req, res) => {
  res.json({
    descopeProjectId: process.env.DESCOPE_PROJECT_ID || 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5',
    firebaseEnabled: !!process.env.FIREBASE_SERVICE_ACCOUNT_PATH,
    supportEmail: 'support@pequire.com'
  });
});

// Socket.io basic setup
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);
  
  // Mobile app joins a specific order room for tracking
  socket.on('join_order', (orderId) => {
    socket.join(orderId);
    console.log(`Socket ${socket.id} joined room: ${orderId}`);
  });

  // Provider joins their own private room to receive status updates / KYC notifications
  socket.on('join_provider', (providerId) => {
    socket.join(providerId.toString());
    console.log(`Socket ${socket.id} joined provider room: ${providerId}`);
  });

  // Providers broadcast their location to a specific order room
  socket.on('update_location', (data) => {
    const { orderId, latitude, longitude } = data;
    io.to(orderId).emit('location_received', { latitude, longitude, timestamp: new Date() });
    console.log(`Location updated for order ${orderId}: ${latitude}, ${longitude}`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Pequire Server running on port ${PORT}`);
});
