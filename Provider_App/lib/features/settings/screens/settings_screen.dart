import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifs = true;
  bool _jobAlerts = true;
  bool _paymentAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _sectionLabel('NOTIFICATIONS'),
                _card([
                  _toggleRow('Push Notifications', 'Receive push notifications', _pushNotifs, (v) => setState(() => _pushNotifs = v)),
                  _divider(),
                  _toggleRow('Job Alerts', 'Get notified for new job requests', _jobAlerts, (v) => setState(() => _jobAlerts = v)),
                  _divider(),
                  _toggleRow('Payment Alerts', 'Notifications for payments', _paymentAlerts, (v) => setState(() => _paymentAlerts = v)),
                ]),

                _sectionLabel('PREFERENCES'),
                _card([
                  _navRow('Language', 'English'),
                  _divider(),
                  _navRow('Theme', 'System Default'),
                ]),

                _sectionLabel('ABOUT'),
                _card([
                  _navRow('Terms of Service', null),
                  _divider(),
                  _navRow('Privacy Policy', null),
                  _divider(),
                  _navRow('Community Guidelines', null),
                ]),

                const SizedBox(height: 20),
                Center(child: Text('Version 1.0.0', style: AppTypography.bodySmall.copyWith(color: const Color(0xFFCBD5E1)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 0, 10),
    child: Text(text, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );

  Widget _divider() => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: Color(0xFFF8FAFC)));

  Widget _toggleRow(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(sub, style: AppTypography.bodySmall.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }

  Widget _navRow(String title, String? value) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(title, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A))),
            const Spacer(),
            if (value != null) Text(value, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE2E8F0)),
          ],
        ),
      ),
    );
  }
}
