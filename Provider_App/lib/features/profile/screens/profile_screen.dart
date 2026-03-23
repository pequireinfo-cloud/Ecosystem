import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Profile'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Rajesh Kumar', style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('⚡ Electrician · Mumbai', style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (i) => Icon(i < 4 ? Icons.star_rounded : Icons.star_half_rounded, size: 16, color: const Color(0xFFFACC15))),
                            const SizedBox(width: 6),
                            Text('4.8', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _stat('Jobs', '36'),
                            const SizedBox(width: 8),
                            _stat('Hours', '57h'),
                            const SizedBox(width: 8),
                            _stat('Earned', '₹28K'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.push('/edit-profile'),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Center(child: Text('Edit Profile', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 13))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _infoCard(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
                  _infoCard(Icons.location_on_outlined, 'City', 'Mumbai, Maharashtra'),
                  _infoCard(Icons.build_outlined, 'Category', 'Electrical Services'),
                  _infoCard(Icons.verified_outlined, 'KYC Status', 'Verified'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}
