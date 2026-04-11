import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class QuickFixBaseLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback? onBack;
  final double initialSheetSize;
  final double minSheetSize;
  final double maxSheetSize;
  final Color? sheetColor;

  const QuickFixBaseLayout({
    super.key,
    required this.child,
    this.title = 'Quick Fix',
    this.onBack,
    this.initialSheetSize = 0.5,
    this.minSheetSize = 0.3,
    this.maxSheetSize = 0.9,
    this.sheetColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Map Layer
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Live Map View',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Map context for service booking)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Custom App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Foregound content in a Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: initialSheetSize,
            minChildSize: minSheetSize,
            maxChildSize: maxSheetSize,
            builder: (context, scrollController) {
              final isDark = (sheetColor ?? Colors.white).computeLuminance() < 0.5;
              return Container(
                decoration: BoxDecoration(
                  color: sheetColor ?? Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
