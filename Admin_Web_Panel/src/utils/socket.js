import { io } from 'socket.io-client';

// Use the production URL for the socket connection
const socket = io('https://api.pequire.com', { transports: ['websocket'] });

export default socket;

