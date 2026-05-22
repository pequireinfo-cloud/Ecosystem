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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 36,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No notifications yet',
                      style: AppTypography.h3.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You'll receive real-time alerts for booking requests, status changes, and earnings updates here.",
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
