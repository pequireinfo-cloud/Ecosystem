import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'cost_breakdown_page.dart';

class SelectAppliancePage extends StatefulWidget {
  final BookingSession session;

  const SelectAppliancePage({super.key, required this.session});

  @override
  State<SelectAppliancePage> createState() => _SelectAppliancePageState();
}

class _SelectAppliancePageState extends State<SelectAppliancePage> {
  String? _selectedAppliance;

  List<String> _getAppliances() {
    switch (widget.session.category) {
      case 'Plumbing Services':
        return ['Kitchen Sink', 'Wash Basin', 'Toilet', 'Shower', 'Bathtub', 'Water Tank', 'Other'];
      case 'Electrical Works':
        return ['AC (Air Conditioner)', 'Refrigerator', 'Washing Machine', 'Ceiling Fan', 'Main Panel/Meter', 'Switchboard', 'Other'];
      case 'Carpentry':
        return ['Bed', 'Wardrobe', 'Dining Table', 'Chair', 'Door', 'Window', 'Cabinet', 'Other'];
      default:
        return ['General Household Item', 'Other'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appliances = _getAppliances();

    return QuickFixBaseLayout(
      title: 'Select Appliance',
      initialSheetSize: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Which appliance needs attention?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: appliances.length,
              itemBuilder: (context, index) {
                final appStr = appliances[index];
                final isSelected = _selectedAppliance == appStr;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAppliance = appStr);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_repair_service_rounded,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedAppliance == null
                    ? null
                    : () {
                        widget.session.selectedAppliance = _selectedAppliance;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CostBreakdownPage(session: widget.session),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue to Review',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
