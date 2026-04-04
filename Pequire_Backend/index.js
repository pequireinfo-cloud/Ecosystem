const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

const bookingRoutes = require('./src/routes/bookingRoutes');
const jobRoutes = require('./src/routes/spRoutes');

// Routes
app.use('/api/bookings', bookingRoutes);
app.use('/api/jobs', jobRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Pequire Backend API is running' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
