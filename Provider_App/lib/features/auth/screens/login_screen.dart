import 'package:flutter/material.dart';
import 'package:descope/descope.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/services/api_service.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_logo.dart';
import 'dart:async';

import 'package:pequire_provider_app/core/services/provider_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '98765 43210');
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  int _resendSeconds = 28;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendSeconds = 28;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  void _onSendOtp() async {
    String phone = _phoneController.text.replaceAll(' ', '');
    if (phone.length < 10) return;
    
    setState(() => _isLoading = true);
    try {
      final fullPhone = '+91$phone';
      await Descope.otp.signUpOrIn(
        method: DeliveryMethod.sms,
        loginId: fullPhone,
      );
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to send OTP: $e");
    }
  }

  void _onVerifyOtp() async {
    String otp = _otpControllers.map((e) => e.text).join();
    if (otp.length < 6) return;
    
    setState(() => _isLoading = true);
    try {
      String phone = _phoneController.text.replaceAll(' ', '');
      final fullPhone = '+91$phone';
      final authResponse = await Descope.otp.verify(
        method: DeliveryMethod.sms,
        loginId: fullPhone,
        code: otp,
      );
      
      final session = DescopeSession.fromAuthenticationResponse(authResponse);
      Descope.sessionManager.manageSession(session);
      
      final response = await ApiService().post('auth/user/verify-descope', data: {
        'sessionToken': session.sessionToken.jwt,
        'role': 'provider',
        'phoneNumber': fullPhone,
      });

      if (response.data['success'] == true) {
        final providerId = response.data['user']['id'];
        final kycStatus = response.data['user']['kycStatus'];
        ApiConfig.currentProviderId = providerId;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_provider_id', providerId);
        
        // Fetch the provider profile to see what steps have been completed
        final profile = await ProviderService().getProfile(providerId);
        String step = 'service-selection';
        String kyc = kycStatus ?? 'Pending';
        
        if (profile != null) {
          kyc = profile['kycStatus'] ?? 'Pending';
          final List? expertise = profile['expertise'];
          final String? fullName = profile['fullName'];
          
          if (kyc == 'Verified') {
            step = 'home';
          } else if (kyc == 'In Review') {
            step = 'verification-pending';
          } else if (fullName != null && fullName != 'New Partner' && fullName.isNotEmpty) {
            step = 'kyc';
          } else if (expertise != null && expertise.isNotEmpty) {
            step = 'profile-setup';
          } else {
            step = 'service-selection';
          }
        }
        
        ApiConfig.kycStatus = kyc;
        ApiConfig.registrationStep = step;
        await prefs.setString('kyc_status', kyc);
        await prefs.setString('registration_step', step);

        if (mounted) {
          if (step == 'home') {
            context.go('/home');
          } else if (step == 'verification-pending') {
            context.go('/verification-pending');
          } else if (step == 'kyc') {
            context.go('/kyc');
          } else if (step == 'profile-setup') {
            context.go('/profile-setup');
          } else {
            context.go('/service-selection');
          }
        }
      }
    } catch (e) {
      _showError("OTP verification failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header logo
              const PequireLogo(height: 32, isLight: true),
              
              const SizedBox(height: 32),
              
              if (_isOtpSent) ...[
                // Back Button for OTP state
                GestureDetector(
                  onTap: () => setState(() => _isOtpSent = false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Main content
              _isOtpSent ? _buildOtpContent() : _buildPhoneContent(),

              const Spacer(),
              
              // Footer
              Center(
                child: Text(
                  _isOtpSent 
                    ? '' 
                    : 'By entering your number, you agree to our\nTerms of Service & Data Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                color: Color(0xFF025EF3),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Text('👋', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter mobile number to continue',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Our premium portal ensures safe and efficient job management.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'PHONE NUMBER',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '98765 43210',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator()
              : const Text(
                  'Get Verification Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Secure 256-bit Encryption',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(Icons.g_mobiledata, Colors.red),
            _buildSocialButton(Icons.facebook, Colors.blue),
            _buildSocialButton(Icons.apple, Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildOtpContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sent security code to +91 ${_phoneController.text}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBlock(index)),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator()
              : const Text(
                  'Verify & Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: _resendSeconds / 28,
                      strokeWidth: 2,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF025EF3)),
                    ),
                  ),
                  Text(
                    '$_resendSeconds',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF025EF3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Sec until resend',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Text(
                'Trusted by 50,000+ Providers',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBlock(int index) {
    return Container(
      width: 50,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _otpFocusNodes[index].hasFocus 
              ? const Color(0xFF025EF3) 
              : Colors.grey.shade200,
          width: _otpFocusNodes[index].hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _otpFocusNodes[index].hasFocus 
            ? [BoxShadow(color: const Color(0xFF025EF3).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
            : null,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else {
              _otpFocusNodes[index].unfocus();
              _onVerifyOtp();
            }
          } else {
            if (index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
          }
          setState(() {});
        },
      ),
    );
  }
}
