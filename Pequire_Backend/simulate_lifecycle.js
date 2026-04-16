const axios = require('axios');
const mongoose = require('mongoose');
const Booking = require('./src/models/Booking');
const Provider = require('./src/models/Provider');

const BASE_URL = 'http://127.0.0.1:3000/api';

async function simulate() {
  try {
    await mongoose.connect('mongodb://localhost:27017/pequire');
    console.log('--- Simulation Started ---');

    const provider = await Provider.findOne({ email: 'rahul.sharma@example.com' });
    if (!provider) {
      console.error('Mock provider NOT FOUND. Seed the database first.');
      process.exit(1);
    }

    console.log(`Professional: ${provider.fullName} (${provider._id})`);

    console.log('Searching for active/pending bookings...');
    let booking = null;
    while (!booking) {
      // Look for pending or already accepted bookings to resume if necessary
      booking = await Booking.findOne({ status: { $in: ['pending', 'accepted'] } }).sort({ createdAt: -1 });
      if (!booking) {
        await new Promise(r => setTimeout(r, 2000));
      }
    }

    const bookingId = booking._id;
    console.log(`Found Booking: ${bookingId} (Status: ${booking.status})`);

    if (booking.status === 'pending') {
      console.log('Step 1: Accepting Booking...');
      await axios.put(`${BASE_URL}/bookings/${bookingId}/accept`, { providerId: provider._id });
      console.log('Accepted.');
      await new Promise(r => setTimeout(r, 5000));
    }

    // Refresh booking data
    booking = await Booking.findById(bookingId);
    
    if (booking.status === 'accepted') {
      console.log('Step 2: Verifying Arrival (OTP: ' + booking.arrivalOtp + ')...');
      await axios.post(`${BASE_URL}/bookings/${bookingId}/verify-arrival`, { otp: booking.arrivalOtp });
      console.log('Arrived.');
      await new Promise(r => setTimeout(r, 5000));
    }

    // Refresh
    booking = await Booking.findById(bookingId);
    if (booking.status === 'diagnosing' || booking.status === 'at_location') {
       console.log('Step 3: Submitting Diagnosis...');
       await axios.post(`${BASE_URL}/bookings/${bookingId}/diagnosis`, {
         appliance: 'Washing Machine',
         problem: 'Drain Pump Obstruction',
         solution: 'Cleared debris and tested flow',
         price: 1200
       });
       console.log('Diagnosis Submitted. Waiting for User Approval...');
    }

    while (booking.status !== 'working') {
      booking = await Booking.findById(bookingId);
      if (booking.status === 'working') break;
      await new Promise(r => setTimeout(r, 2000));
    }

    console.log('Diagnosis Approved! Proceeding to completion in 5s...');
    await new Promise(r => setTimeout(r, 5000));

    // Final Work OTP
    console.log('Step 4: Verifying Work Completion (OTP: ' + booking.workOtp + ')...');
    await axios.post(`${BASE_URL}/bookings/${bookingId}/verify-work`, { otp: booking.workOtp });
    console.log('Work Verified. Job Completed Successfully.');

    await mongoose.disconnect();
    console.log('--- Simulation Finished ---');
  } catch (err) {
    console.error('Simulation Error:', err.response ? err.response.data : err.message);
    process.exit(1);
  }
}

simulate();
