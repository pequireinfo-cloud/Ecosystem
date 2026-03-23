import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          PequireAppBar(
            title: 'Notifications',
            actions: [
              GestureDetector(
                onTap: () {},
                child: Text('Clear All', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                _sectionLabel('TODAY'),
                _notifItem(Icons.account_balance_wallet_rounded, const Color(0xFF059669), const Color(0xFFECFDF5), 'Payment Received', 'You received ₹480 for Electrical Repair with Priya S.', '2 min ago', true),
                _notifItem(Icons.star_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7), 'New Review', 'Priya S. gave you a 5-star review!', '10 min ago', true),
                _sectionLabel('YESTERDAY'),
                _notifItem(Icons.calendar_today_outlined, const Color(0xFF2563EB), const Color(0xFFDBEAFE), 'New Booking', 'Deepak P. scheduled for tomorrow 3 PM.', '1 hr ago', false),
                _notifItem(Icons.warning_amber_rounded, const Color(0xFFDC2626), const Color(0xFFFEE2E2), 'KYC Reminder', 'Complete your KYC verification to start earning.', '3 hrs ago', false),
                _sectionLabel('THIS WEEK'),
                _notifItem(Icons.bar_chart_rounded, const Color(0xFF7C3AED), const Color(0xFFF5F3FF), 'Weekly Summary', 'You earned ₹7,890 this week across 8 jobs. Great work!', '2 days ago', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 10),
    child: Text(text, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );

  Widget _notifItem(IconData icon, Color iconColor, Color bgColor, String title, String body, String time, bool unread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unread ? Border.all(color: AppColors.primary.withValues(alpha: 0.1)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A)))),
                    if (unread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF025EF3), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B), fontSize: 13, height: 1.4)),
                const SizedBox(height: 6),
                Text(time, style: AppTypography.bodySmall.copyWith(color: const Color(0xFFCBD5E1), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
