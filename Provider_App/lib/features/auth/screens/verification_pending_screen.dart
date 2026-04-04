import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Brand Identity
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logos/logo.png',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/logos/Wordmark.png',
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Progress Track (Step 4 of 4)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STEP 4 OF 4',
                              style: AppTypography.label.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(true),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Content Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Review in Progress',
                            style: AppTypography.h1.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'We are reviewing your profile. This usually takes 24–48 hours for premium quality checks.',
                              style: AppTypography.body.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Feature Highlight (Complexity Element)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          _benefitRow(Icons.bolt_rounded, 'Priority Job Access'),
                          const SizedBox(height: 12),
                          _benefitRow(Icons.verified_user_rounded, 'Trusted Badge'),
                          const SizedBox(height: 12),
                          _benefitRow(Icons.account_balance_wallet_rounded, 'Daily Payouts'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Simulating a refresh check with Firebase
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checking verification status...'),
                          backgroundColor: Color(0xFF0F172A),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await Future.delayed(const Duration(milliseconds: 1500));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification still in progress.'), backgroundColor: Colors.orangeAccent),
                        );
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text(
                              'Check Status Now',
                              style: AppTypography.h3.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Return to Dashboard',
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
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
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _progressSegment(bool active) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
