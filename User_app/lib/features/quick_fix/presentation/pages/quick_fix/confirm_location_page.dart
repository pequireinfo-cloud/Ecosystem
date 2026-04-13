import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'searching_provider_page.dart';

class ConfirmLocationPage extends StatefulWidget {
  final BookingSession session;
  final bool isWaitAndSave;
  final List<String> imageUrls;
  final String notes;
  final String serviceType;
  final int suggestedPrice;
  
  const ConfirmLocationPage({
    super.key, 
    required this.session,
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
      if (mounted) {
        setState(() {
          _addressLine1 = 'Location services disabled';
          _isLoadingLocation = false;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _addressLine1 = 'Permission denied';
            _isLoadingLocation = false;
          });
        }
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
    return QuickFixBaseLayout(
      title: 'Confirm Location',
      initialSheetSize: 0.8,
      background: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 16),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Location Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
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
                    child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SERVICE ADDRESS',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '123, Green Park',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001233)),
                        ),
                        Text(
                          'New Delhi, 110016',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Inputs
            const Text('House / Flat No.', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001233), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _flatController,
              decoration: InputDecoration(
                hintText: 'e.g. Flat 4B, 2nd Floor',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('Landmark (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001233), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                hintText: 'e.g. Near City Mall',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Schedule Section
            const Text('Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF001233))),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScheduleOption('ASAP', '~45 mins', Icons.bolt_rounded),
                const SizedBox(width: 16),
                _buildScheduleOption('Scheduled', 'Select Time', Icons.calendar_today_rounded),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoadingLocation ? null : () async {
                  try {
                    final bookingId = await BookingService().createBooking(
                      userId: 'test_user_123',
                      serviceType: widget.serviceType,
                      lat: _currentPosition.latitude,
                      lng: _currentPosition.longitude,
                      address: '${_flatController.text}, ${_landmarkController.text}',
                      estimatedPrice: widget.suggestedPrice.toDouble(),
                      imageUrls: widget.imageUrls,
                      isWaitAndSave: widget.isWaitAndSave,
                    );

                    widget.session.bookingId = bookingId;

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchingProviderPage(session: widget.session),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Confirm & Proceed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String label, String subtitle, IconData icon) {
    bool isSelected = _selectedSchedule == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSchedule = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: isSelected ? AppColors.primary.withOpacity(0.7) : Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

