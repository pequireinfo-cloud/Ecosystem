import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';

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
      if (ApiConfig.currentProviderId != null) {
        joinProvider(ApiConfig.currentProviderId!);
      }
    });

    socket!.onDisconnect((_) {
      debugPrint('Disconnected from backend socket');
    });

    socket!.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });
  }

  void joinProvider(String providerId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_provider', providerId);
      debugPrint('Joined provider room: $providerId');
    }
  }

  void listenToKycUpdates(Function(Map<String, dynamic>) onUpdate) {
    if (socket != null) {
      socket!.off('kyc_status_updated'); // Remove any old listener first
      socket!.on('kyc_status_updated', (data) {
        debugPrint('Socket received kyc_status_updated: $data');
        if (data is Map) {
          onUpdate(Map<String, dynamic>.from(data));
        }
      });
    }
  }

  void stopListeningToKycUpdates() {
    socket?.off('kyc_status_updated');
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
