import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          PequireAppBar(
            title: 'Notifications',
            actions: [
              GestureDetector(
                onTap: () {
                  // Optional: Implement Clear All
                },
                child: Text('Clear All', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Failed to load notifications: $error', style: const TextStyle(color: Colors.red)),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final isRead = notif['isRead'] ?? false;
                    final date = DateTime.parse(notif['createdAt']).toLocal();
                    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

                    return GestureDetector(
                      onTap: () {
                        if (!isRead) {
                          ref.read(markNotificationReadProvider)(notif['_id']);
                        }
                      },
                      child: _notifItem(
                        Icons.notifications,
                        isRead ? Colors.grey : Colors.blue,
                        isRead ? Colors.grey.shade100 : Colors.blue.shade50,
                        notif['title'] ?? 'Alert',
                        notif['body'] ?? '',
                        dateStr,
                        !isRead,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
                    Expanded(
                      child: Text(
                        title, 
                        style: AppTypography.label.copyWith(
                          fontSize: 14, 
                          color: const Color(0xFF0F172A),
                          fontWeight: unread ? FontWeight.bold : FontWeight.normal
                        )
                      )
                    ),
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
