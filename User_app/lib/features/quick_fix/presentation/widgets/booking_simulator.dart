import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/job_status_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/tracking_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/payment_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/rating_feedback_page.dart';

class BookingSimulator extends StatelessWidget {
  final BookingSession session;
  final Widget child;

  const BookingSimulator({super.key, required this.session, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!session.isSimulation) return child;

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 100,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: FloatingActionButton.extended(
              onPressed: () => _showSimulationMenu(context),
              label: const Text('Simulate Flow'),
              icon: const Icon(Icons.rocket_launch_rounded),
              backgroundColor: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showSimulationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UI Flow Simulator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF001233)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jump to any UI state to see the design',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildSimOption(context, 'Finding -> Tracking', Icons.location_on_rounded, () {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TrackingPage(session: session)));
              }),
              _buildSimOption(context, 'Tracking -> Job Status', Icons.build_circle_rounded, () {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobStatusPage(session: session)));
              }),
              _buildSimOption(context, 'Job Status -> Payment', Icons.payment_rounded, () {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentPage(session: session)));
              }),
              _buildSimOption(context, 'Payment -> Rating', Icons.star_rounded, () {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RatingFeedbackPage(session: session)));
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
