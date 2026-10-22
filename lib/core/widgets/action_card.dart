import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// ActionCard - A reusable interactive card widget for highlighting primary user actions
///
/// This card provides a prominent, actionable design for dashboard actions with support for:
/// - Title and descriptive text
/// - Leading icon with customizable primary color
/// - Highlight mode for hero actions with elevated styling
/// - Ripple effect on tap for visual feedback
/// - Minimum touch target size (48x48dp) for accessibility
/// - Proper theming with design tokens
///
/// **Usage Examples:**
///
/// ```dart
/// // Standard action card
/// ActionCard(
///   title: 'Add Produce',
///   description: 'List new crops for sale',
///   icon: Icons.add_circle_outline,
///   primaryColor: AppColors.success,
///   onTap: () => Navigator.push(...),
/// )
///
/// // Highlighted hero action
/// ActionCard(
///   title: 'Where Should I Sell?',
///   description: 'Compare market prices and calculate net revenue',
///   icon: Icons.analytics_outlined,
///   primaryColor: AppColors.primary,
///   isHighlight: true,
///   onTap: () => Navigator.push(...),
/// )
///
/// // Role-specific action
/// ActionCard(
///   title: 'Available Jobs',
///   description: 'Find transport requests near you',
///   icon: Icons.work_outline,
///   primaryColor: AppColors.roleTransporter,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class ActionCard extends StatelessWidget {
  /// The main title text displayed prominently in the card
  final String title;

  /// Descriptive text explaining the action
  final String description;

  /// Icon representing the action
  final IconData icon;

  /// Primary color used for icon and highlight styling
  final Color primaryColor;

  /// Callback function when the card is tapped
  final VoidCallback onTap;

  /// Whether this is a hero/highlight action
  /// When true, applies elevated styling and prominent placement design
  final bool isHighlight;

  /// Creates an ActionCard widget
  ///
  /// All parameters are required except [isHighlight] which defaults to false.
  /// The card automatically ensures minimum touch target size (48x48dp),
  /// applies ripple effects, and uses design tokens for consistent styling.
  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine styling based on highlight mode
    final elevation = isHighlight ? AppTokens.elevationL : AppTokens.elevationS;
    final iconSize = isHighlight ? AppTokens.iconL : AppTokens.iconM;
    final borderRadius = isHighlight ? AppTokens.radiusL : AppTokens.radiusM;

    // Card content layout
    final cardContent = Padding(
      // Use design tokens for consistent padding
      // Larger padding for highlighted cards
      padding: EdgeInsets.all(
        isHighlight ? AppTokens.spaceL : AppTokens.spaceM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with background
          Container(
            width: isHighlight ? AppTokens.avatarL : AppTokens.minTouchTarget,
            height: isHighlight ? AppTokens.avatarL : AppTokens.minTouchTarget,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusM),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: iconSize,
              semanticLabel: title, // Accessibility support
            ),
          ),

          SizedBox(height: AppTokens.spaceM),

          // Title
          Text(
            title,
            style: isHighlight
                ? theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  )
                : theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppTokens.spaceXS),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: isHighlight ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Optional visual indicator for highlighted cards
          if (isHighlight) ...[
            SizedBox(height: AppTokens.spaceM),
            Row(
              children: [
                Text(
                  'Learn more',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: AppTokens.spaceXXS),
                Icon(
                  Icons.arrow_forward,
                  color: primaryColor,
                  size: AppTokens.iconS,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    // Return wrapped in Card with Material and InkWell for ripple effect
    return Card(
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        // Add subtle border for highlighted cards
        side: isHighlight
            ? BorderSide(
                color: primaryColor.withOpacity(0.2),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        // Use primary color for ripple effect
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Semantics(
          button: true,
          enabled: true,
          label: '$title, $description',
          // Indicate if this is a highlighted/primary action
          hint: isHighlight ? 'Featured action' : null,
          child: ConstrainedBox(
            // Ensure minimum touch target height
            constraints: const BoxConstraints(
              minHeight: AppTokens.minTouchTarget,
            ),
            child: cardContent,
          ),
        ),
      ),
    );
  }
}
