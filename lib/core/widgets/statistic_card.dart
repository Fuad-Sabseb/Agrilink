import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A card widget displaying a statistic with label, value, icon, and optional trend indicator.
/// 
/// This widget is designed for dashboard displays and follows the Agricultural Earth-Tone
/// design system with consistent styling, prominent value display, and accessibility support.
/// 
/// Features:
/// - Large, prominent value text
/// - Trend indicator with up/down arrow
/// - Color-coded trend (green for positive, red for negative)
/// - Consistent card styling with design tokens
/// - Accessible touch targets (48x48dp minimum)
/// 
/// Example usage:
/// ```dart
/// StatisticCard(
///   label: 'Active Listings',
///   value: '12',
///   icon: Icons.list,
///   color: AppColors.primary,
///   trend: '+3',
///   trendPositive: true,
/// )
/// ```
class StatisticCard extends StatelessWidget {
  /// The label text displayed above the value
  final String label;
  
  /// The main statistic value to display prominently
  final String value;
  
  /// The icon displayed in the card
  final IconData icon;
  
  /// Optional color for the icon and card accent (defaults to primary color)
  final Color? color;
  
  /// Optional trend indicator text (e.g., '+3%', '-2', '↑ 15%')
  final String? trend;
  
  /// Whether the trend is positive (true) or negative (false)
  /// - true: Green up arrow
  /// - false: Red down arrow
  final bool? trendPositive;

  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and trend row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon with colored background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: 24,
                  ),
                ),
                // Trend indicator (if provided)
                if (trend != null && trendPositive != null)
                  _buildTrendIndicator(theme),
              ],
            ),
            const SizedBox(height: 16),
            // Label
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Value (prominently styled)
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: effectiveColor,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the trend indicator widget with arrow and color coding
  Widget _buildTrendIndicator(ThemeData theme) {
    final isPositive = trendPositive ?? true;
    final trendColor = isPositive ? AppColors.success : AppColors.error;
    final trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 16,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          Text(
            trend!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
