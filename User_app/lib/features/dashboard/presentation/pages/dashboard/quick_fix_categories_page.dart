import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/select_problem_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/laundry_setup_page.dart';

import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';

import 'package:pequire_user_app/core/services/api_service.dart';

class QuickFixCategoriesPage extends StatefulWidget {
  const QuickFixCategoriesPage({super.key});

  @override
  State<QuickFixCategoriesPage> createState() => _QuickFixCategoriesPageState();
}

class _QuickFixCategoriesPageState extends State<QuickFixCategoriesPage> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final List<Map<String, dynamic>> defaultCategories = [
      {
        'id': 'fallback_1',
        'label': 'Plumbing Services',
        'icon': Icons.plumbing_rounded,
        'color': AppColors.primary,
        'description': 'Leaky pipes, taps, and toilets fixed'
      },
      {
        'id': 'fallback_2',
        'label': 'Electrical Works',
        'icon': Icons.electrical_services_rounded,
        'color': AppColors.secondary,
        'description': 'Wiring, switches and appliance repairs'
      },
      {
        'id': 'fallback_3',
        'label': 'Laundry & Dry Clean',
        'icon': Icons.local_laundry_service_rounded,
        'color': AppColors.primary,
        'description': 'Wash, fold and dry cleaning services'
      },
      {
        'id': 'fallback_4',
        'label': 'Carpentry',
        'icon': Icons.carpenter_rounded,
        'color': AppColors.secondary,
        'description': 'Furniture repair and woodwork'
      },
    ];

    try {
      final response = await ApiService().get('/categories');
      final List data = response.data;
      
      if (data.isEmpty) return defaultCategories;

      return data.map((cat) => {
        'id': cat['_id'],
        'label': cat['name'],
        'icon': _getIconForCategory(cat['name']),
        'color': _getColorForCategory(cat['name']),
        'description': cat['description']
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      // If API fails, return the default categories so the UI is not empty
      return defaultCategories;
    }
  }

  IconData _getIconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb')) return Icons.plumbing_rounded;
    if (n.contains('electr')) return Icons.electrical_services_rounded;
    if (n.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (n.contains('carpent')) return Icons.carpenter_rounded;
    return Icons.home_repair_service_rounded;
  }

  Color _getColorForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb') || n.contains('laundry')) return AppColors.primary;
    if (n.contains('electr') || n.contains('carpent')) return AppColors.secondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {

    return QuickFixBaseLayout(
      title: 'Quick Fix',
      initialSheetSize: 0.8,
      sheetColor: const Color(0xFF001233),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Book your service',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verified professionals at your doorstep',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories available', style: TextStyle(color: Colors.white)));
                }
                
                final categories = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _QuickFixCategoryCard(category: category);
                  },
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _QuickFixCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;

  const _QuickFixCategoryCard({required this.category});

  @override
  State<_QuickFixCategoryCard> createState() => _QuickFixCategoryCardState();
}

class _QuickFixCategoryCardState extends State<_QuickFixCategoryCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.category['color'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          final session = BookingSession(category: widget.category['label'] as String);
          if (session.category == 'Laundry & Dry Clean') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LaundrySetupPage(session: session)));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SelectProblemPage(session: session)));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isHovering ? 1.0 : 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: _isHovering ? 15 : 8,
                offset: Offset(0, _isHovering ? 6 : 3),
              ),
            ],
            border: Border.all(
              color: _isHovering ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.category['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.category['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001233),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
