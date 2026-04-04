import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';
import 'package:pequire_provider_app/features/home/screens/chat_page.dart';

class ActiveJobPanel extends StatefulWidget {
  final String bookingId;
  final String serviceType;
  final String address;
  final VoidCallback onComplete;

  const ActiveJobPanel({
    super.key,
    required this.bookingId,
    required this.serviceType,
    required this.address,
    required this.onComplete,
  });

  @override
  State<ActiveJobPanel> createState() => _ActiveJobPanelState();
}

class _ActiveJobPanelState extends State<ActiveJobPanel> {
  File? _beforeImage;
  File? _afterImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(pickedFile.path);
        } else {
          _afterImage = File(pickedFile.path);
        }
      });
      
      // Update Firestore with a local path or placeholder for now
      // In a real app, you'd upload to Firebase Storage and get a URL
      await BookingService().updateJobProgress(
        widget.bookingId,
        isBefore ? 'before_photo_captured' : 'after_photo_captured',
      );
    }
  }

  Future<void> _handleComplete() async {
    if (_beforeImage == null || _afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture both Before and After photos.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // In a real app, upload images to Storage here
      await BookingService().completeBooking(widget.bookingId);
      widget.onComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ACTIVE JOB',
                  style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 10, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(bookingId: widget.bookingId),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 16),
                ),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text('In Progress', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.serviceType, style: AppTypography.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.address,
                  style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Text('QUALITY VERIFICATION', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            children: [
              _photoSlot('Before', _beforeImage, () => _pickImage(true)),
              const SizedBox(width: 16),
              _photoSlot('After', _afterImage, () => _pickImage(false)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Complete Job', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoSlot(String label, File? image, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                image: image != null ? DecorationImage(image: FileImage(image), fit: BoxFit.cover) : null,
              ),
              child: image == null
                  ? const Center(child: Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 28))
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
