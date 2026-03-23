import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/login_role.dart';

export '../../domain/entities/login_role.dart';

class RoleSelectionWidget extends StatelessWidget {
  final LoginRole selectedRole;
  final ValueChanged<LoginRole> onRoleChanged;

  const RoleSelectionWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildRoleButton(
            context,
            'Service Provider',
            LoginRole.serviceProvider,
          ),
          _buildRoleButton(
            context,
            'User',
            LoginRole.user,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String label, LoginRole role) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
