import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum PequireButtonVariant { primary, teal, green, red, outline, outlineGray, ghost, text }
enum PequireButtonSize { sm, md, lg }

class PequireButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PequireButtonVariant variant;
  final PequireButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool isPill;

  const PequireButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PequireButtonVariant.primary,
    this.size = PequireButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.isPill = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case PequireButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.white;
        break;
      case PequireButtonVariant.teal:
        backgroundColor = AppColors.teal;
        foregroundColor = AppColors.white;
        break;
      case PequireButtonVariant.green:
        backgroundColor = AppColors.green;
        foregroundColor = AppColors.white;
        break;
      case PequireButtonVariant.red:
        backgroundColor = AppColors.red;
        foregroundColor = AppColors.white;
        break;
      case PequireButtonVariant.outline:
        backgroundColor = AppColors.white;
        foregroundColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case PequireButtonVariant.outlineGray:
        backgroundColor = AppColors.white;
        foregroundColor = AppColors.ink;
        borderSide = const BorderSide(color: AppColors.lgray, width: 1.5);
        break;
      case PequireButtonVariant.ghost:
        backgroundColor = Colors.white.withValues(alpha: 0.12);
        foregroundColor = AppColors.white;
        borderSide = BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1);
        break;
      case PequireButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        break;
    }

    double height;
    TextStyle textStyle;
    double iconSize;
    EdgeInsets padding;

    switch (size) {
      case PequireButtonSize.sm:
        height = 40;
        textStyle = AppTypography.buttonText.copyWith(fontSize: 13, color: foregroundColor);
        iconSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        break;
      case PequireButtonSize.md:
        height = 48;
        textStyle = AppTypography.buttonText.copyWith(color: foregroundColor);
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
      case PequireButtonSize.lg:
        height = 54;
        textStyle = AppTypography.buttonText.copyWith(fontSize: 17, fontWeight: FontWeight.w800, color: foregroundColor);
        iconSize = 20;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: foregroundColor),
            const SizedBox(width: 8),
          ],
          Text(label, style: textStyle),
        ],
      ],
    );

    if (variant == PequireButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          textStyle: textStyle,
        ),
        child: content,
      );
    }

    final double radius = isPill ? AppRadius.pill : AppRadius.button;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding,
        ),
        child: content,
      ),
    );
  }
}
