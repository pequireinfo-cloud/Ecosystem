import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final Set<int> _selectedIndices = {};

  final List<_Service> _services = [
    const _Service(Icons.bolt_rounded, 'Electrical'),
    const _Service(Icons.water_drop_rounded, 'Plumbing'),
    const _Service(Icons.chair_rounded, 'Carpentry'),
    const _Service(Icons.local_laundry_service_rounded, 'Laundry'),
  ];

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

                    // Progress Track (Step 1 of 4)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STEP 1 OF 4',
                              style: AppTypography.label.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _progressSegment(true),
                            const SizedBox(width: 4),
                            _progressSegment(false),
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
                      'Select services',
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
                      'Choose your areas of expertise.',
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (_, i) {
                        final s = _services[i];
                        final selected = _selectedIndices.contains(i);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedIndices.remove(i);
                            } else {
                              _selectedIndices.add(i);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: selected ? AppColors.primaryGlow : AppColors.softShadow,
                              border: Border.all(
                                color: selected ? AppColors.primary : const Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  s.icon, 
                                  color: selected ? AppColors.primary : const Color(0xFF94A3B8), 
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.name,
                                  style: AppTypography.label.copyWith(
                                    fontSize: 14,
                                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                    color: selected ? AppColors.primary : const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA (Glowing Gradient)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTap: _selectedIndices.isNotEmpty ? () => context.push('/profile-setup') : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: _selectedIndices.isNotEmpty ? AppColors.primaryGradient : null,
                    color: _selectedIndices.isNotEmpty ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _selectedIndices.isNotEmpty ? AppColors.primaryGlow : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm & Continue',
                          style: AppTypography.h3.copyWith(
                            color: _selectedIndices.isNotEmpty ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (_selectedIndices.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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

class _Service {
  final IconData icon;
  final String name;
  const _Service(this.icon, this.name);
}
