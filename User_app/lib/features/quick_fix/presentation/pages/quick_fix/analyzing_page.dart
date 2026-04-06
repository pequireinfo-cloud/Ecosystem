import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'diagnosis_page.dart';

class AnalyzingPage extends StatefulWidget {
  final List<String> imageUrls;
  final String notes;
  const AnalyzingPage({super.key, this.imageUrls = const [], this.notes = ''});

  @override
  State<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends State<AnalyzingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;

  final List<Map<String, String>> _steps = [
    {
      'title': 'Transcribing voice...',
      'subtitle': 'Audio note processed successfully',
    },
    {
      'title': 'Identifying components...',
      'subtitle': 'Scanning for pipes, valves, and leaks',
    },
    {
      'title': 'Estimating severity...',
      'subtitle': 'Calculating repair urgency',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startAnalysis();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _steps.length; i++) {
        // Adjust delays based on actual steps
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentStep = i + 1;
        });
      }
    }
    
    // Navigate to next page
    if (mounted) {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisPage(
            imageUrls: widget.imageUrls,
            notes: widget.notes,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2F), // Dark AI Theme
      body: Stack(
        children: [
          // Background Grid Effect (Optional simplified)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hub, color: AppColors.secondary, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'AI PROCESSING',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosisPage(
                                imageUrls: widget.imageUrls,
                                notes: widget.notes,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Analyzing your\nissue...',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Scanning Image Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                    color: widget.imageUrls.isEmpty ? Colors.white.withOpacity(0.05) : null,
                  ),
                  child: Stack(
                    children: [
                        if (widget.imageUrls.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              widget.imageUrls.first,
                              width: double.infinity,
                              height: 280,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.black,
                                child: const Center(child: Icon(Icons.error, color: Colors.white)),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          )
                        else
                          Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.text_fields_rounded, size: 60, color: Colors.white.withOpacity(0.5)),
                                    const SizedBox(height: 16),
                                    Text(
                                        "Analyzing Description",
                                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    ),
                                ],
                            ),
                          ),
                      
                      // Dark Overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF1A1B2F).withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      
                      // Scanning Line Animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Positioned(
                            top: 280 * _controller.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Scanning Icons
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.qr_code_scanner, color: Colors.white70, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                
                const SizedBox(height: 48),
                
                // Steps List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _steps.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isCompleted = index < _currentStep;
                      bool isCurrent = index == _currentStep;
                      
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isCompleted || isCurrent ? 1.0 : 0.3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted ? AppColors.secondary : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleted || isCurrent ? AppColors.secondary : Colors.grey[700]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isCompleted 
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : isCurrent
                                      ? Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.secondary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                if (index != _steps.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: isCompleted ? AppColors.secondary.withOpacity(0.3) : Colors.grey[800],
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _steps[index]['title']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _steps[index]['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                   const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
