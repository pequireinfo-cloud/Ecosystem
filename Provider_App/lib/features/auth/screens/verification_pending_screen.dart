import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_logo.dart';

import 'package:pequire_provider_app/core/services/provider_service.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  String _status = 'In Review';
  String _rejectionReason = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final profile = await ProviderService().getProfile(ApiConfig.currentProviderId ?? "");
    if (profile != null) {
      setState(() {
        _status = profile['kycStatus'] ?? 'In Review';
        _rejectionReason = profile['rejectionReason'] ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                        const PequireLogo(height: 28, isLight: true),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            await ApiConfig.logout(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Progress Track
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VERIFICATION STATUS',
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
                            _progressSegment(_status == 'Verified'),
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
                              color: _status == 'Verified' ? const Color(0xFFECFDF5) : (_status == 'Rejected' ? const Color(0xFFFEF2F2) : const Color(0xFFF0F7FF)),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_status == 'Verified' ? Colors.green : (_status == 'Rejected' ? Colors.red : AppColors.primary)).withOpacity(0.08),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _status == 'Verified' ? Icons.check_circle_rounded : (_status == 'Rejected' ? Icons.error_rounded : Icons.hourglass_top_rounded), 
                                size: 48, 
                                color: _status == 'Verified' ? Colors.green : (_status == 'Rejected' ? Colors.red : AppColors.primary)
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            _status == 'Verified' ? 'Verification Complete!' : (_status == 'Rejected' ? 'Verification Failed' : 'Review in Progress'),
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
                              _status == 'Verified' 
                                ? 'Congratulations! Your profile has been verified. You can now start accepting jobs.' 
                                : (_status == 'Rejected' 
                                    ? 'Reason: $_rejectionReason\nPlease re-upload clear documents.' 
                                    : 'We are reviewing your profile. This usually takes 24–48 hours.'),
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

                    // Feature Highlight
                    if (_status != 'Rejected') Container(
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
                    onTap: _checkStatus,
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
                    onTap: () {
                      if (_status == 'Verified') {
                        context.go('/home');
                      } else if (_status == 'Rejected') {
                        context.push('/kyc');
                      } else {
                        context.go('/home'); // Allow browsing for now
                      }
                    },
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
                          _status == 'Rejected' ? 'Re-upload Documents' : 'Return to Dashboard',
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


