import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/diagnosis_approval_panel.dart';
import 'chat_page.dart';
import 'tracking_page.dart';
import 'payment_page.dart';

class JobStatusPage extends StatefulWidget {
  final BookingSession session;
  const JobStatusPage({super.key, required this.session});

  @override
  State<JobStatusPage> createState() => _JobStatusPageState();
}

class _JobStatusPageState extends State<JobStatusPage> {
  @override
  Widget build(BuildContext context) {
    return QuickFixBaseLayout(
      title: 'Job Status',
      initialSheetSize: 0.8,
      background: TrackerMapContainer(session: widget.session),
      child: StreamBuilder<DocumentSnapshot>(
        stream: BookingService().watchBooking(widget.session.bookingId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('Booking details unavailable'),
            ));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final progress = data['progress'] ?? 'started';
          final diagnosis = data['diagnosis'] as Map<String, dynamic>?;
          final finalPrice = (data['finalPrice'] ?? 0.0).toDouble();

          // Handle Completion Navigation
          if (status == 'completed' && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => PaymentPage(session: widget.session))
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildProviderCard(data),
                const SizedBox(height: 24),
                
                // Dynamic Content based on Status
                if (status == 'accepted') 
                  _buildArrivalStatus(data)
                else if (status == 'at_location' || status == 'diagnosing')
                  _buildDiagnosingStatus()
                else if (status == 'waiting_approval' && diagnosis != null)
                  DiagnosisApprovalPanel(
                    bookingId: widget.session.bookingId!,
                    appliance: diagnosis['appliance'] ?? 'Appliance',
                    problem: diagnosis['problem'] ?? 'Problem',
                    finalPrice: finalPrice,
                  )
                else if (status == 'working')
                   _buildWorkingStatus()
                else
                  _buildDefaultStatus(status, progress),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                
                // SP Mock Buttons (Debug Only)
                _buildDebugMocks(data),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArrivalStatus(Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text('ARRIVAL OTP', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text(
                '4 2 3 1',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Color(0xFF001233)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Share this with the professional once they arrive at your door',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosingStatus() {
    return Column(
       children: [
         const SizedBox(height: 20),
         const Center(child: CircularProgressIndicator(strokeWidth: 2)),
         const SizedBox(height: 24),
         const Text(
           'Provider is Diagnosing...',
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001233)),
         ),
         const SizedBox(height: 8),
         const Text(
           'They are inspecting your appliance to find the root cause.',
           textAlign: TextAlign.center,
           style: TextStyle(color: Colors.grey, fontSize: 14),
         ),
       ],
    );
  }

  Widget _buildWorkingStatus() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text('REPAIR IN PROGRESS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 20),
              const Icon(Icons.build_circle_rounded, color: Colors.green, size: 48),
              const SizedBox(height: 20),
              const Text('WORK OTP', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('8 8 2 1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 6, color: Color(0xFF001233))),
              const SizedBox(height: 12),
              const Text('Share this only once the work is completed to your satisfaction', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultStatus(String status, String progress) {
    return _buildStatusStepper(status, progress);
  }

  Widget _buildProviderCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ramesh Kumar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001233))),
                Text('Verified Professional', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(bookingId: widget.session.bookingId ?? '')));
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          if (data['status'] == 'accepted') ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TrackingPage(session: widget.session)));
              },
              icon: const Icon(Icons.map_outlined, color: AppColors.primary),
              style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String status, String progress) {
    int currentStep = 0;
    if (status == 'accepted') currentStep = 1;
    if (status == 'at_location') currentStep = 2;
    if (status == 'working') currentStep = 3;
    if (status == 'completed') currentStep = 4;

    return Column(
      children: [
        _stepperRow('Request Confirmed', currentStep >= 0),
        _stepperDivider(currentStep > 0),
        _stepperRow('Professional Assigned', currentStep >= 1),
        _stepperDivider(currentStep > 1),
        _stepperRow('Arrived at Location', currentStep >= 2),
        _stepperDivider(currentStep > 2),
        _stepperRow('Service in Progress', currentStep >= 3),
        _stepperDivider(currentStep > 3),
        _stepperRow('Job Completed', currentStep >= 4),
      ],
    );
  }

  Widget _stepperRow(String label, bool isDone) {
    return Row(
      children: [
        Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isDone ? Colors.green : Colors.grey.shade300, size: 22),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: isDone ? const Color(0xFF001233) : Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _stepperDivider(bool isDone) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 20,
      width: 2,
      color: isDone ? Colors.green : Colors.grey.shade200,
    );
  }

  Widget _buildDebugMocks(Map<String, dynamic> data) {
    final status = data['status'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DEBUG: SP SIMULATOR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => BookingService().updateBookingStatus(widget.session.bookingId!, 'at_location'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0),
              child: const Text('SP: Arrived', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => BookingService().submitDiagnosis(
                bookingId: widget.session.bookingId!,
                applianceDetails: widget.session.category ?? 'Appliance',
                problemDescription: 'Motor bearing failure - Needs lubrication and part replacement',
                finalPrice: 850,
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0),
              child: const Text('SP: Diagnosed', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => BookingService().updateBookingStatus(widget.session.bookingId!, 'completed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0),
              child: const Text('SP: Finished', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}

class TrackerMapContainer extends StatelessWidget {
  final BookingSession session;
  const TrackerMapContainer({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(28.6139, 77.2090),
        zoom: 14,
      ),
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      circles: {
        Circle(
          circleId: const CircleId('service_area'),
          center: const LatLng(28.6139, 77.2090),
          radius: 500,
          fillColor: AppColors.primary.withOpacity(0.1),
          strokeColor: AppColors.primary.withOpacity(0.3),
          strokeWidth: 2,
        ),
      },
    );
  }
}


