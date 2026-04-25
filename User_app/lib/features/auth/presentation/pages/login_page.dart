import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:pequire_user_app/features/auth/domain/entities/login_role.dart';
import 'package:pequire_user_app/features/home/presentation/pages/home_page.dart';
import 'package:pequire_user_app/presentation/pages/onboarding/otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  String _verificationId = '';
  String _selectedCountryCode = '+91';
  String _selectedFlag = '🇮🇳';

  final List<Map<String, String>> _countries = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget _buildCountryPicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, String>>(
              value: _countries.firstWhere((c) => c['code'] == _selectedCountryCode),
              icon: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              items: _countries.map((Map<String, String> country) {
                return DropdownMenuItem<Map<String, String>>(
                  value: country,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(country['flag']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          country['code']!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Map<String, String>? value) {
                if (value != null) {
                  setState(() {
                    _selectedCountryCode = value['code']!;
                    _selectedFlag = value['flag']!;
                  });
                }
              },
            ),
          ),
          Container(
            height: 24,
            width: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(user: state.user)),
            (route) => false,
          );
        } else if (state is OtpSent) {
          setState(() {
            _isOtpSent = true;
            _verificationId = state.verificationId;
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000814),
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/login_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            
            // Subtle Dark Overlay for contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      const Color(0xFF1A1B2F).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Top Logo & Back Button Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/logo.png', width: 32, height: 32),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'PEQUIRE.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isOtpSent)
                                    IconButton(
                                      onPressed: () => setState(() => _isOtpSent = false),
                                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                    ),
                                ],
                              ),
                              
                              const Spacer(),
                              
                              // Animated Content Area (Bottom Bottom)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isOtpSent ? _buildOtpView() : _buildPhoneView(),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Terms and Privacy
                              Center(
                                child: Column(
                                  children: const [
                                    Text(
                                      'By signing up, you agree to the Terms of Service',
                                      style: TextStyle(color: Colors.white30, fontSize: 11),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'and Data Processing Agreement',
                                      style: TextStyle(color: Colors.white30, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneView() {
    return Column(
      key: const ValueKey('phone_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your mobile\nnumber',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Phone Number',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              hintText: '98765 43210',
              prefixIcon: _buildCountryPicker(),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.contact_phone_rounded, color: AppColors.primary, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_phoneController.text.length >= 10) {
                final fullPhone = '$_selectedCountryCode${_phoneController.text.trim()}';
                context.read<AuthBloc>().add(SendOtp(fullPhone));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid phone number')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Get OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView() {
    return Column(
      key: const ValueKey('otp_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify your\nnumber',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Code is sent to $_selectedCountryCode ${_phoneController.text}',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 40),
        const Text(
          'Enter 6-digit OTP',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 18),
              hintText: '******',
              hintStyle: TextStyle(color: Colors.grey, letterSpacing: 8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_otpController.text.length == 6) {
                context.read<AuthBloc>().add(
                      VerifyOtp(
                        verificationId: _verificationId,
                        smsCode: _otpController.text,
                        role: 'user',
                      ),
                    );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the 6-digit verification code')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Verify & Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Resend Code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String? imageAsset;
  final IconData iconData;
  const SocialButton({super.key, this.imageAsset, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 3,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconData == Icons.g_mobiledata ? Colors.red : (iconData == Icons.facebook ? Colors.blue : Colors.black),
          size: 32,
        ),
      ),
    );
  }
}

