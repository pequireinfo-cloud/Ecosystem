import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_shimmer.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _tc.addListener(() => setState(() {}));
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final providerId = ApiConfig.currentProviderId;
    if (providerId != null) {
      final list = await BookingService().getProviderBookings(providerId);
      if (mounted) {
        setState(() {
          _bookings = list;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Segment bookings
    final activeJobs = _bookings.where((b) {
      final status = b['status'] as String? ?? '';
      return ['accepted', 'at_location', 'diagnosing', 'waiting_approval', 'working'].contains(status);
    }).toList();

    final upcomingJobs = _bookings.where((b) {
      final status = b['status'] as String? ?? '';
      return ['pending', 'searching'].contains(status);
    }).toList();

    final completedJobs = _bookings.where((b) {
      final status = b['status'] as String? ?? '';
      return ['completed', 'cancelled'].contains(status);
    }).toList();

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
                _tab('Active (${activeJobs.length})', 0),
                _tab('Upcoming (${upcomingJobs.length})', 1),
                _tab('Completed (${completedJobs.length})', 2),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? PequireShimmer.bookingList()
                : TabBarView(
                    controller: _tc,
                    children: [
                      _tabContent(activeJobs),
                      _tabContent(upcomingJobs),
                      _tabContent(completedJobs),
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
            child: Text(label, style: AppTypography.label.copyWith(color: active ? AppColors.primary : const Color(0xFF94A3B8), fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _tabContent(List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: AppTypography.label.copyWith(color: const Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'No bookings in this tab yet.',
              style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      itemBuilder: (_, i) => _jobCard(jobs[i]),
    );
  }

  Widget _jobCard(Map<String, dynamic> j) {
    final clientName = j['userId']?['fullName'] ?? 'Client';
    final service = j['serviceType'] ?? 'General Service';
    final status = (j['status'] as String? ?? 'pending').replaceAll('_', ' ').toUpperCase();
    final address = j['location']?['address'] ?? 'Nearby Location';

    final priceVal = j['finalPrice'] ?? j['estimatedPrice'] ?? 0;
    final priceStr = '₹$priceVal';

    // Map style helper
    IconData icon = Icons.build_rounded;
    Color bgColor = const Color(0xFFF1F5F9);
    Color iconColor = const Color(0xFF64748B);

    final serviceLower = service.toString().toLowerCase();
    if (serviceLower.contains('plumb')) {
      icon = Icons.plumbing_rounded;
      bgColor = const Color(0xFFDBEAFE);
      iconColor = const Color(0xFF2563EB);
    } else if (serviceLower.contains('elect') || serviceLower.contains('wir')) {
      icon = Icons.bolt_rounded;
      bgColor = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
    } else if (serviceLower.contains('carpen')) {
      icon = Icons.handyman_rounded;
      bgColor = const Color(0xFFF5F3FF);
      iconColor = const Color(0xFF7C3AED);
    } else if (serviceLower.contains('laund') || serviceLower.contains('wash')) {
      icon = Icons.local_laundry_service_rounded;
      bgColor = const Color(0xFFE0F2FE);
      iconColor = const Color(0xFF0284C7);
    } else if (serviceLower.contains('clean')) {
      icon = Icons.cleaning_services_rounded;
      bgColor = const Color(0xFFECFDF5);
      iconColor = const Color(0xFF059669);
    }

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
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName, style: AppTypography.label.copyWith(color: const Color(0xFF0F172A), fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(service, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: AppTypography.bodySmall.copyWith(color: iconColor, fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF8FAFC)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFCBD5E1)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12, overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(priceStr, style: AppTypography.h4.copyWith(color: const Color(0xFF059669))),
            ],
          ),
        ],
      ),
    );
  }
}
