import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';

class DiagnosisApprovalPanel extends StatelessWidget {
  final String bookingId;
  final String appliance;
  final String problem;
  final double finalPrice;

  const DiagnosisApprovalPanel({
    super.key,
    required this.bookingId,
    required this.appliance,
    required this.problem,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'DIAGNOSIS COMPLETE',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.devices_other_rounded, 'Appliance', appliance),
              const Divider(height: 32),
              _buildInfoRow(Icons.report_problem_outlined, 'Identified Issue', problem),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF001233),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FINAL QUOTATION', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                   SizedBox(height: 4),
                  Text('All inclusive price', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              Text(
                '₹${finalPrice.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await BookingService().approveDiagnosis(bookingId);
                if (context.mounted) Navigator.pop(context); // Close loading
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approval failed: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Approve & Start Work', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
             'SP will begin repair immediately after approval',
             style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001233), fontSize: 15)),
          ],
        ),
      ],
    );
  }
}
