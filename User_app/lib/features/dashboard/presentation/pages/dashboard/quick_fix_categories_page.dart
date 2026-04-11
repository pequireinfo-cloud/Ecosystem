import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/select_problem_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/laundry_setup_page.dart';

import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';

class QuickFixCategoriesPage extends StatelessWidget {
  const QuickFixCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.plumbing_rounded,
        'label': 'Plumbing Services',
        'color': AppColors.primary
      },
      {
        'icon': Icons.electrical_services_rounded,
        'label': 'Electrical Works',
        'color': AppColors.secondary
      },
      {
        'icon': Icons.local_laundry_service_rounded,
        'label': 'Laundry & Dry Clean',
        'color': AppColors.primary
      },
      {
        'icon': Icons.carpenter_rounded,
        'label': 'Carpentry',
        'color': AppColors.secondary
      },
    ];

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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4, // Making them slightly taller for better look in sheet
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _QuickFixCategoryCard(category: category);
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
