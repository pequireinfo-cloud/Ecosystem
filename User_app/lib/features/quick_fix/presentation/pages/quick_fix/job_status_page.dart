import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../../../../core/services/booking_service.dart';
import 'chat_page.dart';

class JobStatusPage extends StatefulWidget {
  final String bookingId;
  const JobStatusPage({super.key, required this.bookingId});

  @override
  State<JobStatusPage> createState() => _JobStatusPageState();
}

class _JobStatusPageState extends State<JobStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Job Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: BookingService().watchBooking(widget.bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Booking not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final progress = data['progress'] ?? 'started';
          final serviceType = data['serviceType'] ?? 'Service';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderCard(data),
                const SizedBox(height: 32),
                _buildStatusStepper(status, progress),
                const SizedBox(height: 32),
                const Text('SERVICE DETAILS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 16),
                _buildInfoCard(Icons.settings_suggest_outlined, 'Service', serviceType),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.location_on_outlined, 'Location', data['address'] ?? 'Nearby'),
                const SizedBox(height: 32),
                if (status == 'completed' || progress.contains('photo'))
                  _buildPhotoVerification(data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.person, size: 30, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Professional Assigned', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('Ramesh Kumar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(bookingId: widget.bookingId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String status, String progress) {
    int currentStep = 0;
    if (status == 'accepted') currentStep = 1;
    if (progress == 'arrived') currentStep = 2;
    if (progress.contains('working') || progress.contains('photo')) currentStep = 3;
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
        Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey[300]),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: isDone ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _stepperDivider(bool isDone) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 24,
      width: 2,
      color: isDone ? Colors.green : Colors.grey[200],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoVerification(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUALITY VERIFICATION', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(
          children: [
            _photoPreview('Before', data['progress']?.contains('before') ?? false),
            const SizedBox(width: 16),
            _photoPreview('After', data['status'] == 'completed'),
          ],
        ),
      ],
    );
  }

  Widget _photoPreview(String label, bool isAvailable) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: isAvailable 
                ? const Icon(Icons.image, color: Colors.green, size: 30)
                : const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
