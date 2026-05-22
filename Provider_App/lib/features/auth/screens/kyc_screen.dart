import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pequire_provider_app/core/services/api_service.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_logo.dart';
import 'package:pequire_provider_app/core/providers/kyc_provider.dart';
import 'dart:io';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final Map<String, String?> _uploadedFiles = {
    'Aadhar Card': null,
    'PAN Card': null,
    'Driving License': null,
  };

  final Map<String, String?> _localFilePaths = {
    'Aadhar Card': null,
    'PAN Card': null,
    'Driving License': null,
  };

  bool _isUploading = false;

  bool get _allUploaded => _uploadedFiles.values.every((v) => v != null);

  Future<void> _pickFile(String docType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedFiles[docType] = result.files.single.name;
          _localFilePaths[docType] = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submitKyc() async {
    setState(() => _isUploading = true);
    try {
      final Map<String, String> downloadUrls = {};

      for (var entry in _localFilePaths.entries) {
        if (entry.value != null) {
          final url = await ApiService().uploadFile(entry.value!);
          
          if (entry.key == 'Aadhar Card') downloadUrls['aadharCard'] = url;
          if (entry.key == 'PAN Card') downloadUrls['panCard'] = url;
          if (entry.key == 'Driving License') downloadUrls['drivingLicense'] = url;
        }
      }

      final providerId = ApiConfig.currentProviderId;
      if (providerId == null) throw "Provider ID not found. Please log in again.";

      await ApiService().put('providers/$providerId/kyc', data: {
        'kycStatus': 'In Review',
        'documents': downloadUrls,
      });

      final prefs = await SharedPreferences.getInstance();
      ApiConfig.registrationStep = 'verification-pending';
      ApiConfig.kycStatus = 'In Review';
      await prefs.setString('registration_step', 'verification-pending');
      await prefs.setString('kyc_status', 'In Review');

      if (mounted) {
        ref.read(kycProvider.notifier).updateState(KycState.pending);
        context.push('/verification-pending');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                    const PequireLogo(height: 28, isLight: true),
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
                onTap: (_allUploaded && !_isUploading) ? _submitKyc : null,
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
                          _isUploading ? 'Uploading...' : 'Submit for Review',
                          style: AppTypography.h3.copyWith(
                            color: (_allUploaded && !_isUploading) ? Colors.white : const Color(0xFF94A3B8),
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


