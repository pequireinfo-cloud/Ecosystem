const express = require('express');
const cors = require('cors');
const http = require('http');
const path = require('path');
const { Server } = require('socket.io');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Export io for use in services
module.exports = { app, server, io };

// Middleware
app.use(cors());
app.use(express.json());
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
