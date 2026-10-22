import 'package:flutter/material.dart';

/// AgriLink Color Palette — Earth-Tones Agricultural (Bold Approach)
/// 
/// A modern, premium agricultural technology design inspired by
/// fertile soil, green crops, Ethiopian coffee culture, and golden harvests.
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// WCAG AA ACCESSIBILITY COMPLIANCE
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// This color system has been audited for WCAG 2.1 Level AA compliance.
/// 
/// ✅ FULLY COMPLIANT:
/// - Dark theme (100% pass rate)
/// - Primary/Secondary text colors
/// - Error colors
/// - Buyer role colors
/// - Dark theme containers
/// 
/// ⚠️ REQUIRES ATTENTION:
/// - See inline documentation for specific color warnings
/// - Full report: docs/wcag-contrast-report.md
/// - Quick reference: docs/wcag-contrast-summary.md
/// - Re-run audit: dart scripts/wcag_contrast_checker.dart
/// 
/// KEY WCAG AA STANDARDS:
/// - Normal text (<18pt): Minimum 4.5:1 contrast ratio
/// - Large text (≥18pt or 14pt bold): Minimum 3:1 contrast ratio
/// - UI components: Minimum 3:1 contrast ratio
/// 
/// CRITICAL NOTES:
/// 1. Always use DARK text (#2C241E) on Golden/Transporter backgrounds
/// 2. Sky Blue (Bureau/Tertiary) requires large text or darker variant
/// 3. Success/Warning colors need dark text on backgrounds
/// 4. Tertiary text color only suitable for large text in light theme
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// 
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // EXACT PALETTE: EARTH-TONES AGRICULTURAL (BOLD APPROACH)
  // ============================================================================

  // Primary — Rich Earth Green
  // Represents fertile agricultural land and growth
  
  /// Primary brand color - Rich Earth Green (#3A7D44)
  /// 
  /// This is the main brand color representing fertile agricultural land
  /// and growth. Use for primary buttons, active navigation items, and
  /// key interactive elements.
  /// 
  /// **Accessibility**: White text on this color has 5.00:1 contrast ✅
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Primary button background
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
  ///   child: Text('Add Produce'),
  /// )
  /// 
  /// // Active navigation indicator
  /// Container(color: AppColors.primary)
  /// ```
  static const Color primary = Color(0xFF3A7D44);
  
  /// Primary dark variant - Deep Earth Green (#2B5E34)
  /// 
  /// Darker shade of primary for hover states, pressed buttons, and
  /// creating depth in UI elements.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Button hover state
  /// onHover: () => color: AppColors.primaryDark
  /// 
  /// // Gradient with primary
  /// LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
  /// ```
  static const Color primaryDark = Color(0xFF2B5E34);
  
  /// Primary light variant - Light Earth Green (#5C9B65)
  /// 
  /// Lighter shade of primary for backgrounds, subtle highlights, and
  /// secondary UI elements. Also used as the primary color in dark theme.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Card subtle background
  /// Container(color: AppColors.primaryLight.withOpacity(0.1))
  /// 
  /// // Success indicator
  /// Icon(Icons.check_circle, color: AppColors.primaryLight)
  /// ```
  static const Color primaryLight = Color(0xFF5C9B65);
  
  /// Primary very light variant - Pale Green (#E8F0E9)
  /// 
  /// Very light tint for backgrounds, containers, and hover states.
  /// Provides subtle color without overwhelming content.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Hover background on farmer dashboard cards
  /// Container(color: AppColors.primaryVeryLight)
  /// 
  /// // Chip background for farmer-related tags
  /// Chip(backgroundColor: AppColors.primaryVeryLight)
  /// ```
  static const Color primaryVeryLight = Color(0xFFE8F0E9);

  // Secondary — Ethiopian Coffee Brown
  // Represents Ethiopian coffee culture and warm earth tones
  
  /// Secondary brand color - Ethiopian Coffee Brown (#8B5A3C)
  /// 
  /// Inspired by Ethiopia's renowned coffee culture, this warm brown
  /// is used for secondary actions, buyer role identification, and
  /// warm accents throughout the interface.
  /// 
  /// **Accessibility**: White text on this color has 5.79:1 contrast ✅
  /// Fully compliant for all uses.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Secondary button
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
  ///   child: Text('View Details'),
  /// )
  /// 
  /// // Buyer role badge
  /// RoleBadge(role: 'buyer', color: AppColors.secondary)
  /// ```
  static const Color secondary = Color(0xFF8B5A3C);
  
  /// Secondary light variant - Light Coffee Brown (#A67C52)
  /// 
  /// Lighter shade for hover states and background tints.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Subtle background for buyer sections
  /// Container(color: AppColors.secondaryLight.withOpacity(0.1))
  /// ```
  static const Color secondaryLight = Color(0xFFA67C52);
  
  /// Secondary dark variant - Deep Coffee Brown (#6B4429)
  /// 
  /// Darker shade for emphasis and contrast.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Text on secondary-colored backgrounds
  /// Text('Total Orders', style: TextStyle(color: AppColors.secondaryDark))
  /// ```
  static const Color secondaryDark = Color(0xFF6B4429);
  
  /// Secondary very light variant - Pale Coffee Cream (#F3ECE4)
  /// 
  /// Very light tint for backgrounds and containers.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Buyer dashboard card backgrounds
  /// Card(color: AppColors.secondaryVeryLight)
  /// ```
  static const Color secondaryVeryLight = Color(0xFFF3ECE4);

  // Tertiary — Sky Blue
  // Represents clear skies and optimism
  
  /// Tertiary color - Sky Blue (#4A90E2)
  /// 
  /// Used for informational elements, bureau officer identification,
  /// and alternative accent colors. Represents clear Ethiopian skies.
  /// 
  /// **Accessibility Note**: White text 3.29:1 (passes for large text only)
  /// For normal text, use AppColors.tertiaryDark or ensure text is ≥18pt.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Info banner
  /// Container(
  ///   color: AppColors.tertiary,
  ///   child: Text('Market Update', 
  ///     style: TextStyle(fontSize: 20, color: Colors.white)) // Large text OK
  /// )
  /// 
  /// // Bureau officer badge
  /// RoleBadge(role: 'bureau', color: AppColors.tertiary)
  /// ```
  static const Color tertiary = Color(0xFF4A90E2);
  
  /// Tertiary light variant - Light Sky Blue (#6BA4E8)
  /// 
  /// Lighter shade for backgrounds and subtle accents.
  static const Color tertiaryLight = Color(0xFF6BA4E8);
  
  /// Tertiary dark variant - Deep Blue (#1E3A5F)
  /// 
  /// Dark shade suitable for text on light backgrounds.
  /// Use when tertiary base color doesn't meet contrast requirements.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Info text on light background
  /// Text('Learn More', style: TextStyle(color: AppColors.tertiaryDark))
  /// ```
  static const Color tertiaryDark = Color(0xFF1E3A5F);
  
  /// Tertiary very light variant - Pale Sky Blue (#E8F2FC)
  /// 
  /// Very light tint for backgrounds and containers.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Bureau dashboard backgrounds
  /// Card(color: AppColors.tertiaryVeryLight)
  /// ```
  static const Color tertiaryVeryLight = Color(0xFFE8F2FC);

  // Accent — Golden Harvest
  // Represents harvest prosperity and transporter role
  
  /// Accent color - Golden Harvest (#D4AF37)
  /// 
  /// Represents agricultural prosperity and harvest. Primary color for
  /// transporter role identification.
  /// 
  /// **⚠️ CRITICAL ACCESSIBILITY WARNING**:
  /// - ✅ Use DARK text (#2C241E) on golden backgrounds (7.25:1 contrast)
  /// - ❌ DO NOT use white text (2.10:1 - fails)
  /// - ❌ DO NOT use as text color on light backgrounds (1.87:1 - fails)
  /// - For text on light backgrounds, use AppColors.goldDark (#B89020)
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Transporter card with dark text (CORRECT)
  /// Container(
  ///   color: AppColors.accent,
  ///   child: Text('Active Deliveries', 
  ///     style: TextStyle(color: AppColors.textPrimary)) // Dark text
  /// )
  /// 
  /// // Accent icon on dark background
  /// Icon(Icons.stars, color: AppColors.accent)
  /// 
  /// // Text on light background (use dark variant)
  /// Text('Featured', style: TextStyle(color: AppColors.goldDark))
  /// ```
  static const Color accent = Color(0xFFD4AF37);
  
  /// Alias for accent color - more semantic naming for gold-related UI
  static const Color gold = Color(0xFFD4AF37);
  
  /// Gold light variant - Light Golden (#E5C048)
  /// 
  /// Lighter shade for highlights and hover states.
  static const Color goldLight = Color(0xFFE5C048);
  
  /// Gold dark variant - Deep Gold (#B89020)
  /// 
  /// Darker shade suitable for text on light backgrounds.
  /// Use this when accent/gold doesn't meet contrast requirements.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Gold-colored text on light background
  /// Text('Premium', style: TextStyle(color: AppColors.goldDark))
  /// ```
  static const Color goldDark = Color(0xFFB89020);
  
  /// Gold very light variant - Pale Gold (#FBF4DD)
  /// 
  /// Very light tint for backgrounds and containers.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Transporter dashboard backgrounds
  /// Card(color: AppColors.goldVeryLight)
  /// 
  /// // Premium feature highlights
  /// Container(color: AppColors.goldVeryLight)
  /// ```
  static const Color goldVeryLight = Color(0xFFFBF4DD);
  
  /// Amber accent - Warm Orange Gold (#E09F3E)
  /// 
  /// Alternative warm accent for variety in UI elements.
  static const Color amber = Color(0xFFE09F3E);

  // Background — Natural Cream & Warm White Surface
  // Creates warm, welcoming interface foundation
  
  /// Main background color - Natural Cream (#F5F1E8)
  /// 
  /// Warm, natural cream background providing a comfortable, organic feel.
  /// Used as the main scaffold background throughout the app.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Scaffold background
  /// Scaffold(backgroundColor: AppColors.background)
  /// 
  /// // Section divider background
  /// Container(color: AppColors.background)
  /// ```
  static const Color background = Color(0xFFF5F1E8);
  
  /// Surface color - Warm White (#FFFBF5)
  /// 
  /// Slightly warmer white for cards, sheets, and elevated surfaces.
  /// Provides subtle distinction from background while maintaining warmth.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Card surface
  /// Card(color: AppColors.surface)
  /// 
  /// // Bottom sheet
  /// Container(color: AppColors.surface)
  /// ```
  static const Color surface = Color(0xFFFFFBF5);
  
  /// Surface light variant - Light Cream (#FAF6EE)
  /// 
  /// Alternative surface color for layered UI elements.
  static const Color surfaceLight = Color(0xFFFAF6EE);
  
  /// Border color - Soft Taupe (#DDD6C9)
  /// 
  /// Subtle border color for dividers, outlines, and separators.
  /// Provides clear boundaries without harsh contrast.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Container border
  /// Container(
  ///   decoration: BoxDecoration(
  ///     border: Border.all(color: AppColors.border),
  ///   ),
  /// )
  /// 
  /// // Divider
  /// Divider(color: AppColors.border)
  /// ```
  static const Color border = Color(0xFFDDD6C9);
  
  /// Disabled state color - Muted Taupe (#C4BCB0)
  /// 
  /// For disabled buttons, inactive elements, and non-interactive content.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Disabled button
  /// ElevatedButton(
  ///   onPressed: null,
  ///   style: ElevatedButton.styleFrom(
  ///     disabledBackgroundColor: AppColors.disabled,
  ///   ),
  /// )
  /// ```
  static const Color disabled = Color(0xFFC4BCB0);

  // Dark Theme Backgrounds & Surfaces
  // Deep, rich colors for dark mode interface
  
  /// Dark theme main background - Deep Earth (#1B1916)
  /// 
  /// Rich, deep earth tone for dark theme scaffold background.
  /// Provides comfortable viewing in low-light conditions.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Dark theme scaffold
  /// Scaffold(backgroundColor: AppColors.backgroundDark)
  /// ```
  static const Color backgroundDark = Color(0xFF1B1916);
  
  /// Dark theme surface - Warm Charcoal (#24211D)
  /// 
  /// Elevated surface color for cards and sheets in dark theme.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // Dark theme card
  /// Card(color: AppColors.surfaceDark)
  /// ```
  static const Color surfaceDark = Color(0xFF24211D);
  
  /// Dark theme surface highest - Lighter Charcoal (#2E2A24)
  /// 
  /// Highest elevation surface for layered elements in dark theme.
  /// 
  /// **Usage Examples**:
  /// ```dart
  /// // App bar in dark theme
  /// AppBar(backgroundColor: AppColors.surfaceDarkHighest)
  /// ```
  static const Color surfaceDarkHighest = Color(0xFF2E2A24);
  
  /// Dark theme border - Warm Brown Gray (#453F36)
  /// 
  /// Border color for dark theme providing subtle separation.
  static const Color borderDark = Color(0xFF453F36);
  
  /// Dark theme border variant - Subtle Brown Gray (#38332C)
  /// 
  /// Alternative border color for layered dark theme elements.
  static const Color borderDarkVariant = Color(0xFF38332C);

  // Success — Fresh Growth
  /// Success color - Fresh Growth Green
  /// ⚠️ WCAG Warning: White text 2.50:1 ❌ | As text on light BG 2.22:1 ❌
  /// Recommendation: Use dark text on success backgrounds, or darken to #4A7A2C for text
  static const Color success = Color(0xFF7CB342);
  static const Color successLight = Color(0xFF9CCC65);
  static const Color successDark = Color(0xFF558B2F);

  // ============================================================================
  // CONTAINER COLORS (for dark theme compatibility)
  // ============================================================================
  static const Color primaryContainer = Color(0xFF224227);
  static const Color onPrimaryContainer = Color(0xFFD3E7D6);
  static const Color secondaryContainer = Color(0xFF4A3425);
  static const Color onSecondaryContainer = Color(0xFFE8DDD5);
  static const Color tertiaryContainer = Color(0xFF1E3A5F);
  static const Color onTertiaryContainer = Color(0xFFD6E8FD);
  static const Color errorContainer = Color(0xFF5C1D1D);
  static const Color onErrorContainer = Color(0xFFFFCDD2);

  // ============================================================================
  // SEMANTIC COLORS - Status & Feedback
  // ============================================================================
  
  /// Warning color - Orange
  /// ⚠️ WCAG Warning: White text 3.01:1 ❌ | Dark text 5.06:1 ✅
  /// Recommendation: Use dark text on warning backgrounds, darken to #B55208 for text on light BG
  static const Color warning = Color(0xFFE07A24);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFBF6A1C);
  
  /// Error color - Red
  /// WCAG Contrast: White text 5.44:1 ✅ | As text on light BG 4.82:1 ✅
  /// Fully compliant for all uses
  static const Color error = Color(0xFFC0392B);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFF8B2618);
  
  /// Info color - Sky Blue (same as Bureau role color)
  /// WCAG Contrast: Same issues as roleBureau - see role colors section
  static const Color info = Color(0xFF4A90E2); // Sky Blue

  // ============================================================================
  // TEXT COLORS - High Contrast for Accessibility (Deep Earth & Warm Neutrals)
  // ============================================================================
  
  /// Primary text color - Deep Earth Brown
  /// WCAG Contrast: 13.52:1 on background, 14.78:1 on surface ✅
  static const Color textPrimary = Color(0xFF2C241E);
  
  /// Secondary text color - Warm Gray
  /// WCAG Contrast: 5.30:1 on background, 5.80:1 on surface ✅
  static const Color textSecondary = Color(0xFF6B6258);
  
  /// Tertiary text color - Light Warm Gray
  /// ⚠️ WCAG Warning: 3.01:1 on background (fails normal text, passes large text)
  /// Recommendation: Use for large text only, or darken to #77685A for normal text
  static const Color textTertiary = Color(0xFF948A7E);
  
  /// Text color for use on primary colored backgrounds
  /// WCAG Contrast: 5.00:1 on primary ✅
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Text color for use on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Dark Theme Text Colors
  static const Color textPrimaryDark = Color(0xFFF5F1E8); // Light cream for dark backgrounds
  static const Color textSecondaryDark = Color(0xFFC4BCB0); // Muted for secondary text
  static const Color textTertiaryDark = Color(0xFF948A7E); // Subtle for tertiary text

  // ============================================================================
  // ROLE-SPECIFIC COLORS
  // ============================================================================
  
  /// Farmer role color - Rich Earth Green
  /// WCAG Contrast: White text 5.00:1 ✅ | As text on light BG 4.44:1 ⚠️ (barely fails)
  /// Recommendation: Use for buttons with white text, or darken to #377540 for normal text
  static const Color roleFarmer = Color(0xFF3A7D44); // Primary Earth Green
  
  /// Buyer role color - Ethiopian Coffee Brown
  /// WCAG Contrast: White text 5.79:1 ✅ | As text on light BG 5.14:1 ✅
  /// Fully compliant for all uses
  static const Color roleBuyer = Color(0xFF8B5A3C); // Coffee Brown
  
  /// Transporter role color - Golden Harvest
  /// ⚠️ CRITICAL: Use DARK text (#2C241E) on golden backgrounds (7.25:1 ✅)
  /// ❌ DO NOT use white text (2.10:1 fails)
  /// ❌ DO NOT use as text on light backgrounds (1.87:1 fails)
  /// Recommendation: Use #A68714 for text on light backgrounds
  static const Color roleTransporter = Color(0xFFD4AF37); // Golden Harvest
  
  /// Bureau Officer role color - Sky Blue
  /// WCAG Contrast: White text 3.29:1 (passes large text only) | As text on light BG 2.92:1 ❌
  /// Recommendation: Darken to #2563B0 for normal text, or use large text only
  static const Color roleBureau = Color(0xFF4A90E2); // Sky Blue

  /// Returns the primary color for a given user role.
  /// 
  /// Maps roles to their designated colors:
  /// - farmer → #3A7D44 (Rich Earth Green)
  /// - buyer → #8B5A3C (Ethiopian Coffee Brown)
  /// - transporter → #D4AF37 (Golden Harvest)
  /// - bureau → #4A90E2 (Sky Blue)
  /// 
  /// Returns [primary] as default if role is not recognized.
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return roleFarmer;
      case 'buyer':
        return roleBuyer;
      case 'transporter':
        return roleTransporter;
      case 'bureau':
      case 'bureau officer':
        return roleBureau;
      default:
        return primary; // Default fallback
    }
  }

  /// Returns a light variant color for a given user role.
  /// 
  /// Maps roles to their designated light colors for backgrounds and subtle UI elements:
  /// - farmer → #5C9B65 (Light Earth Green)
  /// - buyer → #A67C52 (Light Coffee Brown)
  /// - transporter → #FBF4DD (Light Golden)
  /// - bureau → #E8F0E9 (Light Sky Blue/Primary Very Light as fallback)
  /// 
  /// Returns [primaryLight] as default if role is not recognized.
  static Color getRoleColorLight(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return primaryLight; // #5C9B65
      case 'buyer':
        return secondaryLight; // #A67C52
      case 'transporter':
        return goldLight; // #FBF4DD
      case 'bureau':
      case 'bureau officer':
        return primaryVeryLight; // #E8F0E9 - using this as light blue variant
      default:
        return primaryLight; // Default fallback
    }
  }

  // ============================================================================
  // GRADIENT DEFINITIONS
  // ============================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5C048), accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // OPACITY VARIANTS
  // ============================================================================
  static const Color shadow12 = Color(0x1A2C241E);
  static const Color overlay8 = Color(0x142C241E);
  static const Color shimmer50 = Color(0x80FFFBF5);

  // ============================================================================
  // COMMODITY-SPECIFIC COLORS (Agricultural price indicators)
  // ============================================================================
  static const Color commodityCoffee = Color(0xFF8B5A3C);
  static const Color commodityMaize = Color(0xFFD4AF37);
  static const Color commodityTeff = Color(0xFFA67C52);
  static const Color commodityWheat = Color(0xFFE5B84B);
  static const Color commodityPotato = Color(0xFF93684B);

  // ============================================================================
  // CHART & GRAPH COLORS (Cohesive Earth-Tones)
  // ============================================================================
  static const List<Color> chartColors = [
    Color(0xFF3A7D44), // Primary Green
    Color(0xFF8B5A3C), // Coffee Brown
    Color(0xFF4A90E2), // Sky Blue
    Color(0xFFD4AF37), // Golden Harvest
    Color(0xFF7CB342), // Fresh Growth
    Color(0xFFA67C52), // Light Coffee
  ];
}
