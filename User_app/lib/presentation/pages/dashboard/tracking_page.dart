import 'dart:async';
import 'package:flutter/material.dart';
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

class _TrackingPageState extends State<TrackingPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  StreamSubscription? _trackingSubscription;
  Offset _currentProPosition = const Offset(0.2, 0.2); // Default mock start
  final Offset _userPosition = const Offset(0.6, 0.7); // Static user pos
  int _remainingMinutes = 8;
  String _statusStatus = 'Connecting...';
  bool _hasReceivedUpdate = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTracking();
  }

  void _startTracking() {
    _trackingSubscription = sl<TrackingService>().listenToLocation(widget.orderId).listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        print('Location received from Firestore: $data');
        
        setState(() {
          _hasReceivedUpdate = true;
          _currentProPosition = _mapCoordsToUI(data['latitude'], data['longitude']);
          // Calculate minutes if needed (mocked for now)
          _remainingMinutes = 5; 
          _statusStatus = 'Tracking Live (Firestore)';
        });
      } else {
        setState(() => _statusStatus = 'Waiting for Provider...');
      }
    }, onError: (error) {
      setState(() => _statusStatus = 'Connection Error');
      print('Firestore Tracking Error: $error');
    });
  }

  // Helper to map real coords to our local painter (Demo only)
  Offset _mapCoordsToUI(double lat, double lon) {
    // This is a simple projection for the demo CUSTOM PAINTER
    // 192.168.1.7:3000 broadcast -> this listener
    return Offset(0.2 + (lat % 1), 0.2 + (lon % 1));
  }

  int _calculateTimeRemaining(double lat, double lon) {
    // Simulating time calculation
    return 5; 
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE5E7EB),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: MapPainter(proPos: _currentProPosition, userPos: _userPosition),
          ),
          
          Positioned(
            left: MediaQuery.of(context).size.width * _userPosition.dx - 20,
            top: MediaQuery.of(context).size.height * _userPosition.dy - 20,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          Positioned(
            left: MediaQuery.of(context).size.width * _currentProPosition.dx - 15,
            top: MediaQuery.of(context).size.height * _currentProPosition.dy - 15,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
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
                      !_hasReceivedUpdate ? 'Waiting for Provider...' : 'Coming in $_remainingMinutes mins',
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

class MapPainter extends CustomPainter {
  final Offset proPos;
  final Offset userPos;

  MapPainter({required this.proPos, required this.userPos});

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      canvas.drawLine(Offset(0, i * 60.0), Offset(size.width, i * 60.0), dashPaint);
      canvas.drawLine(Offset(i * 60.0, 0), Offset(i * 60.0, size.height), dashPaint);
    }

    final proMarkerPaint = Paint()..color = Colors.orange;
    canvas.drawCircle(Offset(size.width * proPos.dx, size.height * proPos.dy), 10, proMarkerPaint);
    proMarkerPaint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * proPos.dx, size.height * proPos.dy), 4, proMarkerPaint);

    final userMarkerPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * userPos.dx, size.height * userPos.dy), 10, userMarkerPaint);
    userMarkerPaint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * userPos.dx, size.height * userPos.dy), 4, userMarkerPaint);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => 
      oldDelegate.proPos != proPos || oldDelegate.userPos != userPos;
}
