import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';
import 'package:pequire_provider_app/core/services/provider_service.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:intl/intl.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_shimmer.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final providerId = ApiConfig.currentProviderId;
    if (providerId != null) {
      final profile = await ProviderService().getProfile(providerId);
      final reviews = await ProviderService().getReviews(providerId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double rating = (_profile?['rating'] ?? 5.0).toDouble();
    final int reviewCount = _profile?['reviewCount'] ?? _reviews.length;

    // Calculate rating distribution
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in _reviews) {
      int star = (r['rating'] as num).toInt();
      if (distribution.containsKey(star)) {
        distribution[star] = (distribution[star] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Reviews'),
          Expanded(
            child: _isLoading 
              ? PequireShimmer.reviewsScreen()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                  Text(rating.toStringAsFixed(1), style: AppTypography.h1.copyWith(fontSize: 48, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('/5', style: AppTypography.h3.copyWith(color: const Color(0xFFCBD5E1), fontSize: 20)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  double starValue = i + 1;
                                  IconData icon = Icons.star_outline_rounded;
                                  if (rating >= starValue) {
                                    icon = Icons.star_rounded;
                                  } else if (rating >= starValue - 0.5) {
                                    icon = Icons.star_half_rounded;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Icon(
                                      icon,
                                      color: const Color(0xFFFACC15),
                                      size: 24,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              Text('Based on $reviewCount reviews', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8))),
                              const SizedBox(height: 20),
                              ...[5, 4, 3, 2, 1].map((n) {
                                double factor = reviewCount > 0 ? (distribution[n] ?? 0) / reviewCount : 0;
                                return Padding(
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
                                            widthFactor: factor,
                                            child: Container(decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(100))),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(width: 20, child: Text('${distribution[n]}', style: AppTypography.bodySmall.copyWith(fontSize: 11), textAlign: TextAlign.right)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Recent Reviews', style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        if (_reviews.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.star_outline_rounded, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text('No reviews yet', style: AppTypography.body.copyWith(color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._reviews.map((r) {
                            final userName = r['userId']?['name'] ?? 'Anonymous';
                            final stars = (r['rating'] as num).toInt();
                            final type = r['serviceType'] ?? 'Service';
                            final quote = r['review'] ?? 'No comment provided.';
                            final date = DateTime.parse(r['createdAt']);
                            final timeAgo = _getTimeAgo(date);
                            
                            return _reviewCard(userName, stars, type, quote, timeAgo);
                          }),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return DateFormat('MMM d, y').format(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
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
                child: Center(child: Text(name.isNotEmpty ? name[0] : 'U', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 14))),
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
