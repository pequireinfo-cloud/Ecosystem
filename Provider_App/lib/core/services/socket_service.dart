import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect() {
    // Replace with your server IP if not running on localhost/emulator
    // For Android Emulator, use 10.0.2.2
    // For physical device, use the server's local IP (e.g., 192.168.x.x)
    const String serverUrl = 'http://10.46.122.48:4000'; 

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

  void joinOrder(String orderId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_order', orderId);
      debugPrint('Joined order room: $orderId');
    }
  }

  void updateLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double heading = 0.0,
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('update_location', {
        'orderId': orderId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
      });
      debugPrint('Sent location update for $orderId: $latitude, $longitude');
    }
  }

  void disconnect() {
    socket?.disconnect();
  }
}
