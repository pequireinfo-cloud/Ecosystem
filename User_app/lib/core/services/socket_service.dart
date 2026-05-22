import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect() {
    // Use production URL for socket connection
    const String serverUrl = 'https://api.pequire.com'; 

    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('Connected to backend socket');
    });

    socket!.onDisconnect((_) {
      debugPrint('Disconnected from backend socket');
    });

    socket!.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });
  }

  void joinOrder(String orderId, Function(Map<String, dynamic>) onLocationReceived) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_order', orderId);
      debugPrint('Joined order room: $orderId');

      socket!.on('location_received', (data) {
        debugPrint('Location received for $orderId: $data');
        onLocationReceived(Map<String, dynamic>.from(data));
      });
    }
  }

  void disconnect() {
    socket?.disconnect();
  }
}
