import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Breadcrumb navigation item
class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
  });
}

/// Breadcrumb navigation component
class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? textColor;
  final Color? activeColor;

  const Breadcrumb({
    super.key,
    required this.items,
    this.textColor,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.textSecondary;
    final active = activeColor ?? AppColors.primary;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildBreadcrumbItem(
            context,
            items[i],
            isLast: i == items.length - 1,
            textColor: i == items.length - 1 ? active : color,
          ),
          if (i < items.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spaceXS,
              ),
              child: Icon(
                Icons.chevron_right,
                size: AppTokens.iconS,
                color: color,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item, {
    required bool isLast,
    required Color textColor,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: AppTokens.iconS,
            color: textColor,
          ),
          const SizedBox(width: AppTokens.spaceXXS),
        ],
        Text(
          item.label,
          style: AppTypography.bodySmall.copyWith(
            color: textColor,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );

    if (isLast || item.route == null) {
      return content;
    }

    return InkWell(
      onTap: () {
        if (item.route != null) {
          Navigator.pushNamed(context, item.route!);
        }
      },
      borderRadius: BorderRadius.circular(AppTokens.radiusXS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceXXS,
          vertical: AppTokens.spaceXXS,
        ),
        child: content,
      ),
    );
  }
}
