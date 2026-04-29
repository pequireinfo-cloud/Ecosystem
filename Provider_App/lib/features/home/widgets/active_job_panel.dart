import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pequire_provider_app/core/services/api_service.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';
import 'package:pequire_provider_app/features/home/screens/chat_page.dart';
import 'package:pequire_provider_app/features/home/widgets/user_feedback_dialog.dart';

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
  XFile? _beforeImage;
  XFile? _afterImage;
  bool _isSubmitting = false;
  String _currentStatus = 'accepted';
  Map<String, dynamic>? _bookingData;

  // Diagnosis Controllers
  final _applianceController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() async {
    while (mounted) {
      try {
        final response = await ApiService().get('/bookings/${widget.bookingId}');
        if (mounted) {
          setState(() {
            _bookingData = response.data;
            _currentStatus = _bookingData?['status'] ?? 'accepted';
          });
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _verifyArrival() async {
    final otp = await _showOtpDialog('Arrival OTP');
    if (otp == null) return;

    setState(() => _isSubmitting = true);
    try {
      await BookingService().verifyArrivalOtp(widget.bookingId, otp);
    } catch (e) {
      _showError('Invalid OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitDiagnosis() async {
    if (_priceController.text.isEmpty) {
      _showError('Please enter a final price.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await BookingService().submitDiagnosis(
        bookingId: widget.bookingId,
        appliance: _applianceController.text.isEmpty ? widget.serviceType : _applianceController.text,
        problem: _problemController.text,
        solution: _solutionController.text,
        price: double.parse(_priceController.text),
      );
    } catch (e) {
      _showError('Failed to submit diagnosis.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyCompletion() async {
    if (_beforeImage == null || _afterImage == null) {
      _showError('Please capture both Before and After photos.');
      return;
    }

    final otp = await _showOtpDialog('Completion OTP');
    if (otp == null) return;

    setState(() => _isSubmitting = true);
    try {
      await BookingService().verifyWorkOtp(widget.bookingId, otp);
      
      if (mounted) {
        // Show Feedback Dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UserFeedbackDialog(
            bookingId: widget.bookingId,
            userName: _bookingData?['userId']?['name'] ?? 'the Customer',
          ),
        );
      }
      
      widget.onComplete();
    } catch (e) {
      _showError('Invalid OTP or verification failed.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _showOtpDialog(String title) {
    String otpValue = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTypography.h3),
        content: TextField(
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: 'Enter 6-digit OTP'),
          onChanged: (v) => otpValue = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, otpValue), child: const Text('Verify')),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        if (isBefore) _beforeImage = pickedFile;
        else _afterImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Text(widget.serviceType, style: AppTypography.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.address, style: AppTypography.bodySmall, maxLines: 1)),
            ]),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),
            
            // Dynamic Workflow Content
            if (_currentStatus == 'accepted') _buildArrivalStage(),
            if (_currentStatus == 'diagnosing') _buildDiagnosisStage(),
            if (_currentStatus == 'waiting_approval') _buildWaitingStage(),
            if (_currentStatus == 'working') _buildWorkingStage(),
            if (_currentStatus == 'completed') ...[
              const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 48)),
              const SizedBox(height: 16),
              const Center(child: Text('JOB COMPLETED', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: widget.onComplete, child: const Text('Close'))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalStage() {
    return Column(
      children: [
        const Text('Professional has arrived?', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _verifyArrival,
            child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Start Diagnosis (Verify Arrival)'),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DIAGNOSIS REPORT', style: AppTypography.label.copyWith(fontSize: 11)),
        const SizedBox(height: 12),
        if (!widget.serviceType.toLowerCase().contains('laundry'))
          _buildField('Appliance Model/Type', _applianceController),
        _buildField('Problem Found', _problemController),
        _buildField('Suggested Solution', _solutionController),
        _buildField('Final Quotation (₹)', _priceController, isNum: true),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitDiagnosis,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit for Approval'),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingStage() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Waiting for user to approve price...', style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildWorkingStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUALITY VERIFICATION', style: AppTypography.label.copyWith(fontSize: 11)),
        const SizedBox(height: 16),
        Row(children: [
          _photoSlot('Before', _beforeImage, () => _pickImage(true)),
          const SizedBox(width: 16),
          _photoSlot('After', _afterImage, () => _pickImage(false)),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _verifyCompletion,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
            child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Finish Work (Verify OTP)'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
     return Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.primary.withOpacity(0.2) : const Color(0xFFEEF2FF), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ACTIVE JOB', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 10)),
              ),
              const SizedBox(width: 12),
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatPage(bookingId: widget.bookingId))), icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20)),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(_currentStatus.toUpperCase(), style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B))),
            ],
          );
  }

  Widget _buildField(String hint, TextEditingController controller, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _photoSlot(String label, XFile? image, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
              ),
              child: image == null
                  ? const Center(child: Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 28))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<Uint8List>(
                        future: image.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(snapshot.data!, fit: BoxFit.cover);
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
