import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:agrolink/core/utils/validators/password_validator.dart';

/// Visual indicator for password strength
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordValidator.calculateStrength(password);
    final color = _getColor(strength);
    final label = _getLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _getValue(strength),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getColor(PasswordStrengthLevel strength) {
    switch (strength) {
      case PasswordStrengthLevel.weak:
        return AppColors.error;
      case PasswordStrengthLevel.medium:
        return AppColors.warning;
      case PasswordStrengthLevel.strong:
        return AppColors.success;
    }
  }

  String _getLabel(PasswordStrengthLevel strength) {
    switch (strength) {
      case PasswordStrengthLevel.weak:
        return 'Weak';
      case PasswordStrengthLevel.medium:
        return 'Medium';
      case PasswordStrengthLevel.strong:
        return 'Strong';
    }
  }

  double _getValue(PasswordStrengthLevel strength) {
    switch (strength) {
      case PasswordStrengthLevel.weak:
        return 0.33;
      case PasswordStrengthLevel.medium:
        return 0.66;
      case PasswordStrengthLevel.strong:
        return 1.0;
    }
  }
}
