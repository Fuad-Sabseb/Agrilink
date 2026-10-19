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
  /// Falls back to system fonts on low-end devices
  static TextStyle get _baseTextStyle => GoogleFonts.notoSans(
    color: AppColors.textPrimary,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.0,
  );

  // ============================================================================
  // DISPLAY STYLES - Large, impactful text
  // ============================================================================
  
  /// Display Large - 32sp, Bold
  /// Use for splash screens and major section headers
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  /// Display Medium - 28sp, Bold
  /// Use for dashboard headers
  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.28,
    letterSpacing: -0.25,
  );
  
  /// Display Small - 24sp, SemiBold
  /// Use for page titles
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
  
  /// Body Large - 16sp, Regular
  /// Primary body text for readable content
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  /// Body Medium - 14sp, Regular
  /// Standard body text
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
    letterSpacing: 0.25,
  );
  
  /// Body Small - 12sp, Regular
  /// Supporting text, metadata
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
  
  /// Price Large - 32sp, Bold
  /// Major price displays
  static TextStyle get priceLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );
  
  /// Price Medium - 24sp, SemiBold
  /// Card-level prices
  static TextStyle get priceMedium => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.primary,
  );
  
  /// Price Small - 16sp, SemiBold
  /// List item prices
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
