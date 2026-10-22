import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Status indicator that doesn't rely on color alone
class AccessibleStatusIndicator extends StatelessWidget {
  final String status;
  final Color color;
  final IconData? icon;

  const AccessibleStatusIndicator({
    super.key,
    required this.status,
    required this.color,
    this.icon,
  });

  factory AccessibleStatusIndicator.success({String? label}) {
    return AccessibleStatusIndicator(
      status: label ?? 'Success',
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  factory AccessibleStatusIndicator.error({String? label}) {
    return AccessibleStatusIndicator(
      status: label ?? 'Error',
      color: AppColors.error,
      icon: Icons.error,
    );
  }

  factory AccessibleStatusIndicator.warning({String? label}) {
    return AccessibleStatusIndicator(
      status: label ?? 'Warning',
      color: AppColors.warning,
      icon: Icons.warning,
    );
  }

  factory AccessibleStatusIndicator.info({String? label}) {
    return AccessibleStatusIndicator(
      status: label ?? 'Info',
      color: AppColors.tertiaryDark,
      icon: Icons.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $status',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
