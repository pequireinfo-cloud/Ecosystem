import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/core/services/tracking_service.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class TrackingPage extends StatefulWidget {
  final String serviceTitle;
  final String orderId;

  const TrackingPage({
    super.key,
    required this.serviceTitle,
    this.orderId = 'ORDER_123',
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription? _trackingSubscription;
  
  LatLng? _currentProPosition;
  final LatLng _userPosition = const LatLng(28.6139, 77.2090); // Default user position (Delhi)
  
  String _remainingTime = '--';
  String _statusStatus = 'Connecting...';
  bool _hasReceivedUpdate = false;
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _trackingSubscription = sl<TrackingService>().listenToLocation(widget.orderId).listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        print('Location received from Firestore: $data');
        
        setState(() {
          _hasReceivedUpdate = true;
          _currentProPosition = LatLng(data['latitude'], data['longitude']);
          
          if (data['heading'] != null) {
             _heading = (data['heading'] is int) ? (data['heading'] as int).toDouble() : data['heading'];
          }

          if (data['eta'] != null) {
             _remainingTime = data['eta'].toString();
          }

          _statusStatus = 'Provider on the way';
          
          _animateCameraToPro();
        });
      } else {
        setState(() => _statusStatus = 'Waiting for Provider...');
      }
    }, onError: (error) {
      setState(() => _statusStatus = 'Connection Error');
      print('Firestore Tracking Error: $error');
    });
  }

  Future<void> _animateCameraToPro() async {
    if (_currentProPosition == null) return;
    
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentProPosition!,
        zoom: 17,
        tilt: 45,
        bearing: _heading,
      ),
    ));
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          _buildInteractiveMap(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      'Tracking ${widget.serviceTitle}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildTrackingDetails(context),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('user_home'),
        position: _userPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Home'),
      ),
    };

    if (_currentProPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_car'),
          position: _currentProPosition!,
          rotation: _heading,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Technician'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    Set<Polyline> polylines = {};
    if (_currentProPosition != null) {
       polylines.add(
         Polyline(
           polylineId: const PolylineId('route_line'),
           color: AppColors.primary,
           width: 4,
           points: [_currentProPosition!, _userPosition],
         )
       );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE5E7EB),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _userPosition,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        markers: markers,
        polylines: polylines,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
      ),
    );
  }

  Widget _buildTrackingDetails(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.42,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      !_hasReceivedUpdate ? 'Waiting for Provider...' : 'Coming in $_remainingTime mins',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusStatus,
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      const Text('REAL-TIME', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Wilson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Professional Provider', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildActionButton(Icons.call_rounded, Colors.green),
                  const SizedBox(width: 12),
                  _buildActionButton(Icons.chat_bubble_rounded, AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
