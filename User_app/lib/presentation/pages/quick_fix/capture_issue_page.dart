import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'analyzing_page.dart';

class CaptureIssuePage extends StatefulWidget {
  const CaptureIssuePage({super.key});

  @override
  State<CaptureIssuePage> createState() => _CaptureIssuePageState();
}

class _CaptureIssuePageState extends State<CaptureIssuePage> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();
  bool _isListening = false; // Mock for voice recording state

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _showARScan() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Mock Camera View
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=2070',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Scanning Grid Animation
              const Center(
                child: ARScanOverlay(),
              ),
              // Close Button
              Positioned(
                top: 50,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Bottom Status
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Analyzing structural Pulse...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Premium Header Background
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1B2F),
                  Color(0xFF2D2E45),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Capture Issue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                
                // Progress Indicator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  height: 4,
                  child: LinearProgressIndicator(
                    value: 0.2, // Step 1 of 5
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Show us the leak',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'समस्या दिखाएं',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Main Capture Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                               Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
                                    SizedBox(width: 6),
                                    Text(
                                      'AI VISION READY',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Image Preview or Placeholder
                              if (_images.isEmpty) ...[
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Photo Evidence',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap below to take a photo of the damage.\nOur AI will analyze it instantly.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ] else ...[
                                 SizedBox(
                                  height: 220,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _images.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: FutureBuilder<Uint8List>(
                                                future: _images[index].readAsBytes(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Image.memory(
                                                      snapshot.data!,
                                                      height: 220,
                                                      width: 160,
                                                      fit: BoxFit.cover,
                                                    );
                                                  }
                                                  return const SizedBox(
                                                    height: 220,
                                                    width: 160,
                                                    child: Center(child: CircularProgressIndicator()),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 32),
                               // Pulse AR Scan Button
                               SizedBox(
                                 width: double.infinity,
                                 child: Container(
                                   decoration: BoxDecoration(
                                     gradient: const LinearGradient(
                                       colors: [Color(0xFF025EF3), Color(0xFF6366F1)],
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                     ),
                                     borderRadius: BorderRadius.circular(16),
                                     boxShadow: [
                                       BoxShadow(
                                         color: const Color(0xFF025EF3).withOpacity(0.3),
                                         blurRadius: 12,
                                         offset: const Offset(0, 4),
                                       ),
                                     ],
                                   ),
                                   child: ElevatedButton.icon(
                                     onPressed: _showARScan,
                                     icon: const Icon(Icons.vibration_rounded, color: Colors.white),
                                     label: const Text(
                                       'Pequire Pulse (AR Scan)',
                                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                     ),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.transparent,
                                       foregroundColor: Colors.white,
                                       elevation: 0,
                                       padding: const EdgeInsets.symmetric(vertical: 16),
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                     ),
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 16),
                               Row(
                                 children: [
                                   Expanded(
                                     child: ElevatedButton.icon(
                                       onPressed: () => _pickImage(ImageSource.camera),
                                      icon: const Icon(Icons.camera_alt_outlined),
                                      label: Text(
                                        _images.isEmpty ? 'Open Camera' : 'Add Photo',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.background,
                                        foregroundColor: AppColors.primary, // Using primary purple
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_images.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                     Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(ImageSource.gallery),
                                        icon: const Icon(Icons.photo_library_outlined),
                                        label: const Text(
                                          'Gallery',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.background,
                                          foregroundColor: AppColors.textSecondary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Input Section (Row)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             // Mic Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isListening = !_isListening;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _isListening ? AppColors.error : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening ? AppColors.error : AppColors.secondary)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic_none,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text Input
                            Expanded(
                              child: TextField(
                                controller: _notesController,
                                onChanged: (value) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Describe issue or speak...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                maxLines: 2,
                                minLines: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Main Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_images.isEmpty && _notesController.text.trim().isEmpty)
                              ? null 
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnalyzingPage(
                                      image: _images.isNotEmpty ? _images.first : null
                                    ),
                                  ),
                                );
                              },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Analyze Problem',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                         const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ARScanOverlay extends StatefulWidget {
  const ARScanOverlay({super.key});

  @override
  State<ARScanOverlay> createState() => _ARScanOverlayState();
}

class _ARScanOverlayState extends State<ARScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
              ),
            ),
            // Pulsing Target
            Container(
              width: 200 + (50 * (1.0 - _controller.value % 0.5 * 2).abs()),
              height: 200 + (50 * (1.0 - _controller.value % 0.5 * 2).abs()),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withOpacity(1.0 - (_controller.value % 0.5 * 2)),
                  width: 4,
                ),
              ),
            ),
            // Scanning Line
            Positioned(
              top: 250 * _controller.value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: AppColors.secondary.withOpacity(0.8), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
            ),
            if (_controller.value > 0.8)
              Positioned(
                top: 80,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('SEV-2 LEAK DETECTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
