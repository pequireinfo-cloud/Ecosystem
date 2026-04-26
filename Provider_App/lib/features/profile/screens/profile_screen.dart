import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_app_bar.dart';
import 'package:pequire_provider_app/core/services/provider_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (providerId != null) {
      final profile = await ProviderService().getProfile(providerId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = _profile?['fullName'] ?? 'Unknown Professional';
    final serviceType = _profile?['serviceType'] ?? 'Service Provider';
    final rating = (_profile?['rating'] ?? 5.0).toDouble();
    final jobs = _profile?['totalJobsCompleted'] ?? 0;
    final streak = _profile?['currentStreak'] ?? 0;
    final rewardPoints = _profile?['rewardPoints'] ?? 0;
    final phone = _profile?['phoneNumber'] ?? 'No phone';
    final city = _profile?['location']?['address'] ?? 'Unknown Location';
    final kyc = _profile?['kycStatus'] ?? 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const PequireAppBar(title: 'Profile'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 3),
                                  color: Colors.grey.shade800,
                                ),
                                child: Center(child: Text(name.isNotEmpty ? name[0] : 'P', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                              ),
                              if (streak > 0)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(name, style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 20)),
                          const SizedBox(height: 4),
                          Text('⚡ $serviceType', style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                          const SizedBox(height: 12),
                          
                          // Streak & Rewards Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _badge(Icons.local_fire_department_rounded, 'Streak: $streak', Colors.orange),
                              const SizedBox(width: 8),
                              _badge(Icons.stars_rounded, '$rewardPoints Points', Colors.blueAccent),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate(5, (i) {
                                double starValue = i + 1;
                                IconData icon = Icons.star_outline_rounded;
                                if (rating >= starValue) icon = Icons.star_rounded;
                                else if (rating >= starValue - 0.5) icon = Icons.star_half_rounded;
                                return Icon(icon, size: 16, color: const Color(0xFFFACC15));
                              }),
                              const SizedBox(width: 6),
                              Text(rating.toStringAsFixed(1), style: AppTypography.label.copyWith(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _stat('Jobs', jobs.toString()),
                              const SizedBox(width: 8),
                              _stat('Streak', streak.toString()),
                              const SizedBox(width: 8),
                              _stat('Reward', '$rewardPoints'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _infoCard(Icons.phone_outlined, 'Phone', phone),
                    _infoCard(Icons.location_on_outlined, 'Location', city),
                    _infoCard(Icons.build_outlined, 'Category', serviceType),
                    _infoCard(Icons.verified_outlined, 'KYC Status', kyc),

                    const SizedBox(height: 24),
                    _logoutButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 10),
            Text(
              'Sign Out Account',
              style: AppTypography.label.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.label.copyWith(fontSize: 14, color: const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
