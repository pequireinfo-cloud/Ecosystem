import 'package:flutter/material.dart';

import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          PequireAppBar(
            title: 'Earnings',
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.filter_list_rounded, size: 20, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹28,450', style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _statChip('Available', '₹22,400', const Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            _statChip('Pending', '₹6,050', const Color(0xFFF59E0B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(Icons.account_balance_rounded, 'Add Bank', const Color(0xFF475569)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(Icons.download_rounded, 'Withdraw', const Color(0xFF059669)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Period filters
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterPill('Today', true),
                        _filterPill('This Week', false),
                        _filterPill('This Month', false),
                        _filterPill('All Time', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Recent Transactions', style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  _txnItem('Electrical Repair', 'Priya S. · 2:30 PM', '+₹480', true),
                  _txnItem('Plumbing Fix', 'Arjun M. · 11:00 AM', '+₹620', true),
                  _txnItem('Withdrawal', 'To HDFC ****1234', '-₹5,000', false),
                  _txnItem('Wiring Install', 'Meena R. · Yesterday', '+₹350', true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.h3.copyWith(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.label.copyWith(color: const Color(0xFF334155), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _filterPill(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: active ? Colors.white : const Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _txnItem(String title, String sub, String amount, bool isCredit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
              size: 18,
            ),
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
          Text(
            amount,
            style: AppTypography.h4.copyWith(color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}
