import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pequire_provider_app/core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifs = true;
  bool _jobAlerts = true;
  bool _paymentAlerts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          PequireAppBar(title: l10n.settings),
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

                _sectionLabel(l10n.profile),
                _card([
                  _navRow(l10n.language, Localizations.localeOf(context).languageCode == 'en' ? l10n.english : l10n.hindi, onTap: () => context.push('/language-selection')),
                  _divider(),
                  _navRow('Theme', ref.watch(themeModeProvider) == ThemeMode.light ? 'Light' : 'Dark', onTap: () {
                    final current = ref.read(themeModeProvider);
                    ref.read(themeModeProvider.notifier).state = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                  }),
                ]),

                _sectionLabel('ABOUT'),
                _card([
                  _navRow('Terms of Service', null),
                  _divider(),
                  _navRow('Privacy Policy', null),
                  _divider(),
                  _navRow('Community Guidelines', null),
                ]),

                _sectionLabel('SESSION'),
                _card([
                  _logoutRow(context),
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

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 24),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 12, 
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : const Color(0xFF64748B), 
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(children: children),
    );
  }

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

  Widget _navRow(String title, String? value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(title, style: AppTypography.label.copyWith(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            if (value != null) Text(value, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE2E8F0)),
          ],
        ),
      ),
    );
  }

  Widget _logoutRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(l10n.logout, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }
}
