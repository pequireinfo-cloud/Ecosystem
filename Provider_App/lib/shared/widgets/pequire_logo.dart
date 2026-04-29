import 'package:flutter/material.dart';

class PequireLogo extends StatelessWidget {
  final double height;
  final bool isLight;

  const PequireLogo({
    super.key,
    this.height = 32,
    this.isLight = true,
  });

  @override
  Widget build(BuildContext context) {
    // For Provider App, most backgrounds are light (AppColors.bg is Color(0xFFF8FAFC))
    // So default isLight is true.
    final Color wordmarkColor = isLight ? const Color(0xFF01173B) : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logos/logo.webp',
          height: height,
        ),
        SizedBox(width: height * 0.375),
        Image.asset(
          'assets/images/logos/Wordmark.webp',
          height: height * 0.56,
          color: wordmarkColor,
        ),
      ],
    );
  }
}
