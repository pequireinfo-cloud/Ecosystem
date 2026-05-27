import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:pequire_user_app/features/home/presentation/pages/home_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:pequire_user_app/core/widgets/pequire_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController(text: '98765 43210');
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.name == 'New User' || state.user.name.isEmpty) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => ProfileSetupPage(user: state.user)),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage(user: state.user)),
              (route) => false,
            );
          }
        } else if (state is OtpSent) {
          setState(() {
            _isOtpSent = true;
            _isLoading = false;
          });
        } else if (state is AuthError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117), // Dark base color
        body: Stack(
          children: [
            // 1. Grid Background
            Positioned.fill(
              child: ColorFiltered(
      child: Theme(
        data: AppTheme.lightTheme,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D1117), // Dark base color
          body: Stack(
            children: [
              // 1. Grid Background
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  child: Image.asset(
                    'assets/login_bg.webp',
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),

              // 2. Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PequireLogo(height: 32, isLight: false),
                          if (_isOtpSent)
                            IconButton(
                              onPressed: () => setState(() => _isOtpSent = false),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // Heading
                      Text(
                        _isOtpSent ? 'Verify your\nnumber' : 'Enter your mobile\nnumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isOtpSent ? 'Code is sent to +91' : 'Join the Pequire ecosystem',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Label
                      Text(
                        _isOtpSent ? 'Enter 6-digit OTP' : 'Phone Number',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: _isOtpSent ? _buildOtpInput() : _buildPhoneInput(),
                      ),

                      const SizedBox(height: 20),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isOtpSent ? 'Verify & Login' : 'Get OTP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),

                      if (_isOtpSent) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: _sendOtp,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const Spacer(flex: 3),

                      // Footer
                      Center(
                        child: Text(
                          'By signing up, you agree to the Terms of Service\nand Data Processing Agreement',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Row(
      children: [
        // Fake Flag & +91
        const Text('🇮🇳', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        const Text(
          '+91',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        const SizedBox(width: 8),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '98765 43210',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const Icon(Icons.contact_page_outlined, color: Color(0xFF3B82F6)),
      ],
    );
  }

  Widget _buildOtpInput() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 16,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        hintText: '******',
        hintStyle: TextStyle(color: Colors.grey, letterSpacing: 16),
      ),
    );
  }

  void _sendOtp() {
    String raw = _phoneController.text.replaceAll(' ', '');
    String fullPhone = raw.startsWith('+') ? raw : '+91$raw';
    
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(SendWhatsAppOtp(fullPhone));
  }

  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      String raw = _phoneController.text.replaceAll(' ', '');
      String fullPhone = raw.startsWith('+') ? raw : '+91$raw';
      
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(VerifyWhatsAppOtp(
        phoneNumber: fullPhone,
        otp: _otpController.text,
        role: 'user',
      ));
    }
  }
}
