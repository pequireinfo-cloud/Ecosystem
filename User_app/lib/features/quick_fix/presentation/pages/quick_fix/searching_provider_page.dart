import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'tracking_page.dart';

class SearchingProviderPage extends StatefulWidget {
  final BookingSession session;

  const SearchingProviderPage({super.key, required this.session});

  @override
  State<SearchingProviderPage> createState() => _SearchingProviderPageState();
}

class _SearchingProviderPageState extends State<SearchingProviderPage> {
  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  Future<void> _startSearch() async {
    // Mocking 3 seconds search delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrackingPage(session: widget.session)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuickFixBaseLayout(
      title: 'Finding Professional',
      initialSheetSize: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Searching nearby experts...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Finding the best ${widget.session.category} professional',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'This usually takes less than a minute',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

