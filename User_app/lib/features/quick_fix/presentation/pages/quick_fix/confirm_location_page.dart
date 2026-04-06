import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'searching_provider_page.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'payment_page.dart';

class ConfirmLocationPage extends StatefulWidget {
  final bool isWaitAndSave;
  final List<String> imageUrls;
  final String notes;
  final String serviceType;
  final int suggestedPrice;
  const ConfirmLocationPage({
    super.key, 
    this.isWaitAndSave = false,
    this.imageUrls = const [],
    this.notes = '',
    this.serviceType = 'Plumbing',
    this.suggestedPrice = 500,
  });

  @override
  State<ConfirmLocationPage> createState() => _ConfirmLocationPageState();
}

class _ConfirmLocationPageState extends State<ConfirmLocationPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090);
  String _addressLine1 = 'Fetching location...';
  String _addressLine2 = '';
  bool _isLoadingLocation = true;
  
  String _selectedSchedule = 'ASAP'; // 'ASAP' or 'Scheduled'
  
  // Form controllers
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _addressLine1 = 'Location services disabled';
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _addressLine1 = 'Permission denied';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addressLine1 = 'Current Location';
        _addressLine2 = 'Tap to refine';
        _isLoadingLocation = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 16));
    }
  }

  @override
  void dispose() {
    _flatController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Section (Full background top half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) {
                    _currentPosition = position.target;
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapToolbarEnabled: false,
                ),
                // Gradient Overlay for AppBar visibility
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Center Marker
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                             Text(
                              _addressLine1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _addressLine2,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36), // Offset for marker tip
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Confirm Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Location Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SERVICE LOCATION',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '123, Green Park',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'New Delhi, 110016',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Inputs
                    const Text(
                      'House / Flat No.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _flatController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Flat 4B, 2nd Floor',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Landmark',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                         Text(
                          'Optional',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _landmarkController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Near City Mall',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.directions, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Schedule Section
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'When do you need service?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSchedule = 'ASAP'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                 color: _selectedSchedule == 'ASAP' 
                                   ? AppColors.primary.withOpacity(0.05) 
                                   : Colors.white,
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(
                                   color: _selectedSchedule == 'ASAP' 
                                     ? AppColors.primary 
                                     : Colors.grey[200]!,
                                   width: 2,
                                 ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bolt, 
                                    color: _selectedSchedule == 'ASAP' ? AppColors.primary : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ASAP',
                                    style: TextStyle(
                                      color: _selectedSchedule == 'ASAP' ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '~45 mins',
                                    style: TextStyle(
                                      color: _selectedSchedule == 'ASAP' ? AppColors.primary : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSchedule = 'Scheduled'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                 color: _selectedSchedule == 'Scheduled' 
                                   ? AppColors.primary.withOpacity(0.05) 
                                   : Colors.white,
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(
                                   color: _selectedSchedule == 'Scheduled' 
                                     ? AppColors.primary 
                                     : Colors.grey[200]!,
                                   width: 2,
                                 ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today, 
                                    color: _selectedSchedule == 'Scheduled' ? AppColors.primary : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Schedule',
                                    style: TextStyle(
                                      color: _selectedSchedule == 'Scheduled' ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Select Time',
                                    style: TextStyle(
                                      color: _selectedSchedule == 'Scheduled' ? AppColors.primary : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoadingLocation ? null : () async {
                          // Create booking in Firestore
                          try {
                            final bookingId = await BookingService().createBooking(
                              userId: 'test_user_123', // Static for now
                              serviceType: widget.serviceType,
                              lat: _currentPosition.latitude,
                              lng: _currentPosition.longitude,
                              address: '${_flatController.text}, ${_landmarkController.text}',
                              estimatedPrice: widget.suggestedPrice.toDouble(),
                              imageUrls: widget.imageUrls,
                              isWaitAndSave: widget.isWaitAndSave,
                            );

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchingProviderPage(bookingId: bookingId),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booking failed: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm & Proceed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                     const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
