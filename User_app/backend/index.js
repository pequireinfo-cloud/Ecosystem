const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

app.get('/', (req, res) => {
    res.send('Introviaa Real-Time Tracking Server is running!');
});

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    // Join a room based on Order ID
    socket.on('join_order', (orderId) => {
        socket.join(orderId);
        console.log(`Socket ${socket.id} joined room: ${orderId}`);
    });

    // Handle location updates from Provider
    socket.on('update_location', (data) => {
        // data: { orderId: string, latitude: number, longitude: number, heading: number }
        console.log(`Location update for ${data.orderId}:`, data.latitude, data.longitude);

        // Broadcast to everyone in the room (the User tracking this order)
        socket.to(data.orderId).emit('location_received', {
            latitude: data.latitude,
            longitude: data.longitude,
            heading: data.heading,
            timestamp: new Date().toISOString()
        });
    });

    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    });
});

const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server listening on http://0.0.0.0:${PORT}`);
});
