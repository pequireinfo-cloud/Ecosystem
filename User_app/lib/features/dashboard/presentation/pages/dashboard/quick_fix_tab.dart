import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/dashboard/presentation/pages/dashboard/categories_page.dart';
import 'package:pequire_user_app/features/dashboard/presentation/pages/dashboard/quick_fix_categories_page.dart';
class QuickFixTab extends StatefulWidget {
  const QuickFixTab({super.key});

  @override
  State<QuickFixTab> createState() => _QuickFixTabState();
}

class _QuickFixTabState extends State<QuickFixTab> {
  
  Future<void> _handleRequestNow() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuickFixCategoriesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Expanded(
                flex: 5,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      size: 100,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Text Content
              const Text(
                'Need a Quick Fix?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Get a service provider at your doorstep\nwithin 30 minutes. Fast, reliable, and verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Action Button
              ElevatedButton(
                onPressed: _handleRequestNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Request Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
