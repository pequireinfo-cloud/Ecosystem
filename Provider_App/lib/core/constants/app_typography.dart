import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Pequire Typography System (v3)
/// Primary: Plus Jakarta Sans — headings, labels, UI
/// Secondary: Inter — body text, stats, functional
class AppTypography {
  // ── HEADINGS (Plus Jakarta Sans) ──
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.03 * 26,
      );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.02 * 20,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.02 * 17,
      );

  static TextStyle get h4 => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.01 * 15,
      );

  // ── BODY (Inter) ──
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.gray,
      );

  // ── LABELS (Plus Jakarta Sans) ──
  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  // ── FUNCTIONAL (Inter) ──
  static TextStyle get formLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.proGray,
        letterSpacing: 0.07 * 11,
      );

  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.gray,
        letterSpacing: 0.1 * 10,
      );

  // ── CHIPS / STATS (Inter) ──
  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.02 * 11,
      );

  static TextStyle get stat => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  // ── BUTTON (Plus Jakarta Sans) ──
  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: -0.01 * 15,
      );

  // ── SECTION HEADER (Plus Jakarta Sans) ──
  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.01 * 15,
      );

  // ── SECTION LABEL / GROUP HEADER (Inter) ──
  static TextStyle get sectionLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.lgray,
        letterSpacing: 0.1 * 11,
      );

  // ── Compatibility aliases ──
  static TextStyle get monoTiny => eyebrow;
  static TextStyle get monoLabel => formLabel;
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: AppColors.gray,
        letterSpacing: 0.1 * 8,
      );
}
