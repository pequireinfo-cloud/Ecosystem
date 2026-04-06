import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/searching_provider_page.dart';

class EmergencySOSPage extends StatefulWidget {
  const EmergencySOSPage({super.key});

  @override
  State<EmergencySOSPage> createState() => _EmergencySOSPageState();
}

class _EmergencySOSPageState extends State<EmergencySOSPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isFinding = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Real booking creation for Emergency
    _createEmergencyBooking();
  }

  Future<void> _createEmergencyBooking() async {
    try {
      // For SOS, we assume user is in the same location and needs immediate help
      final bookingId = await BookingService().createBooking(
        userId: 'test_user_123', // Static for now
        serviceType: 'Emergency',
        lat: 28.6139, // Default to New Delhi if geolocator is not wrapped here yet
        lng: 77.2090,
        address: 'Emergency SOS Request',
        estimatedPrice: 999, // Emergency premium
        isWaitAndSave: false,
      );

      if (mounted) {
        setState(() => _isFinding = false);
        // Optionally navigate to a special emergency tracking or existing searching page
        // Future.delayed(const Duration(seconds: 2), () {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchingProviderPage(bookingId: bookingId)));
        // });
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS failed: $e')));
         Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark urgent theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on_rounded, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'EMERGENCY MODE',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                        return Container(
                          width: 150 + (200 * progress),
                          height: 150 + (200 * progress),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(1 - progress),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent, blurRadius: 40, spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 60),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Text(
                _isFinding ? 'Dispatching Nearest Expert' : 'Professional Dispatched!',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isFinding 
                  ? 'We are scanning for professionals within 2 miles of your location for immediate help.'
                  : 'John Wilson is 3 minutes away. He has been given priority access to your request.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (!_isFinding)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Wilson', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Emergency Specialist', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
