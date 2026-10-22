import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// DashboardCard - A reusable card widget for displaying agricultural metrics and data
///
/// This card provides a consistent design for dashboard content with support for:
/// - Title and optional subtitle
/// - Leading icon with customizable color
/// - Optional trailing widget (badges, arrows, etc.)
/// - Tap handling for navigation
/// - Proper theming with design tokens
///
/// **Usage Examples:**
///
/// ```dart
/// // Simple card with title and icon
/// DashboardCard(
///   title: 'Active Listings',
///   icon: Icons.shopping_bag_outlined,
/// )
///
/// // Card with subtitle and custom icon color
/// DashboardCard(
///   title: 'My Farms',
///   subtitle: '3 farms registered',
///   icon: Icons.agriculture_outlined,
///   iconColor: AppColors.success,
/// )
///
/// // Interactive card with navigation
/// DashboardCard(
///   title: 'Market Prices',
///   subtitle: 'View current rates',
///   icon: Icons.trending_up,
///   onTap: () => Navigator.push(...),
///   trailing: Icon(Icons.arrow_forward_ios, size: 16),
/// )
///
/// // Card with badge
/// DashboardCard(
///   title: 'Pending Orders',
///   icon: Icons.receipt_long_outlined,
///   trailing: Badge(
///     label: Text('5'),
///     backgroundColor: AppColors.error,
///   ),
/// )
/// ```
class DashboardCard extends StatelessWidget {
  /// The main title text displayed in the card
  final String title;

  /// Optional subtitle text displayed below the title
  final String? subtitle;

  /// Icon displayed on the left side of the card
  final IconData icon;

  /// Color for the icon (defaults to primary color if not specified)
  final Color? iconColor;

  /// Optional widget displayed on the right side (badges, arrows, etc.)
  final Widget? trailing;

  /// Callback function when the card is tapped
  /// If null, the card will not be interactive
  final VoidCallback? onTap;

  /// Creates a DashboardCard widget
  ///
  /// The [title] and [icon] parameters are required.
  /// The card automatically applies theme colors, spacing tokens,
  /// border radius, and elevation from the design system.
  const DashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use custom icon color or default to primary
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    // Build the card content
    final cardContent = Padding(
      // Use design tokens for consistent padding
      padding: const EdgeInsets.all(AppTokens.spaceM),
      child: Row(
        children: [
          // Icon container with background
          Container(
            width: AppTokens.minTouchTarget,
            height: AppTokens.minTouchTarget,
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusS),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: AppTokens.iconM,
              semanticLabel: title, // Accessibility support
            ),
          ),
          
          SizedBox(width: AppTokens.spaceM),
          
          // Title and subtitle column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTokens.spaceXXS),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Trailing widget if provided
          if (trailing != null) ...[
            SizedBox(width: AppTokens.spaceS),
            trailing!,
          ],
        ],
      ),
    );

    // Return wrapped in Card with Material
    return Card(
      // Use theme card configuration (elevation, radius, colors already set)
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Semantics(
                button: true,
                enabled: true,
                label: subtitle != null
                    ? '$title, $subtitle'
                    : title,
                child: cardContent,
              ),
            )
          : Semantics(
              label: subtitle != null
                  ? '$title, $subtitle'
                  : title,
              child: cardContent,
            ),
    );
  }
}
