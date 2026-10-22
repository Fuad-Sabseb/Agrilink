import 'package:flutter/material.dart';
import 'colors.dart';


/// Text Style Helpers for Consistent Color Usage
/// 
/// Provides pre-configured text styles that ensure WCAG AA compliance
/// and proper color contrast across different backgrounds.
/// 
/// **Usage**:
/// ```dart
/// // Text on primary green background
/// Text('Active', style: AppTextStyles.onPrimary(context))
/// 
/// // Text on golden/transporter background
/// Text('Deliveries', style: AppTextStyles.onGolden(context))
/// 
/// // Primary heading
/// Text('Dashboard', style: AppTextStyles.heading(context))
/// ```
/// 
/// **Why Use These?**:
/// - Automatic WCAG AA compliance
/// - Dark theme support
/// - Consistent text hierarchy
/// - Reduced color-related bugs
/// 
class AppTextStyles {
  // Private constructor
  AppTextStyles._();

  // ==========================================================================
  // TEXT ON COLORED BACKGROUNDS
  // ==========================================================================
  
  /// Text style for use on Primary (green) backgrounds
  /// 
  /// Uses white text which has 5.00:1 contrast on primary green.
  /// Safe for all text sizes.
  /// 
  /// **Example**:
  /// ```dart
  /// Container(
  ///   color: AppColors.primary,
  ///   child: Text('Add Produce', style: AppTextStyles.onPrimary(context)),
  /// )
  /// ```
  static TextStyle onPrimary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textOnPrimary,
      fontWeight: FontWeight.w500,
    );
  }
  
  /// Text style for use on Secondary (coffee brown) backgrounds
  /// 
  /// Uses white text which has 5.79:1 contrast on coffee brown.
  /// Safe for all text sizes.
  static TextStyle onSecondary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textOnPrimary,
      fontWeight: FontWeight.w500,
    );
  }
  
  /// Text style for use on Golden/Accent backgrounds ⚠️ CRITICAL
  /// 
  /// **ALWAYS uses DARK text** (not white!) because:
  /// - White on golden: 2.10:1 contrast ❌ (fails WCAG)
  /// - Dark on golden: 7.25:1 contrast ✅ (passes WCAG AA)
  /// 
  /// **Example**:
  /// ```dart
  /// Container(
  ///   color: AppColors.accent, // Golden
  ///   child: Text('Premium', style: AppTextStyles.onGolden(context)),
  /// )
  /// ```
  static TextStyle onGolden(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimary, // Dark text, NOT white!
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Text style for use on Tertiary (sky blue) backgrounds
  /// 
  /// Uses large white text because:
  /// - White on sky blue: 3.29:1 contrast (passes for large text only)
  /// 
  /// **WARNING**: Only use for large text (≥18pt or ≥14pt bold)
  /// For normal text, use a darker background or dark text color.
  static TextStyle onTertiary(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: AppColors.textOnPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20, // Large text required
    );
  }
  
  /// Text style for use on Success (green) backgrounds
  /// 
  /// Uses dark text because white on success has insufficient contrast.
  static TextStyle onSuccess(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Text style for use on Warning (orange) backgrounds
  /// 
  /// Uses dark text because white on warning has insufficient contrast.
  static TextStyle onWarning(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Text style for use on Error (red) backgrounds
  /// 
  /// Uses white text which has 5.44:1 contrast on error red.
  static TextStyle onError(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.textOnPrimary,
      fontWeight: FontWeight.w600,
    );
  }

  // ==========================================================================
  // ROLE-SPECIFIC TEXT STYLES
  // ==========================================================================
  
  /// Text for Farmer role badges/cards
  static TextStyle forFarmerRole(BuildContext context) {
    return onPrimary(context); // Green background → white text
  }
  
  /// Text for Buyer role badges/cards
  static TextStyle forBuyerRole(BuildContext context) {
    return onSecondary(context); // Brown background → white text
  }
  
  /// Text for Transporter role badges/cards ⚠️ USES DARK TEXT
  static TextStyle forTransporterRole(BuildContext context) {
    return onGolden(context); // Golden background → DARK text
  }
  
  /// Text for Bureau role badges/cards
  static TextStyle forBureauRole(BuildContext context) {
    return onTertiary(context); // Sky blue background → large white text
  }

  // ==========================================================================
  // TEXT HIERARCHY ON LIGHT BACKGROUNDS
  // ==========================================================================
  
  /// Primary heading text (titles, headers)
  /// 
  /// Uses textPrimary (#2C241E) with 13.52:1 contrast on background.
  /// Excellent readability.
  static TextStyle heading(BuildContext context, {TextStyle? base}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return (base ?? theme.textTheme.headlineMedium!).copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
  }
  
  /// Body text (paragraphs, descriptions)
  /// 
  /// Uses textPrimary (#2C241E) with excellent contrast.
  static TextStyle body(BuildContext context, {TextStyle? base}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return (base ?? theme.textTheme.bodyMedium!).copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );
  }
  
  /// Secondary text (labels, captions, metadata)
  /// 
  /// Uses textSecondary (#6B6258) with 5.30:1 contrast.
  static TextStyle secondary(BuildContext context, {TextStyle? base}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return (base ?? theme.textTheme.bodyMedium!).copyWith(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }
  
  /// Tertiary text (hints, disabled, subtle info)
  /// 
  /// Uses textTertiary (#948A7E) with 3.01:1 contrast.
  /// **Only suitable for large text** (≥18pt). For normal text, use secondary().
  static TextStyle tertiary(BuildContext context, {TextStyle? base}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return (base ?? theme.textTheme.bodyLarge!).copyWith(
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
      fontSize: 18, // Ensure large text for accessibility
    );
  }

  // ==========================================================================
  // SEMANTIC TEXT STYLES
  // ==========================================================================
  
  /// Success text color (as text, not background)
  /// 
  /// Uses successDark for proper contrast on light backgrounds.
  static TextStyle success(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.successDark,
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Warning text color (as text, not background)
  /// 
  /// Uses warningDark for proper contrast on light backgrounds.
  static TextStyle warning(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.warningDark,
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Error text color (as text, not background)
  /// 
  /// Uses error color which has proper contrast on light backgrounds.
  static TextStyle error(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.error,
      fontWeight: FontWeight.w600,
    );
  }
  
  /// Info text color (as text, not background)
  /// 
  /// Uses tertiaryDark for proper contrast on light backgrounds.
  static TextStyle info(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: AppColors.tertiaryDark,
      fontWeight: FontWeight.w500,
    );
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================
  
  /// Get appropriate text color for any role
  /// 
  /// Returns the correct text style based on role color.
  /// Handles special cases (golden needs dark text, etc.)
  static TextStyle forRole(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return forFarmerRole(context);
      case 'buyer':
        return forBuyerRole(context);
      case 'transporter':
        return forTransporterRole(context);
      case 'bureau':
      case 'bureau officer':
        return forBureauRole(context);
      default:
        return onPrimary(context);
    }
  }
  
  /// Get text style for colored container backgrounds
  /// 
  /// Automatically determines if white or dark text is needed
  /// based on background color luminance.
  static TextStyle onColor(BuildContext context, Color backgroundColor) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = backgroundColor.computeLuminance();
    
    // If background is bright, use dark text; if dark, use light text
    final textColor = luminance > 0.5 
        ? AppColors.textPrimary 
        : AppColors.textOnPrimary;
    
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: textColor,
      fontWeight: FontWeight.w500,
    );
  }
}

/// Extension methods for easy access to text styles
extension TextStyleHelpers on BuildContext {
  /// Quick access to text style helpers
  /// 
  /// **Usage**:
  /// ```dart
  /// Text('Title', style: context.textStyles.heading())
  /// Text('Body', style: context.textStyles.body())
  /// ```
  AppTextStylesHelper get textStyles => AppTextStylesHelper(this);
}

class AppTextStylesHelper {
  final BuildContext context;
  
  AppTextStylesHelper(this.context);
  
  TextStyle heading({TextStyle? base}) => AppTextStyles.heading(context, base: base);
  TextStyle body({TextStyle? base}) => AppTextStyles.body(context, base: base);
  TextStyle secondary({TextStyle? base}) => AppTextStyles.secondary(context, base: base);
  TextStyle tertiary({TextStyle? base}) => AppTextStyles.tertiary(context, base: base);
  
  TextStyle onPrimary() => AppTextStyles.onPrimary(context);
  TextStyle onSecondary() => AppTextStyles.onSecondary(context);
  TextStyle onGolden() => AppTextStyles.onGolden(context);
  TextStyle onTertiary() => AppTextStyles.onTertiary(context);
  TextStyle onSuccess() => AppTextStyles.onSuccess(context);
  TextStyle onWarning() => AppTextStyles.onWarning(context);
  TextStyle onError() => AppTextStyles.onError(context);
  
  TextStyle success() => AppTextStyles.success(context);
  TextStyle warning() => AppTextStyles.warning(context);
  TextStyle error() => AppTextStyles.error(context);
  TextStyle info() => AppTextStyles.info(context);
  
  TextStyle forRole(String role) => AppTextStyles.forRole(context, role);
  TextStyle onColor(Color color) => AppTextStyles.onColor(context, color);
}
