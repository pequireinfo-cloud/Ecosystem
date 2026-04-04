import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../../../../core/services/socket_service.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  static const LatLng _center = LatLng(28.6139, 77.2090);
  GoogleMapController? _mapController;
  LatLng? _providerLocation;
  final String _orderId = "demo_order_123"; // Dummy ID for "as is" testing
  
  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  void _setupSocket() {
    SocketService().connect();
    SocketService().joinOrder(_orderId, (data) {
      if (mounted) {
        setState(() {
          _providerLocation = LatLng(
            data['latitude'] as double,
            data['longitude'] as double,
          );
        });
        
        // Optionally animate camera to provider if they are the focus
        if (_providerLocation != null && _mapController != null) {
          // _mapController!.animateCamera(CameraUpdate.newLatLng(_providerLocation!));
        }
      }
    });
  }

  @override
  void dispose() {
    SocketService().disconnect();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Map
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 16.0,
            ),
            markers: {
              if (_providerLocation != null)
                Marker(
                  markerId: const MarkerId('provider_location'),
                  position: _providerLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: 'Provider Location'),
                ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
          ),
          
          // Custom Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Navigate back to home or dashboard
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ),
          
          // ETA Card
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ARRIVING IN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '10 min',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Detail Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Provider Info
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person, color: Colors.grey, size: 30),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Ramesh Kumar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                             Text(
                              'Plumbing Expert • 4.8 ★',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'OTP',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '4829',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {}, // Call functionality
                          icon: const Icon(Icons.call, size: 20),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.green),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {}, // Chat functionality
                          icon: const Icon(Icons.message, size: 20),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Status Timeline (Simplified)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 12, color: AppColors.primary),
                        Container(width: 40, height: 2, color: AppColors.primary),
                        const Icon(Icons.circle, size: 12, color: AppColors.primary),
                        Container(width: 40, height: 2, color: Colors.grey[300]),
                        Icon(Icons.circle, size: 12, color: Colors.grey[300]),
                         const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'On the way to your location',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
