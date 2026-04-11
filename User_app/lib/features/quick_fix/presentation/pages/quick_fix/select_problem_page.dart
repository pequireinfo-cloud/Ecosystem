import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'select_appliance_page.dart';

class SelectProblemPage extends StatefulWidget {
  final BookingSession session;

  const SelectProblemPage({super.key, required this.session});

  @override
  State<SelectProblemPage> createState() => _SelectProblemPageState();
}

class _SelectProblemPageState extends State<SelectProblemPage> {
  String? _selectedProblem;

  List<String> _getProblemsForCategory() {
    switch (widget.session.category) {
      case 'Plumbing Services':
        return ['Leakage', 'Pipe Blockage', 'Installation', 'Tap Repair', 'Water Heater', 'Other'];
      case 'Electrical Works':
        return ['Short Circuit', 'Wiring Issue', 'Installation', 'Fan Repair', 'Switchboard', 'Other'];
      case 'Carpentry':
        return ['Furniture Repair', 'Woodworking', 'Door Lock Fix', 'Installation', 'Cabinet Fix', 'Other'];
      default:
        return ['General Repair', 'Inspection', 'Other'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final problems = _getProblemsForCategory();

    return QuickFixBaseLayout(
      title: 'Select Problem',
      initialSheetSize: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'What do you need help with in ${widget.session.category}?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: problems.length,
              itemBuilder: (context, index) {
                final prob = problems[index];
                final isSelected = _selectedProblem == prob;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedProblem = prob);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prob,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary),
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
                onPressed: _selectedProblem == null
                    ? null
                    : () {
                        widget.session.selectedProblem = _selectedProblem;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectAppliancePage(session: widget.session),
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
                  'Continue',
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
