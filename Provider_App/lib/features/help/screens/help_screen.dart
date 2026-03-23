import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _expandedIndex = -1;

  final List<_Faq> _faqs = [
    _Faq('How do I get more job requests?', 'Stay online during peak hours (8AM–12PM, 4PM–8PM). Maintain a high rating by being punctual, professional, and thorough. Complete your profile and KYC for priority matching.'),
    _Faq('When do I receive payments?', 'Payments are processed within 24 hours of job completion. You can withdraw anytime from Earnings. Minimum withdrawal is ₹100.'),
    _Faq('How do ratings work?', 'Customers rate you 1-5 stars after each job. Your overall rating is an average. Higher ratings get more requests.'),
    _Faq('What if I need to cancel a job?', 'You can decline before accepting. After accepting, cancellations affect your reliability score.'),
    _Faq('How do I update my services?', 'Go to Profile > Edit Profile to update service categories. Changes take effect immediately.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Help Centre'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // Search bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search_rounded, color: Color(0xFFCBD5E1), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: AppTypography.body.copyWith(fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for help...',
                            hintStyle: AppTypography.body.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('FAQ', style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A))),
                const SizedBox(height: 12),
                ...List.generate(_faqs.length, (i) {
                  final open = _expandedIndex == i;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: open ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _expandedIndex = open ? -1 : i),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(child: Text(_faqs[i].q, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A)))),
                                AnimatedRotation(
                                  turns: open ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (open)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(_faqs[i].a, style: AppTypography.body.copyWith(color: const Color(0xFF64748B), height: 1.6, fontSize: 13)),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                Text('Contact Us', style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _contactCard(Icons.chat_bubble_outline_rounded, 'WhatsApp Support', 'Chat with us instantly', const Color(0xFF059669), const Color(0xFFECFDF5)),
                _contactCard(Icons.email_outlined, 'Email Support', 'support@pequire.com', const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String sub, Color iconColor, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(sub, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }
}

class _Faq {
  final String q, a;
  const _Faq(this.q, this.a);
}
