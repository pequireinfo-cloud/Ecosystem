import { io } from 'socket.io-client';

// Use the machine's local IP for the socket connection
const socket = io('http://10.46.122.48:3000');

export default socket;
