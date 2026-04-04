import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeMode _selectedTheme = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Theme Settings',
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
      body: Column(
        children: [
          _buildThemePreview(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'APPEARANCE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _buildThemeOption('Light Mode', 'Bright and clean look', ThemeMode.light, Icons.light_mode_rounded),
                _buildThemeOption('Dark Mode', 'Easy on the eyes in the dark', ThemeMode.dark, Icons.dark_mode_rounded),
                _buildThemeOption('System Default', 'Sync with your device settings', ThemeMode.system, Icons.settings_suggest_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview() {
    final isDark = _selectedTheme == ThemeMode.dark;
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: isDark ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: const Icon(Icons.dark_mode_rounded, size: 80, color: Colors.yellow),
          ),
          AnimatedOpacity(
            opacity: isDark ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: const Icon(Icons.light_mode_rounded, size: 80, color: Colors.orange),
          ),
          Positioned(
            bottom: 20,
            child: Text(
              isDark ? 'Midnight Aura' : 'Classic Day',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String subtitle, ThemeMode mode, IconData icon) {
    final isSelected = _selectedTheme == mode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isSelected ? AppColors.secondary : Colors.grey, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: isSelected
            ? const Icon(Icons.radio_button_checked_rounded, color: AppColors.secondary)
            : const Icon(Icons.radio_button_off_rounded, color: Colors.grey),
        onTap: () => setState(() => _selectedTheme = mode),
      ),
    );
  }
}
