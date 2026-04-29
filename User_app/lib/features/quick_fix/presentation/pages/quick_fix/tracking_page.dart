import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';

class TrackingPage extends StatelessWidget {
  final BookingSession session;

  const TrackingPage({super.key, required this.session});

  bool get _isLaundry => session.category == 'Laundry & Dry Clean';

  @override
  Widget build(BuildContext context) {
    return QuickFixBaseLayout(
        title: 'Booking Confirmed',
        onBack: () => Navigator.of(context).popUntil((route) => route.isFirst),
        initialSheetSize: 0.8,
        background: GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(28.6139, 77.2090), zoom: 14),
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: BookingService().watchBooking(session.bookingId ?? ''),
          builder: (context, snapshot) {
            final data = snapshot.data ?? {};
            final provider = data['providerId'] as Map<String, dynamic>?;
            final providerName = provider?['fullName'] ?? 'Professional';
            final arrivalOtp = data['arrivalOtp'] ?? '----';
            final status = data['status'] ?? 'accepted';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Arrival Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Provider arriving in', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Estimating...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                        child: Text('OTP: $arrivalOtp', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      )
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Provider Details
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(providerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const Text(' 5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(' (New Partner)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.1)),
                        child: IconButton(icon: const Icon(Icons.call, color: AppColors.primary), onPressed: () {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Vehicle & Booking
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.two_wheeler_rounded, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider?['serviceType'] ?? 'Service Provider', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(status.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Estimate & Job Details
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Job Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Category', session.category),
                  if (!_isLaundry) ...[
                    _buildDetailRow('Problem', session.selectedProblem ?? 'Unknown'),
                    _buildDetailRow('Appliance', session.selectedAppliance ?? 'Unknown'),
                  ] else ...[
                    _buildDetailRow('Items', '${session.numberOfClothes} Clothes'),
                  ],
                  const Divider(height: 32),
                  _buildDetailRow('Estimated Cost', _isLaundry ? '\$${((session.numberOfClothes ?? 1) * 12) + 20}' : '\$80+', isBold: true),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
        ),
      );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}

