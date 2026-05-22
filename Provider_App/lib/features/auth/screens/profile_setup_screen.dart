import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:pequire_provider_app/core/services/provider_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  bool get _isValid => _nameController.text.length >= 3 && 
                       _emailController.text.contains('@') && 
                       _cityController.text.isNotEmpty;

  void _onSubmitProfile() async {
    final providerId = ApiConfig.currentProviderId;
    if (providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      context.go('/login');
      return;
    }

    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid details'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ProviderService().updateProfile(providerId, {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'city': _cityController.text.trim(),
      });

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        ApiConfig.registrationStep = 'kyc';
        await prefs.setString('registration_step', 'kyc');
        
        if (mounted) {
          context.push('/kyc');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
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
                    const PequireLogo(height: 28, isLight: true),
                    const SizedBox(height: 32),

                    // Progress Track
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP 2 OF 4',
                          style: AppTypography.label.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(false),
                            const SizedBox(width: 4),
                            _progressSegment(false),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Title Section
                    Text(
                      'Professional profile',
                      style: AppTypography.h1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your details to build trust.',
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Matrix
                    _inputCard('FULL NAME', _nameController, 'Your full name', Icons.person_rounded),
                    const SizedBox(height: 10),
                    _inputCard('EMAIL ADDRESS', _emailController, 'your@email.com', Icons.email_rounded),
                    const SizedBox(height: 10),
                    _inputCard('PRIMARY CITY', _cityController, 'Your city', Icons.location_city_rounded),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTap: (_isValid && !_isLoading) ? _onSubmitProfile : null,
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
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue to Verification',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard(String label, TextEditingController controller, String hint, IconData icon) {
    bool hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.softShadow,
            border: Border.all(
              color: hasValue ? AppColors.primary.withOpacity(0.2) : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(icon, color: hasValue ? AppColors.primary : const Color(0xFFCBD5E1), size: 18),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.h3.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTypography.body.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 14,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
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


