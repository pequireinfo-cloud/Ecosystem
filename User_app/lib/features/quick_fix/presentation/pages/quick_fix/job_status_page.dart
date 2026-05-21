import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/diagnosis_approval_panel.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/chat_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/tracking_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/payment_page.dart';

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
        child: StreamBuilder<Map<String, dynamic>>(
          stream: BookingService().watchBooking(widget.session.bookingId ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ));
            }
            if (!snapshot.hasData) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('Connecting to service...'),
              ));
            }
  
            final data = snapshot.data!;
            final status = data['status'] ?? 'pending';
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
                  else if (status == 'diagnosing')
                    _buildDiagnosingStatus()
                  else if (status == 'waiting_approval' && diagnosis != null)
                    DiagnosisApprovalPanel(
                      bookingId: widget.session.bookingId ?? 'mock_id',
                      appliance: diagnosis['appliance'] ?? 'Appliance',
                      problem: diagnosis['problem'] ?? 'Problem',
                      finalPrice: finalPrice,
                    )
                  else if (status == 'working')
                    _buildWorkingStatus(data)
                  else
                    _buildDefaultStatus(status),
  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      );
  }

  Widget _buildArrivalStatus(Map<String, dynamic> data) {
    final otp = data['arrivalOtp'] ?? '----';
    final formattedOtp = otp.split('').join(' ');

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
              Text(
                formattedOtp,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Color(0xFF001233)),
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

  Widget _buildWorkingStatus(Map<String, dynamic> data) {
    final otp = data['workOtp'] ?? '----';
    final formattedOtp = otp.split('').join(' ');

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
              Text(formattedOtp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 6, color: Color(0xFF001233))),
              const SizedBox(height: 12),
              const Text('Share this only once the work is completed to your satisfaction', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> data) {
    final provider = data['providerId'] as Map<String, dynamic>?;
    final providerName = provider?['fullName'] ?? 'Professional';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(providerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001233))),
                const Text('Verified Professional', style: TextStyle(color: Colors.grey, fontSize: 12)),
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

  Widget _buildStatusStepper(String status) {
    int currentStep = 0;
    if (status == 'accepted') currentStep = 1;
    if (status == 'diagnosing' || status == 'waiting_approval') currentStep = 2;
    if (status == 'working') currentStep = 3;
    if (status == 'completed') currentStep = 4;

    return Column(
      children: [
        _stepperRow('Request Confirmed', currentStep >= 0),
        _stepperDivider(currentStep > 0),
        _stepperRow('Professional Assigned', currentStep >= 1),
        _stepperDivider(currentStep > 1),
        _stepperRow('Arrived & Diagnosing', currentStep >= 2),
        _stepperDivider(currentStep > 2),
        _stepperRow('Service in Progress', currentStep >= 3),
        _stepperDivider(currentStep > 3),
        _stepperRow('Job Completed', currentStep >= 4),
      ],
    );
  }

  Widget _buildDefaultStatus(String status) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildStatusStepper(status),
      ],
    );
  }

  Widget _stepperRow(String label, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? Colors.green : Colors.grey.shade300,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDone ? const Color(0xFF001233) : Colors.grey,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _stepperDivider(bool isDone) {
    return Container(
      margin: const EdgeInsets.only(left: 9),
      height: 20,
      width: 2,
      color: isDone ? Colors.green : Colors.grey.shade200,
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


