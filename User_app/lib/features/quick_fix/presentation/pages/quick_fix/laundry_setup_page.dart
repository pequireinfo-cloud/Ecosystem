import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'cost_breakdown_page.dart';

class LaundrySetupPage extends StatefulWidget {
  final BookingSession session;

  const LaundrySetupPage({super.key, required this.session});

  @override
  State<LaundrySetupPage> createState() => _LaundrySetupPageState();
}

class _LaundrySetupPageState extends State<LaundrySetupPage> {
  int _itemCount = 1;
  late List<LaundryItem> _items;
  final List<String> _fabricTypes = ['Normal', 'Woolen', 'Cotton', 'Silk', 'Denim', 'Other'];

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  void _initItems() {
    _items = List.generate(_itemCount, (index) => LaundryItem(id: index));
  }

  void _updateItemCount(int delta) {
    setState(() {
      final newCount = _itemCount + delta;
      if (newCount >= 1 && newCount <= 20) {
        _itemCount = newCount;
        
        if (delta > 0) {
          _items.add(LaundryItem(id: _items.length));
        } else {
          _items.removeLast();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuickFixBaseLayout(
      title: 'Laundry Setup',
      initialSheetSize: 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header: Select No. of clothes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Number of clothes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _updateItemCount(-1),
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                      ),
                      Text('$_itemCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => _updateItemCount(1),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List of items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Icon(Icons.local_laundry_service_outlined, color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Image Upload Button (Mocked for Web)
                      GestureDetector(
                        onTap: () {
                          // Mocking Image Upload
                          setState(() {
                            item.rawImageData = 'mock_image_path_${index}.jpg';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Selected')));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: item.rawImageData == null 
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Tap to upload image', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              )
                            : Stack(
                                children: [
                                  Center(child: Icon(Icons.image_rounded, size: 64, color: AppColors.primary.withOpacity(0.5))),
                                  Positioned(
                                    right: 4, top: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () {
                                        setState(() => item.rawImageData = null);
                                      },
                                    ),
                                  )
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Fabric Type:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: item.fabricType,
                        hint: const Text('Select Fabric Type', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _fabricTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          setState(() => item.fabricType = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final allValid = _items.every((i) => i.fabricType != null);
                  if (!allValid) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select fabric type for all items')));
                    return;
                  }
                  
                  widget.session.numberOfClothes = _itemCount;
                  widget.session.laundryItems = _items;
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CostBreakdownPage(session: widget.session)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Review Booking', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
