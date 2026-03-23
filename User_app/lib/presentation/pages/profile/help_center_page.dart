import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = ['General', 'Account', 'Service', 'Payment'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black87)),
              child: const Icon(Icons.more_horiz, color: Colors.black87, size: 20),
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.redesignPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.redesignPurple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactUsTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildCategoryFilter(),
        const SizedBox(height: 24),
        _buildSearchBar(),
        const SizedBox(height: 24),
        _buildFAQItem('What is Hamo?', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
        _buildFAQItem('How to use Hamo?', ''),
        _buildFAQItem('How do I cancel a booking?', ''),
        _buildFAQItem('Is Hamo free to use?', ''),
        _buildFAQItem('How to make offer on Hamo?', ''),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.redesignPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.redesignPurple,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.white,
              shape: StadiumBorder(side: BorderSide(color: AppColors.redesignPurple)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: Icon(Icons.tune_rounded, color: AppColors.redesignPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        trailing: Icon(Icons.arrow_drop_down, color: AppColors.redesignPurple),
        children: [
          if (answer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(answer, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildContactItem(Icons.headset_mic_rounded, 'Customer Service'),
        _buildContactItem(Icons.chat_rounded, 'WhatsApp'),
        _buildContactItem(Icons.language_rounded, 'Website'),
        _buildContactItem(Icons.facebook_rounded, 'Facebook'),
        _buildContactItem(Icons.camera_alt_rounded, 'Twitter'), // Using camera for twitter as placeholder or custom icon
        _buildContactItem(Icons.camera_alt_rounded, 'Instagram'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.redesignPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        onTap: () {},
      ),
    );
  }
}
