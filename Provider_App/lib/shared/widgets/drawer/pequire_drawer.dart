import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';

class PequireDrawer extends StatelessWidget {
  const PequireDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ─── Header ───
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logos/logo.webp',
                          height: 24,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/logos/wordmark.webp',
                          height: 20,
                          fit: BoxFit.contain,
                          color: Colors.white, // Invert to white if it's a dark background Wordmark
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Scaffold.of(context).closeEndDrawer(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                        color: const Color(0xFF1E293B),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=11',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Provider', style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 14),
                            const SizedBox(width: 4),
                            Text('4.8', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Earnings Peek ───
          Transform.translate(
            offset: const Offset(0, -16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TODAY', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('₹1,280', style: AppTypography.h2.copyWith(color: const Color(0xFF0F172A), fontSize: 20)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THIS WEEK', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('₹5,480', style: AppTypography.h2.copyWith(color: AppColors.primary, fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Pequire Pulse (Achievements) ───
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.vibration_rounded, color: Color(0xFF6366F1), size: 18),
                        const SizedBox(width: 8),
                        Text('PEQUIRE PULSE', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 1)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insights_rounded, color: Color(0xFF6366F1), size: 10),
                          const SizedBox(width: 4),
                          Text('TOP PRO', style: AppTypography.label.copyWith(color: const Color(0xFF6366F1), fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level 12', style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 18)),
                    Text('2,450 / 3,000 XP', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.8,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You\'re in the top 5% of providers this month! Keep it up.',
                  style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 0),
              children: [
                _sectionTitle('ACCOUNT'),
                _menuItem(context, Icons.person_outline_rounded, 'Profile', '/edit-profile'),

                _sectionTitle('ACTIVITY'),
                _menuItem(context, Icons.calendar_today_outlined, 'My Bookings', '/history'),
                _menuItem(context, Icons.account_balance_wallet_outlined, 'Earnings & Payouts', '/earnings'),
                _menuItem(context, Icons.star_border_rounded, 'Reviews & Ratings', '/reviews'),

                _sectionTitle('SUPPORT'),
                _menuItem(context, Icons.help_outline_rounded, 'Help Centre', '/help'),
                _menuItem(context, Icons.settings_outlined, 'Settings', '/settings'),
              ],
            ),
          ),

          // ─── Logout ───
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).closeEndDrawer();
                context.go('/login');
              },
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Log Out', style: AppTypography.label.copyWith(color: const Color(0xFFDC2626), fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          color: const Color(0xFFCBD5E1),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () {
        Scaffold.of(context).closeEndDrawer();
        context.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF475569), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTypography.body.copyWith(color: const Color(0xFF334155), fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFE2E8F0), size: 20),
          ],
        ),
      ),
    );
  }
}


