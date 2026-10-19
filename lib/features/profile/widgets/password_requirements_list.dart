import 'package:flutter/material.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/utils/validators/password_validator.dart';

/// List of password requirements with checkmarks
class PasswordRequirementsList extends StatelessWidget {
  final String password;

  const PasswordRequirementsList({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = PasswordValidator.getPasswordRequirements(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must contain:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...requirements.map((req) => _buildRequirement(req)),
      ],
    );
  }

  Widget _buildRequirement(PasswordRequirement requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            requirement.isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: requirement.isMet ? AppColors.success : AppColors.disabled,
          ),
          const SizedBox(width: 8),
          Text(
            requirement.description,
            style: TextStyle(
              fontSize: 12,
              color: requirement.isMet ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
