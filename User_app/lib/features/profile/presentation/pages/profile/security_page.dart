import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _rememberMe = true;
  bool _faceId = false;
  bool _biometricId = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          _buildToggleRow('Remember me', _rememberMe, (val) => setState(() => _rememberMe = val)),
          const SizedBox(height: 16),
          _buildToggleRow('Face ID', _faceId, (val) => setState(() => _faceId = val)),
          const SizedBox(height: 16),
          _buildToggleRow('Biometric ID', _biometricId, (val) => setState(() => _biometricId = val)),
          const SizedBox(height: 16),
          _buildAuthenticatorLink(),
          const SizedBox(height: 32),
          _buildSecurityActionButton('Change PIN', () {}),
          const SizedBox(height: 16),
          _buildSecurityActionButton('Change Password', () {}),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.redesignPurple,
            inactiveTrackColor: Colors.grey.shade200,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatorLink() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Google Authenticator',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.redesignPurple.withOpacity(0.7), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityActionButton(String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redesignPurpleLight,
          foregroundColor: AppColors.redesignPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
