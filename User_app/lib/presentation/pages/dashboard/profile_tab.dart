import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import 'orders_page.dart';
import '../profile/manage_profile_page.dart';
import '../profile/security_page.dart';
import '../profile/notifications_settings_page.dart';
import '../profile/language_page.dart';
import '../profile/about_us_page.dart';
import '../profile/help_center_page.dart';
import '../profile/privacy_policy_page.dart';
import '../profile/my_coupons_page.dart';
import 'provider_tracking_broadcast.dart';

class ProfileTab extends StatefulWidget {
  final UserEntity user;
  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildUserCard(),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCouponsPage()));
              },
            ),
          ]),
          _buildSection('Account', [
            _buildMenuItem(
              Icons.account_circle_outlined,
              'Manage Profile',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProfilePage()));
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
                // Placeholder for Payment
              },
            ),
            _buildMenuItem(
              Icons.language_rounded,
              'Language',
              trailing: 'English',
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
              trailing: 'Light',
              onTap: () {
                // In the image this looks like a navigation item but "Theme" often toggles. 
                // Let's keep it consistent with the image which shows text on the right.
              },
            ),
            _buildMenuItem(
              Icons.calendar_today_outlined,
              'Appointments',
              onTap: () {
                // Placeholder or link to OrdersPage as per plan
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
              'Logout',
              isDestructive: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              image: const DecorationImage(
                image: AssetImage('assets/profile_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ronald Richards',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
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
            color: Colors.white.withOpacity(0.5),
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
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_outlined, color: isDestructive ? Colors.red : Colors.black, size: 16),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
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
              const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22)),
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
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4FD2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: const Text('Yes, Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

