import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/auth/presentation/pages/login_page.dart';
import 'package:pequire_user_app/l10n/app_localizations.dart';
import 'package:pequire_user_app/core/widgets/pequire_logo.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<OnboardingContent> _contents = [
      OnboardingContent(
        title: l10n.onboarding1,
        image: 'assets/onboarding_pricing.webp',
      ),
      OnboardingContent(
        title: l10n.onboarding2,
        image: 'assets/onboarding_professionals.webp',
      ),
      OnboardingContent(
        title: l10n.onboarding3,
        image: 'assets/onboarding_snap_solve.webp',
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
              child: Row(
                children: [
                  const PequireLogo(height: 36, isLight: true),
                ],
              ),
            ),
            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _contents[index].image,
                          height: 320,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1B2F),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Row(
                children: [
                  // Skip Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text(
                      l10n.skip,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Page Indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _contents.length,
                      (index) => Container(
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _currentPage == index
                              ? AppColors.secondary
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _contents.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            value: (_currentPage + 1) / _contents.length,
                            strokeWidth: 3,
                            backgroundColor: AppColors.secondary.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.secondary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String image;

  OnboardingContent({
    required this.title,
    required this.image,
  });
}






