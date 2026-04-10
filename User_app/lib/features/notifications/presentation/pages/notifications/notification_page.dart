import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 24),
          _buildSectionHeader('Today'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            title: 'Payment Successful!',
            subtitle: 'You have made a services payment',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.grid_view_rounded,
            color: AppColors.accent,
            title: 'New Category Services!',
            subtitle: 'Now the plumbing service is available',
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Yesterday'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.card_giftcard_rounded,
            color: AppColors.secondary,
            title: 'Today\'s Special Offers',
            subtitle: 'You get a special promo today!',
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('December 22, 2024'),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            title: 'Credit Card Connected!',
            subtitle: 'Credit Card has been linked!',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.person_rounded,
            color: AppColors.accent,
            title: 'Account Setup Successful!',
            subtitle: 'Your account has been created!',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconWithDecoration(icon, color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithDecoration(IconData icon, Color color) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative dots
          ...List.generate(6, (index) {
            final random = Random(index);
            final angle = random.nextDouble() * 2 * pi;
            final radius = 28.0 + random.nextDouble() * 5;
            final size = 3.0 + random.nextDouble() * 3;
            return Transform.translate(
              offset: Offset(cos(angle) * radius, sin(angle) * radius),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.6),
                ),
              ),
            );
          }),
          // Main Icon Circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
