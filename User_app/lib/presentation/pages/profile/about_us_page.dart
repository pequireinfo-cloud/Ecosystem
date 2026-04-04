import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'privacy_policy_page.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pequire',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.0.0 (1)',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            _buildAboutCard(
              'Our Mission',
              'Connecting you with top-rated local professionals in minutes. We handle the stress, you get the results.',
            ),
            const SizedBox(height: 24),
            _buildLinkSection([
              _buildLinkLabel('Terms of Service', () {}),
              _buildLinkLabel('Privacy Policy', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              }),
              _buildLinkLabel('Community Guidelines', () {}),
              _buildLinkLabel('Open Source Licenses', () {}),
            ]),
            const SizedBox(height: 40),
            const Text(
              '© 2026 Pequire Inc. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLinkLabel(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
