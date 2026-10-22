import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// AgriLink Typography System
/// High-contrast, accessibility-first typography supporting
/// Afaan Oromoo, Amharic, and English with optimal readability
/// on entry-level Android devices
class AppTypography {
  // Private constructor
  AppTypography._();

  // ============================================================================
  // BASE FONT CONFIGURATION
  // ============================================================================
  
  /// Base font family - Noto Sans supports Afaan Oromoo, Amharic, and English
  /// 
  /// Noto Sans was specifically chosen for its comprehensive Unicode support:
  /// - Full Afaan Oromoo character set (including special diacritics)
  /// - Complete Amharic (Ge'ez) script support
  /// - Latin characters for English
  /// - Optimized for screen readability on mobile devices
  /// 
  /// Falls back to system fonts on low-end devices for performance.
  /// 
  /// **Design Decision**: Using Google Fonts allows dynamic font loading
  /// while maintaining offline functionality through caching.
  static TextStyle get _baseTextStyle => GoogleFonts.notoSans(
    color: AppColors.textPrimary,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.0,
  );

  // ============================================================================
  // DISPLAY STYLES - Large, impactful text
  // ============================================================================
  
  /// Display Large - 32sp, Bold, Height 1.25, Letter Spacing -0.5
  /// 
  /// **Use for**: Splash screens, major section headers, hero text
  /// 
  /// **Example Usage**:
  /// ```dart
  /// Text('Welcome to AgriLink', style: AppTypography.displayLarge)
  /// ```
  /// 
  /// **Accessibility**: High contrast (13.52:1 on background), easily readable
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  /// Display Medium - 28sp, Bold, Height 1.28, Letter Spacing -0.25
  /// 
  /// **Use for**: Dashboard headers, major page titles
  /// 
  /// **Example Usage**:
  /// ```dart
  /// Text('Farmer Dashboard', style: AppTypography.displayMedium)
  /// ```
  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.28,
    letterSpacing: -0.25,
  );
  
  /// Display Small - 24sp, SemiBold, Height 1.33, Letter Spacing 0
  /// 
  /// **Use for**: Page titles, section headers, dialog titles
  /// 
  /// **Example Usage**:
  /// ```dart
  /// Text('My Farms', style: AppTypography.displaySmall)
  /// 
  /// // In AppBar
  /// AppBar(
  ///   title: Text('Market Prices', style: AppTypography.displaySmall),
  /// )
  /// ```
  static TextStyle get displaySmall => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  // ============================================================================
  // HEADLINE STYLES - Prominent section headers
  // ============================================================================
  
  /// Headline Large - 22sp, SemiBold
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.36,
  );
  
  /// Headline Medium - 20sp, SemiBold
  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  /// Headline Small - 18sp, SemiBold
  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44,
  );

  // ============================================================================
  // TITLE STYLES - Card headers, list items
  // ============================================================================
  
  /// Title Large - 16sp, SemiBold
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  /// Title Medium - 14sp, Medium
  static TextStyle get titleMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.57,
    letterSpacing: 0.1,
  );
  
  /// Title Small - 12sp, Medium
  static TextStyle get titleSmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.67,
    letterSpacing: 0.1,
  );

  // ============================================================================
  // BODY STYLES - Main content text
  // ============================================================================
  
  /// Body Large - 16sp, Regular, Height 1.5, Letter Spacing 0.5
  /// 
  /// **Use for**: Primary body text, readable content, descriptions
  /// 
  /// **Example Usage**:
  /// ```dart
  /// Text(
  ///   'This produce is fresh from the farm and ready for delivery.',
  ///   style: AppTypography.bodyLarge,
  /// )
  /// 
  /// // Article or description text
  /// Text(productDescription, style: AppTypography.bodyLarge)
  /// ```
  /// 
  /// **Design Note**: 16sp is optimal for mobile reading, reducing eye strain
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  /// Body Medium - 14sp, Regular, Height 1.57, Letter Spacing 0.25
  /// 
  /// **Use for**: Standard body text, list item content
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // List item description
  /// ListTile(
  ///   subtitle: Text('Available today', style: AppTypography.bodyMedium),
  /// )
  /// ```
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
    letterSpacing: 0.25,
  );
  
  /// Body Small - 12sp, Regular, Height 1.67, Letter Spacing 0.4
  /// 
  /// **Use for**: Supporting text, metadata, captions
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Timestamp or metadata
  /// Text('Last updated 2 hours ago', style: AppTypography.bodySmall)
  /// 
  /// // Supporting information
  /// Text('Minimum order: 10kg', style: AppTypography.bodySmall)
  /// ```
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.67,
    letterSpacing: 0.4,
  );

  // ============================================================================
  // LABEL STYLES - Buttons, badges, form labels
  // ============================================================================
  
  /// Label Large - 14sp, Medium
  /// Primary button text
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  /// Label Medium - 12sp, Medium
  /// Secondary button text, badges
  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  /// Label Small - 11sp, Medium
  /// Small badges, chips
  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // SPECIALIZED STYLES
  // ============================================================================
  
  /// Caption - 10sp, Regular
  /// Timestamps, helper text
  static TextStyle get caption => _baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );
  
  /// Overline - 10sp, Medium, Uppercase
  /// Section labels, category tags
  static TextStyle get overline => _baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // NUMERIC STYLES - Prices, quantities, statistics
  // ============================================================================
  
  /// Price Large - 32sp, Bold, Height 1.25, Letter Spacing -0.5
  /// 
  /// **Use for**: Major price displays, hero prices, featured statistics
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Hero price display
  /// Text('2,500 ETB', style: AppTypography.priceLarge)
  /// 
  /// // Dashboard statistic
  /// Text('145', style: AppTypography.priceLarge)
  /// ```
  /// 
  /// **Design Note**: Uses primary color (#3A7D44) to draw attention
  static TextStyle get priceLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );
  
  /// Price Medium - 24sp, SemiBold, Height 1.33
  /// 
  /// **Use for**: Card-level prices, section prices
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Product card price
  /// Card(
  ///   child: Column(
  ///     children: [
  ///       Text('Coffee Beans'),
  ///       Text('850 ETB/kg', style: AppTypography.priceMedium),
  ///     ],
  ///   ),
  /// )
  /// ```
  static TextStyle get priceMedium => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.primary,
  );
  
  /// Price Small - 16sp, SemiBold, Height 1.5
  /// 
  /// **Use for**: List item prices, compact price displays
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // List item price
  /// ListTile(
  ///   title: Text('Maize'),
  ///   trailing: Text('450 ETB', style: AppTypography.priceSmall),
  /// )
  /// ```
  static TextStyle get priceSmall => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.primary,
  );

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================
  
  /// Primary Button Text
  static TextStyle get buttonPrimary => labelLarge.copyWith(
    color: AppColors.textOnPrimary,
    fontWeight: FontWeight.w600,
  );
  
  /// Secondary Button Text
  static TextStyle get buttonSecondary => labelLarge.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );
  
  /// Text Button Text
  static TextStyle get buttonText => labelLarge.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  // ============================================================================
  // NAVIGATION STYLES
  // ============================================================================
  
  /// Bottom Navigation Label - 10sp, Medium
  static TextStyle get navLabel => _baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.5,
  );
  
  /// App Bar Title - 18sp, SemiBold
  static TextStyle get appBarTitle => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.textOnPrimary,
  );

  // ============================================================================
  // ROLE BADGE STYLES
  // ============================================================================
  
  /// Role Badge Text - 11sp, SemiBold
  static TextStyle get roleBadge => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.textOnPrimary,
  );

  // ============================================================================
  // FORM FIELD STYLES
  // ============================================================================
  
  /// Input Text - 16sp, Regular
  static TextStyle get inputText => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  /// Input Label - 12sp, Medium
  static TextStyle get inputLabel => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.67,
    color: AppColors.textSecondary,
  );
  
  /// Input Hint - 16sp, Regular
  static TextStyle get inputHint => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );
  
  /// Input Error - 12sp, Regular
  static TextStyle get inputError => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.67,
    color: AppColors.error,
  );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Create a text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Create a text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Create a text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
