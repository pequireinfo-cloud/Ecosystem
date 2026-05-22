import { io } from 'socket.io-client';

// Use the production URL for the socket connection
const socket = io('https://api.pequire.com');

export default socket;

