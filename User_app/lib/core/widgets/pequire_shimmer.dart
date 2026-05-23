import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PequireShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder shapeBorder;

  const PequireShimmer.rectangular({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  }) : shapeBorder = const RoundedRectangleBorder();

  const PequireShimmer.circular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  }) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF1F5F9),
      child: Container(
        width: width,
        height: height,
        decoration: shapeBorder is CircleBorder
            ? const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)
            : BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
      ),
    );
  }

  // --- PRESETS FOR USER APP ---

  /// Shimmer for a single Order Card in orders page
  static Widget card() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const PequireShimmer.rectangular(width: 50, height: 50, borderRadius: 16),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PequireShimmer.rectangular(width: 140, height: 18),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFFE2E8F0)),
                        SizedBox(width: 4),
                        PequireShimmer.rectangular(width: 70, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
              const PequireShimmer.rectangular(width: 80, height: 24, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shimmer list for Orders page
  static Widget ordersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      itemBuilder: (_, __) => card(),
    );
  }

  /// Shimmer for Profile Tab
  static Widget profileTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // User Profile Card Shimmer
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const PequireShimmer.circular(width: 80, height: 80),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PequireShimmer.rectangular(width: 140, height: 20),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const PequireShimmer.rectangular(width: 75, height: 20, borderRadius: 12),
                        const SizedBox(width: 8),
                        const PequireShimmer.rectangular(width: 60, height: 20, borderRadius: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Sections Shimmers
        _section('My Order & Rewards', 2),
        _section('Account', 4),
        _section('Preferences', 3),
      ],
    );
  }

  static Widget _section(String title, int itemsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: List.generate(itemsCount, (index) {
              return Column(
                children: [
                  ListTile(
                    leading: const PequireShimmer.rectangular(width: 24, height: 24, borderRadius: 4),
                    title: const PequireShimmer.rectangular(width: 120, height: 16),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFE2E8F0)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  ),
                  if (index < itemsCount - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
