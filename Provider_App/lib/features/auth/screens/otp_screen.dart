import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:flutter/services.dart';

import 'package:pequire_provider_app/core/services/firebase_service.dart';

class OtpScreen extends StatefulWidget {
  final String? verificationId;
  const OtpScreen({super.key, this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _countdown = 30;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  bool get _allFilled => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (widget.verificationId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid session. Please try again.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final smsCode = _controllers.map((c) => c.text).join();
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: smsCode,
      );

      await FirebaseService().auth.signInWithCredential(credential);
      
      if (mounted) {
        context.go('/service-selection');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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

              // Back Button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 24),

              // Title Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Code',
                    style: AppTypography.h1.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Sent security code to '),
                        TextSpan(
                          text: '+91 98765 43210',
                          style: AppTypography.label.copyWith(
                            color: const Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // OTP Input Matrix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final hasValue = _controllers[index].text.isNotEmpty;
                  final hasFocus = _focusNodes[index].hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 64,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasFocus ? AppColors.primaryGlow : AppColors.softShadow,
                      border: Border.all(
                        color: hasFocus ? AppColors.primary : (hasValue ? AppColors.primary.withOpacity(0.3) : const Color(0xFFF1F5F9)),
                        width: hasFocus ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) {
                          setState(() {});
                          if (val.isNotEmpty && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                        style: AppTypography.h1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify & Continue Button
              GestureDetector(
                onTap: (_allFilled && !_isLoading) ? _verifyOtp : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _allFilled ? AppColors.primaryGradient : null,
                    color: _allFilled ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _allFilled ? AppColors.primaryGlow : null,
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Verify & Continue',
                          style: AppTypography.h3.copyWith(
                            color: _allFilled ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Resend Timer (Circular Premium feel)
              Center(
                child: Column(
                  children: [
                    if (!_canResend) ...[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: _countdown / 30,
                              strokeWidth: 3,
                              color: AppColors.primary.withOpacity(0.2),
                              backgroundColor: const Color(0xFFF1F5F9),
                            ),
                          ),
                          Text(
                            '$_countdown',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sec until resend',
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: _startCountdown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Resend Code',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Security Trust Badge
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF04F1A2)),
                    const SizedBox(width: 8),
                    Text(
                      'Trusted by 50,000+ Providers',
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
