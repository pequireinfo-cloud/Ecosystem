import { io } from 'socket.io-client';

// Use dynamic socket URL or fallback
const socket = io(import.meta.env.VITE_SOCKET_URL || 'https://api.pequire.com', { transports: ['websocket'] });

export default socket;

