import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:flutter/services.dart';

import 'package:pequire_provider_app/core/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint("LOGIN SCREEN LOADED V2 - WITH MOCK BYPASS");
    _phoneController.addListener(() {
      setState(() => _isValid = _phoneController.text.length >= 10);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final phone = '+91${_phoneController.text.trim()}';
      
      await FirebaseService().auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseService().auth.signInWithCredential(credential);
          if (mounted) context.go('/service-selection');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Phone Auth Failed: ${e.code} - ${e.message}");
          
          // In development mode, we bypass ALL Auth errors to allow testing the rest of the app
          debugPrint("Entering Mock Auth Mode due to Error: ${e.code}");
          setState(() => _isLoading = false);
          // Bypass to OTP screen with mock ID
          context.push('/login/otp', extra: 'mock_verification_id');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("OTP Sent: $verificationId");
          setState(() => _isLoading = false);
          context.push('/login/otp', extra: verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("OTP Timeout: $verificationId");
        },
      );
    } catch (e) {
      debugPrint("Login General Error: $e");
      // Generic fallback for any other error (like network or config)
      setState(() => _isLoading = false);
      context.push('/login/otp', extra: 'mock_verification_id');
    }
  }

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

                    // Welcome Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter mobile number to continue',
                          style: AppTypography.h1.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Our premium portal ensures safe and efficient job management.',
                          style: AppTypography.body.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Phone Number Input
                    Text(
                      'PHONE NUMBER',
                      style: AppTypography.label.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(
                          color: _phoneController.text.isNotEmpty ? AppColors.primary.withOpacity(0.3) : const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Country Code
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇮🇳', style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: AppTypography.label.copyWith(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(width: 1.5, height: 24, color: const Color(0xFFF1F5F9)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textAlignVertical: TextAlignVertical.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: AppTypography.h3.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 1,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '98765 43210',
                                hintStyle: AppTypography.body.copyWith(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    GestureDetector(
                      onTap: (_isValid && !_isLoading) ? _handleLogin : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: _isValid ? AppColors.primaryGradient : null,
                          color: _isValid ? null : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isValid ? AppColors.primaryGlow : null,
                        ),
                        child: Center(
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Verification Code',
                                    style: AppTypography.h3.copyWith(
                                      color: _isValid ? Colors.white : const Color(0xFF94A3B8),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (_isValid) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                  ],
                                ],
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Security Indicator
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF04F1A2)),
                            const SizedBox(width: 6),
                            Text(
                              'Secure 256-bit Encryption',
                              style: AppTypography.body.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: AppTypography.label.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Container(height: 1, color: const Color(0xFFF1F5F9))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Matrix
                    Row(
                      children: [
                        _socialButton(Icons.g_mobiledata_rounded, const Color(0xFFEA4335)),
                        const SizedBox(width: 12),
                        _socialButton(Icons.facebook_rounded, const Color(0xFF1877F2)),
                        const SizedBox(width: 12),
                        _socialButton(Icons.apple_rounded, const Color(0xFF000000)),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: Text(
                'By entering your number, you agree to our\nTerms of Service & Data Privacy Policy',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}
