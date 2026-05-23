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

  // --- PRESETS FOR PROVIDER APP ---

  /// Shimmer for a single Booking Card
  static Widget card() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const PequireShimmer.rectangular(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PequireShimmer.rectangular(width: 120, height: 16),
                    const SizedBox(height: 6),
                    const PequireShimmer.rectangular(width: 80, height: 12),
                  ],
                ),
              ),
              const PequireShimmer.rectangular(width: 70, height: 22, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE2E8F0)),
              const SizedBox(width: 4),
              const Expanded(
                child: PequireShimmer.rectangular(height: 12),
              ),
              const SizedBox(width: 16),
              const PequireShimmer.rectangular(width: 50, height: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// Shimmer list for Booking Cards
  static Widget bookingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (_, __) => card(),
    );
  }

  /// Shimmer for Profile Screen
  static Widget profileScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Card Shimmer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const PequireShimmer.circular(width: 72, height: 72),
                const SizedBox(height: 14),
                const PequireShimmer.rectangular(width: 160, height: 20),
                const SizedBox(height: 8),
                const PequireShimmer.rectangular(width: 100, height: 14),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PequireShimmer.rectangular(width: 90, height: 22, borderRadius: 20),
                    const SizedBox(width: 8),
                    const PequireShimmer.rectangular(width: 90, height: 22, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: 16),
                const PequireShimmer.rectangular(width: 120, height: 16),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Container(height: 44, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 44, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 44, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info Cards Shimmers
          ...List.generate(4, (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const PequireShimmer.rectangular(width: 40, height: 40, borderRadius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PequireShimmer.rectangular(width: 60, height: 10),
                      const SizedBox(height: 6),
                      const PequireShimmer.rectangular(width: 150, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Shimmer for Earnings Screen
  static Widget earningsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card Shimmer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PequireShimmer.rectangular(width: 100, height: 14),
                const SizedBox(height: 8),
                const PequireShimmer.rectangular(width: 180, height: 36),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Container(height: 50, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 50, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons Shimmer
          Row(
            children: [
              Expanded(child: Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
            ],
          ),
          const SizedBox(height: 28),
          // Filter Pills Shimmer
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: 90,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const PequireShimmer.rectangular(width: 160, height: 18),
          const SizedBox(height: 12),
          // Transactions Shimmers
          ...List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const PequireShimmer.rectangular(width: 40, height: 40, borderRadius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PequireShimmer.rectangular(width: 110, height: 14),
                      const SizedBox(height: 6),
                      const PequireShimmer.rectangular(width: 160, height: 12),
                    ],
                  ),
                ),
                const PequireShimmer.rectangular(width: 65, height: 16),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Shimmer for Reviews Screen
  static Widget reviewsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero rating block
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const PequireShimmer.rectangular(width: 100, height: 48),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: PequireShimmer.rectangular(width: 20, height: 20, borderRadius: 4),
                  )),
                ),
                const SizedBox(height: 10),
                const PequireShimmer.rectangular(width: 140, height: 12),
                const SizedBox(height: 20),
                ...List.generate(5, (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const PequireShimmer.rectangular(width: 25, height: 12),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)))),
                      const SizedBox(width: 8),
                      const PequireShimmer.rectangular(width: 20, height: 12),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const PequireShimmer.rectangular(width: 140, height: 18),
          const SizedBox(height: 12),
          // Reviews list shimmer
          ...List.generate(2, (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PequireShimmer.rectangular(width: 36, height: 36, borderRadius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PequireShimmer.rectangular(width: 90, height: 14),
                          const SizedBox(height: 4),
                          Row(children: List.generate(5, (_) => const Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: PequireShimmer.rectangular(width: 10, height: 10),
                          ))),
                        ],
                      ),
                    ),
                    const PequireShimmer.rectangular(width: 60, height: 18, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 12),
                const PequireShimmer.rectangular(height: 14),
                const SizedBox(height: 6),
                const PequireShimmer.rectangular(width: 200, height: 14),
                const SizedBox(height: 10),
                const PequireShimmer.rectangular(width: 50, height: 11),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
