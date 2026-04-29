import 'package:flutter/material.dart';

class PequireLogo extends StatelessWidget {
  final double height;
  final bool isLight;

  const PequireLogo({
    super.key,
    this.height = 32,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    // If isLight is true, we use dark colors for the wordmark (to be seen on light bg)
    // If isLight is false (default), we use white for the wordmark (to be seen on dark bg)
    final Color wordmarkColor = isLight ? const Color(0xFF1A1B2F) : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.webp',
          height: height,
        ),
        SizedBox(width: height * 0.375), // Proportional spacing
        Image.asset(
          'assets/wordmark.webp',
          height: height * 0.56, // Proportional height for text
          color: wordmarkColor,
        ),
      ],
    );
  }
}
