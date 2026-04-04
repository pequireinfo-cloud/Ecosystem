import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // Use a map to handle many toggles easily
  final Map<String, bool> _settings = {
    'General Notification': true,
    'Sound': true,
    'Vibrate': false,
    'Special Offers': true,
    'Promo & Discount': false,
    'Payments': true,
    'Cashback': false,
    'App Updates': true,
    'New Service Available': false,
    'New Tips Available': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: _settings.keys.map((title) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildRedesignedToggle(title, _settings[title]!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRedesignedToggle(String title, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: (val) => setState(() => _settings[title] = val),
            activeColor: Colors.white,
            activeTrackColor: AppColors.redesignPurple,
            inactiveTrackColor: Colors.grey.shade200,
            inactiveThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
