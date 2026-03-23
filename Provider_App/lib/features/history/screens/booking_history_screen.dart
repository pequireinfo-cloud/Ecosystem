import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'My Bookings'),
          // Tab Strip
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _tab('Active', 0),
                _tab('Upcoming', 1),
                _tab('Completed', 2),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                _tabContent([_Job('Priya S.', 'Electrical Repair', Icons.bolt_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706), 'In Progress', '₹480', '2.4 km')]),
                _tabContent([
                  _Job('Deepak P.', 'Carpentry Work', Icons.handyman_rounded, const Color(0xFFF5F3FF), const Color(0xFF7C3AED), 'Tomorrow 3PM', '₹750', '1.8 km'),
                  _Job('Sita R.', 'Electrical Install', Icons.bolt_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706), 'Wed 10AM', '₹520', '4.2 km'),
                ]),
                _tabContent([
                  _Job('Arjun M.', 'Plumbing Fix', Icons.plumbing_rounded, const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'Completed', '₹620', '3.1 km'),
                  _Job('Meena R.', 'Wiring Install', Icons.bolt_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706), 'Completed', '₹350', '2.0 km'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = _tc.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tc.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
          ),
          child: Center(
            child: Text(label, style: AppTypography.label.copyWith(color: active ? AppColors.primary : const Color(0xFF94A3B8), fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _tabContent(List<_Job> jobs) {
    if (jobs.isEmpty) return Center(child: Text('No jobs yet', style: AppTypography.body.copyWith(color: const Color(0xFFCBD5E1))));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      itemBuilder: (_, i) => _jobCard(jobs[i]),
    );
  }

  Widget _jobCard(_Job j) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: j.bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(j.icon, color: j.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j.name, style: AppTypography.label.copyWith(color: const Color(0xFF0F172A), fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(j.service, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: j.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(j.status, style: AppTypography.bodySmall.copyWith(color: j.iconColor, fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF8FAFC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 4),
              Text(j.distance, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              const Spacer(),
              Text(j.price, style: AppTypography.h4.copyWith(color: const Color(0xFF059669))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Job {
  final String name, service, status, price, distance;
  final IconData icon;
  final Color bgColor, iconColor;
  const _Job(this.name, this.service, this.icon, this.bgColor, this.iconColor, this.status, this.price, this.distance);
}
