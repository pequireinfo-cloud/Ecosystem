import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/l10n/app_localizations.dart';

import 'package:pequire_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:pequire_user_app/core/theme/theme_cubit.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'orders_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/manage_profile_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/security_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/notifications_settings_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/language_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/about_us_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/help_center_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/privacy_policy_page.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/my_coupons_page.dart';
import 'provider_tracking_broadcast.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'package:pequire_user_app/core/widgets/pequire_shimmer.dart';
import 'package:pequire_user_app/features/profile/presentation/pages/profile/payment_methods_page.dart';

class ProfileTab extends StatefulWidget {
  final UserEntity user;
  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = sl<ProfileBloc>()..add(GetProfile());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          UserEntity currentUser = widget.user;
          if (state is ProfileLoaded) {
            currentUser = state.user;
          }
          
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                l10n.profile,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: state is ProfileLoading && state is! ProfileLoaded
                ? PequireShimmer.profileTab()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildUserCard(currentUser),
                      const SizedBox(height: 24),
                      _buildSection('My Order & Rewards', [
                        _buildMenuItem(
                          Icons.shopping_bag_outlined,
                          'My Orders',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.stars_rounded,
                          'My Rewards',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyCouponsPage(user: currentUser)));
                          },
                        ),
                      ]),
                      _buildSection('Account', [
                        _buildMenuItem(
                          Icons.account_circle_outlined,
                          'Manage Profile',
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: BlocProvider.of<ProfileBloc>(context),
                                  child: ManageProfilePage(user: currentUser),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          Icons.lock_outline_rounded,
                          'Password & Security',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.notifications_none_rounded,
                          'Notifications',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsSettingsPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.account_balance_wallet_outlined,
                          'Payment',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.language_rounded,
                          l10n.language,
                          trailing: Localizations.localeOf(context).languageCode == 'en' ? l10n.english : l10n.hindi,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguagePage()));
                          },
                        ),
                      ]),
                      _buildSection('Preferences', [
                        _buildMenuItem(
                          Icons.list_alt_rounded,
                          'About Us',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.palette_outlined,
                          'Theme',
                          trailing: context.watch<ThemeCubit>().state == ThemeMode.light ? 'Light' : 'Dark',
                          onTap: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                        _buildMenuItem(
                          Icons.calendar_today_outlined,
                          'Appointments',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()));
                          },
                        ),
                      ]),
                      _buildSection('Support', [
                        _buildMenuItem(
                          Icons.help_outline_rounded,
                          'Help Center',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.privacy_tip_outlined,
                          'Privacy & Policy',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
                          },
                        ),
                        _buildMenuItem(
                          Icons.logout_rounded,
                          l10n.logout,
                          isDestructive: true,
                          onTap: () => _showLogoutDialog(context, l10n),
                        ),
                      ]),
                      const SizedBox(height: 40),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: user.avatarUrl != null 
                  ? NetworkImage(user.avatarUrl!) as ImageProvider
                  : const AssetImage('assets/profile_avatar.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? user.nickname ?? user.email.split('@')[0],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStreakBadge(user.currentStreak),
                    const SizedBox(width: 8),
                    _buildPointsBadge(user.rewardPoints),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14),
          const SizedBox(width: 4),
          Text(
            'Streak: $streak',
            style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.redesignPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redesignPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.redesignPurple, size: 14),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: const TextStyle(color: AppColors.redesignPurple, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
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
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailing, bool isDestructive = false, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : theme.colorScheme.onSurface, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.grey,
                fontSize: 14,
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey.shade400, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDED9F5),
                        foregroundColor: const Color(0xFF6B4FD2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4FD2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: Text('Yes, ${l10n.logout}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}


