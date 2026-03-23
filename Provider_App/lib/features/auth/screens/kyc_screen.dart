import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:file_picker/file_picker.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final Map<String, String?> _uploadedFiles = {
    'Aadhar Card': null,
    'PAN Card': null,
    'Driving License': null,
  };

  bool get _allUploaded => _uploadedFiles.values.every((v) => v != null);

  Future<void> _pickFile(String docType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _uploadedFiles[docType] = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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

                    // Progress Track
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP 3 OF 4',
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
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(false),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify identity',
                      style: AppTypography.h1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload high-quality photos of your documents.',
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Document Cards
                    _docCard('Aadhar Card', 'Front & Back photo', Icons.badge_rounded),
                    const SizedBox(height: 12),
                    _docCard('PAN Card', 'Individual PAN card', Icons.credit_card_rounded),
                    const SizedBox(height: 12),
                    _docCard('Driving License', 'Valid license photo', Icons.admin_panel_settings_rounded),

                    const SizedBox(height: 24),
                    
                    // Security Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your documents are encrypted and secure.',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTap: _allUploaded ? () => context.push('/verification-pending') : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _allUploaded ? AppColors.primaryGradient : null,
                    color: _allUploaded ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _allUploaded ? AppColors.primaryGlow : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit for Review',
                          style: AppTypography.h3.copyWith(
                            color: _allUploaded ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_allUploaded) ...[
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

  Widget _docCard(String title, String sub, IconData icon) {
    String? fileName = _uploadedFiles[title];
    bool uploaded = fileName != null;

    return GestureDetector(
      onTap: () => _pickFile(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: uploaded ? AppColors.primaryGlow : AppColors.softShadow,
          border: Border.all(
            color: uploaded ? AppColors.primary : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: uploaded ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: uploaded ? AppColors.primary : const Color(0xFF94A3B8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    uploaded ? fileName! : sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: uploaded ? AppColors.primary : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: uploaded ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (uploaded)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
            else
              const Icon(Icons.add_a_photo_rounded, color: Color(0xFFCBD5E1), size: 16),
          ],
        ),
      ),
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
