import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // If isLight is true (light background), we use dark colors for the dark parts of the logo/wordmark
    // If isLight is false (dark background), we use white for the dark parts
    final Color visibilityColor = isLight ? const Color(0xFF01173B) : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/Logo.svg',
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => SizedBox(height: height, width: height, child: const CircularProgressIndicator(strokeWidth: 2)),
          colorFilter: !isLight ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
        ),
        SizedBox(width: height * 0.3),
        Flexible(
          child: SvgPicture.asset(
            'assets/Wordmark.svg',
            height: height * 0.55,
            width: height * 0.55 * 5.26, 
            fit: BoxFit.contain,
            placeholderBuilder: (context) => const Text('PEQUIRE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            colorFilter: ColorFilter.mode(visibilityColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}
