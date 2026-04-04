import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'English (US)';

  final List<String> _suggested = ['English (US)', 'English (UK)'];
  final List<String> _others = [
    'Mandarin',
    'Hindi',
    'Spanish',
    'French',
    'Arabic',
    'Bengali',
    'Russian',
    'Indonesia'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Language',
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
          _buildSectionHeader('Suggested'),
          ..._suggested.map((lang) => _buildLanguageItem(lang)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionHeader('Language'),
          ..._others.map((lang) => _buildLanguageItem(lang)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String lang) {
    final isSelected = _selectedLanguage == lang;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.redesignPurple : AppColors.redesignPurple.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
