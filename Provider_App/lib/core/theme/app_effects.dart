import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';

class AppEffects {
  // Brand Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [AppColors.deepBlue, Color(0xFF003366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [AppColors.teal, Color(0xFF00BFA5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> get standardShadow => [
        BoxShadow(
          color: AppColors.dark.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get tealGlow => [
        BoxShadow(
          color: AppColors.teal.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.dark.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
