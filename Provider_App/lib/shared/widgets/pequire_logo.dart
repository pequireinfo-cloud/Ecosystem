import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/logos/Logo.svg',
          height: height,
          fit: BoxFit.contain,
          colorFilter: !isLight ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
        ),
        SizedBox(width: height * 0.3),
        Flexible(
          child: SvgPicture.asset(
            'assets/images/logos/Wordmark.svg',
            height: height * 0.55,
            width: height * 0.55 * 5.26,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(wordmarkColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}
