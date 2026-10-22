import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/tokens.dart';

/// RoleBadge - A widget that displays a user's role with appropriate styling
/// 
/// Displays role name with role-specific background color using the Agricultural
/// Earth-Tone color scheme. The badge uses accessible contrast ratios and
/// rounded corners for a modern, friendly appearance.
/// 
/// Example usage:
/// ```dart
/// RoleBadge(role: 'farmer')
/// RoleBadge(role: 'buyer')
/// RoleBadge(role: 'transporter')
/// RoleBadge(role: 'bureau')
/// ```
/// 
/// The widget automatically:
/// - Maps role to appropriate color (Farmer: green, Buyer: brown, Transporter: gold, Bureau: blue)
/// - Uses white text for sufficient contrast (except transporter which uses dark text)
/// - Applies small border radius for rounded corners
/// - Provides proper spacing and padding for readability
class RoleBadge extends StatelessWidget {
  /// The user role to display (farmer, buyer, transporter, bureau)
  final String role;

  /// Optional custom padding (defaults to small horizontal padding)
  final EdgeInsetsGeometry? padding;

  const RoleBadge({
    super.key,
    required this.role,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.getRoleColor(role);
    
    // Use dark text on transporter (golden) background for accessibility
    // All other roles use white text
    final textColor = role.toLowerCase() == 'transporter'
        ? AppColors.textPrimary
        : AppColors.textOnPrimary;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceS,
            vertical: AppTokens.spaceXS,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusS),
      ),
      child: Text(
        _formatRoleName(role),
        style: AppTypography.roleBadge.copyWith(color: textColor),
      ),
    );
  }

  /// Formats the role name for display
  /// Capitalizes first letter and handles special cases
  String _formatRoleName(String role) {
    final normalized = role.toLowerCase().trim();
    
    // Handle special cases
    if (normalized == 'bureau' || normalized == 'bureau officer') {
      return 'Bureau Officer';
    }
    
    // Capitalize first letter
    if (normalized.isEmpty) return '';
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}
