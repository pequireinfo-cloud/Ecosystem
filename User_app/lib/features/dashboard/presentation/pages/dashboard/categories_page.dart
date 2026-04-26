import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/select_problem_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/laundry_setup_page.dart';
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.plumbing_rounded,
        'label': 'Plumbing Services',
        'description': 'Expert repairs for leaks, pipes, and installations. Available 24/7.',
        'color': AppColors.primary
      },
      {
        'icon': Icons.electrical_services_rounded,
        'label': 'Electrical Works',
        'description': 'Professional wiring, fuse fixes, and appliance setup by certified experts.',
        'color': AppColors.secondary
      },
      {
        'icon': Icons.local_laundry_service_rounded,
        'label': 'Laundry & Dry Clean',
        'description': 'Premium care for your clothes. Wash, fold, and iron with doorstep delivery.',
        'color': AppColors.primary
      },
      {
        'icon': Icons.carpenter_rounded,
        'label': 'Carpentry',
        'description': 'Custom furniture repair and woodwork from skilled craftsmen.',
        'color': AppColors.secondary
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680), // Perfect width for list views
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _AnimatedCategoryListTile(category: categories[index]);
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedCategoryListTile extends StatefulWidget {
  final Map<String, dynamic> category;

  const _AnimatedCategoryListTile({required this.category});

  @override
  State<_AnimatedCategoryListTile> createState() => _AnimatedCategoryListTileState();
}

class _AnimatedCategoryListTileState extends State<_AnimatedCategoryListTile> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.category['color'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
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
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : (_isHovering ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovering ? color.withOpacity(0.3) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_isHovering ? 0.12 : 0.04),
                blurRadius: _isHovering ? 20 : 10,
                offset: Offset(0, _isHovering ? 8 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(_isHovering ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.category['icon'] as IconData,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category['label'] as String,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.category['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isHovering ? color.withOpacity(0.1) : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF8F9FE)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _isHovering ? color : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black38),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
