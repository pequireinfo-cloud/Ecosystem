import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Reviews'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Hero
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('4.8', style: AppTypography.h1.copyWith(fontSize: 48, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('/5', style: AppTypography.h3.copyWith(color: const Color(0xFFCBD5E1), fontSize: 20)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                              color: const Color(0xFFFACC15),
                              size: 24,
                            ),
                          )),
                        ),
                        const SizedBox(height: 6),
                        Text('Based on 36 reviews', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8))),
                        const SizedBox(height: 20),
                        ...[5, 4, 3, 2, 1].map((n) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              SizedBox(width: 20, child: Text('$n', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 12))),
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFACC15)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: [0.72, 0.18, 0.06, 0.03, 0.01][5 - n],
                                    child: Container(decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(100))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(width: 20, child: Text(['26', '6', '2', '1', '1'][5 - n], style: AppTypography.bodySmall.copyWith(fontSize: 11), textAlign: TextAlign.right)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Reviews', style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  _reviewCard('Priya S.', 5, 'Electrical', 'Excellent work! Fixed our switch board perfectly. Very professional.', '2 hours ago'),
                  _reviewCard('Arjun M.', 4, 'Plumbing', 'Good job overall. Arrived on time. Could improve cleanup.', 'Yesterday'),
                  _reviewCard('Meena R.', 5, 'Wiring', 'Best electrician we\'ve had. Neat work. Highly recommend!', '3 days ago'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(String name, int stars, String type, String quote, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(name[0], style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 14))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A))),
                    Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 14, color: i < stars ? const Color(0xFFFACC15) : const Color(0xFFE2E8F0)))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(6)),
                child: Text(type, style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('"$quote"', style: AppTypography.body.copyWith(color: const Color(0xFF64748B), fontStyle: FontStyle.italic, height: 1.5, fontSize: 13)),
          const SizedBox(height: 8),
          Text(time, style: AppTypography.bodySmall.copyWith(color: const Color(0xFFCBD5E1), fontSize: 11)),
        ],
      ),
    );
  }
}
