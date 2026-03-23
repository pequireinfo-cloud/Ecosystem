import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class ProviderTrackingBroadcast extends StatefulWidget {
  final String orderId;
  const ProviderTrackingBroadcast({super.key, required this.orderId});

  @override
  State<ProviderTrackingBroadcast> createState() => _ProviderTrackingBroadcastState();
}

class _ProviderTrackingBroadcastState extends State<ProviderTrackingBroadcast> {
  IO.Socket? socket;
  bool _isBroadcasting = false;
  Position? _currentPosition;
  String _status = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io(ApiConstants.socketServerUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );

    socket?.onConnect((_) {
      setState(() => _status = 'Connected');
      socket?.emit('join_order', widget.orderId);
    });

    socket?.onDisconnect((_) => setState(() => _status = 'Disconnected'));
  }

  Future<void> _toggleBroadcasting() async {
    if (_isBroadcasting) {
      setState(() => _isBroadcasting = false);
      return;
    }

    // Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      setState(() => _isBroadcasting = true);
      _startMockOrRealBroadcast();
    }
  }

  void _startMockOrRealBroadcast() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5)
    ).listen((Position position) {
      if (!_isBroadcasting) return;

      setState(() => _currentPosition = position);
      
      // Emit to server
      socket?.emit('update_location', {
        'orderId': widget.orderId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
      });
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Provider Broadcast Mode'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _isBroadcasting ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isBroadcasting ? Icons.radar_rounded : Icons.location_off_rounded,
                size: 80,
                color: _isBroadcasting ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isBroadcasting ? 'BROADCASTING LIVE' : 'BROADCAST PAUSED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isBroadcasting ? Colors.green : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text('Server Status: $_status', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            if (_currentPosition != null) ...[
              Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
              Text('Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _toggleBroadcasting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBroadcasting ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isBroadcasting ? 'STOP BROADCAST' : 'START BROADCAST'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
