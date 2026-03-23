import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.plumbing_rounded,
        'label': 'Plumbing Services',
        'description': 'Expert repairs for leaks, pipes, and installations. Available 24/7.',
        'color': const Color(0xFF2196F3)
      },
      {
        'icon': Icons.electrical_services_rounded,
        'label': 'Electrical Works',
        'description': 'Professional wiring, fuse fixes, and appliance setup by certified experts.',
        'color': const Color(0xFFFF9800)
      },
      {
        'icon': Icons.local_laundry_service_rounded,
        'label': 'Laundry & Dry Clean',
        'description': 'Premium care for your clothes. Wash, fold, and iron with doorstep delivery.',
        'color': const Color(0xFF9C27B0)
      },
      {
        'icon': Icons.carpenter_rounded,
        'label': 'Carpentry',
        'description': 'Custom furniture repair and woodwork from skilled craftsmen.',
        'color': const Color(0xFF795548)
      },
      {
        'icon': Icons.format_paint_rounded,
        'label': 'Painting & Deco',
        'description': 'Give your home a fresh look with our professional interior and exterior painting.',
        'color': const Color(0xFFE91E63)
      },
      {
        'icon': Icons.cleaning_services_rounded,
        'label': 'Home Cleaning',
        'description': 'Deep cleaning for every corner. Eco-friendly products and thorough service.',
        'color': const Color(0xFF4CAF50)
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = category['color'] as Color;
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        category['label'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['description'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
