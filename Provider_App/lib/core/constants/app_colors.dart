import 'package:flutter/material.dart';

/// Pequire Design System Colors (v3 — HTML Prototype Alignment)
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF025EF3);
  static const Color secondary = Color(0xFF01173B);
  static const Color accent = Color(0xFF04F1A2);

  // Semantic Aliases
  static const Color blue = primary;
  static const Color deep = secondary;
  static const Color navy = secondary;
  static const Color deepBlue = secondary;
  static const Color teal = accent;
  static const Color actionBlue = primary;

  // Neutrals
  static const Color ink = Color(0xFF000814);
  static const Color dark = ink;
  static const Color gray = Color(0xFF64748B);
  static const Color proGray = Color(0xFF475569);
  static const Color lgray = Color(0xFFCBD5E1);
  static const Color bg = Color(0xFFF5F9FF);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic Feedback
  static const Color green = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);

  // Compatibility
  static const Color error = red;
  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Soft Shadows for Depth
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
