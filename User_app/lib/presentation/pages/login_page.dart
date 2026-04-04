import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../state/auth_bloc.dart';
import '../state/auth_state.dart';
import 'onboarding/otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2F),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'assets/wordmark.png',
                        height: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  const Text(
                    'Enter your mobile\nnumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Phone Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        hintText: '9256771264',
                        prefixIcon: _buildCountryPicker(),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.contact_phone_rounded, color: AppColors.buttonPurple, size: 26),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Get OTP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_phoneController.text.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTPVerificationPage(
                                phoneNumber: '$_selectedCountryCode ${_phoneController.text}',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your phone number')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Get OTP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Social Login Section
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or login with',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SocialButton(imageAsset: 'assets/google_icon.png', iconData: Icons.g_mobiledata),
                      SocialButton(imageAsset: 'assets/facebook_icon.png', iconData: Icons.facebook),
                      SocialButton(imageAsset: 'assets/apple_icon.png', iconData: Icons.apple),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Terms and Privacy
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'By signing up, you agree to the Terms of Service',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'and Data Processing Agreement',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
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

