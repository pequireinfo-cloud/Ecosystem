import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pequire_provider_app/core/providers/locale_provider.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          PequireAppBar(title: l10n.language),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _languageItem(ref, l10n.english, const Locale('en'), currentLocale.languageCode == 'en'),
                const SizedBox(height: 12),
                _languageItem(ref, l10n.hindi, const Locale('hi'), currentLocale.languageCode == 'hi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageItem(WidgetRef ref, String title, Locale locale, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).state = locale,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Text(title, style: AppTypography.label.copyWith(fontSize: 16, color: const Color(0xFF0F172A))),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
