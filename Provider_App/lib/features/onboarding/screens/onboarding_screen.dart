import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pequire_provider_app/core/constants/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  final List<_Slide> _slides = const [
    _Slide(
      image: 'assets/images/onboarding_1.webp',
      title: 'Get Jobs Instantly',
      subtitle: 'Receive real-time service requests from customers near you',
      gradient: [Color(0xFF025EF3), Color(0xFF0142A8)],
    ),
    _Slide(
      image: 'assets/images/onboarding_2.webp',
      title: 'Earn on Your Terms',
      subtitle: 'Set your own hours and work when it suits you best',
      gradient: [Color(0xFF059669), Color(0xFF047857)],
    ),
    _Slide(
      image: 'assets/images/onboarding_3.webp',
      title: 'Get Paid Fast',
      subtitle: 'Instant payments directly to your bank after every job',
      gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _slides[_page].gradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // New Brand Group
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logos/logo.webp',
                            height: 28,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/logos/wordmark.webp',
                            height: 20,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      // Skip
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Skip',
                            style: AppTypography.label.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final slide = _slides[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Illustration in white circle
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    slide.image,
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, e, s) => Icon(
                                      Icons.work_outline_rounded,
                                      size: 80,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Title
                            Text(
                              slide.title,
                              style: AppTypography.h1.copyWith(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            // Subtitle
                            Text(
                              slide.subtitle,
                              style: AppTypography.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 15,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom: Dots + Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Page Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // CTA Button
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _page == _slides.length - 1 ? 'Get Started' : 'Continue',
                              style: AppTypography.label.copyWith(
                                color: _slides[_page].gradient[0],
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
    );
  }
}

class _Slide {
  final String image;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  const _Slide({required this.image, required this.title, required this.subtitle, required this.gradient});
}





