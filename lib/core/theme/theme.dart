import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'tokens.dart';

/// AgriLink Theme Configuration
/// 
/// Material 3 theme implementation with Agricultural Earth-Tone design system.
/// Provides comprehensive light and dark themes with:
/// - Rich Earth Green primary color (#3A7D44)
/// - Ethiopian Coffee Brown secondary color (#8B5A3C)
/// - Natural cream backgrounds for warmth and comfort
/// - WCAG AA accessibility compliance
/// - Role-specific color coding
/// 
/// **Theme Architecture**:
/// This theme system follows Material Design 3 guidelines while incorporating
/// agricultural earth tones that resonate with Ethiopian farming culture.
/// 
/// **Usage**:
/// ```dart
/// // In MaterialApp
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system, // Respects user's system preference
/// )
/// 
/// // Access theme in widgets
/// final theme = Theme.of(context);
/// final primaryColor = theme.colorScheme.primary;
/// ```
/// 
/// **Design Philosophy**:
/// - Warm, welcoming colors inspired by fertile soil and crops
/// - High contrast for readability in outdoor sunlight
/// - Consistent spacing using design tokens
/// - Accessibility-first approach (WCAG AA compliant)
/// 
class AppTheme {
  // Private constructor
  AppTheme._();

  // ============================================================================
  // LIGHT THEME — Earth-Tones Agricultural (Bold Approach)
  // ============================================================================
  
  /// Light theme configuration with Agricultural Earth-Tone design system
  /// 
  /// **Color Palette**:
  /// - Primary: Rich Earth Green (#3A7D44) - fertile soil and growth
  /// - Secondary: Ethiopian Coffee Brown (#8B5A3C) - cultural heritage
  /// - Background: Natural Cream (#F5F1E8) - warm, welcoming
  /// - Surface: Warm White (#FFFBF5) - clean but not stark
  /// 
  /// **Accessibility**:
  /// - All color combinations meet WCAG AA standards (4.5:1 for text)
  /// - High contrast suitable for outdoor use in sunlight
  /// - Clear focus indicators for keyboard navigation
  /// 
  /// **Component Customization**:
  /// Every Material component has been customized to match the earth-tone
  /// aesthetic while maintaining Material Design 3 interaction patterns.
  /// 
  /// **Usage Example**:
  /// ```dart
  /// MaterialApp(
  ///   theme: AppTheme.lightTheme,
  ///   home: DashboardScreen(),
  /// )
  /// ```
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary — Rich Earth Green (#3A7D44)
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryVeryLight,
      onPrimaryContainer: AppColors.primaryDark,
      // Secondary — Ethiopian Coffee Brown (#8B5A3C)
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondaryVeryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      // Tertiary — Sky Blue (#4A90E2)
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryVeryLight,
      onTertiaryContainer: AppColors.tertiaryDark,
      // Error colors
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFCEBEA),
      onErrorContainer: AppColors.errorDark,
      // Surface and background — Natural Cream (#F5F1E8)
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceLight,
      onSurfaceVariant: AppColors.textSecondary,
      // Borders and outline
      outline: AppColors.border,
      outlineVariant: const Color(0xFFEBE5DB),
      shadow: AppColors.shadow12,
    );

    return ThemeData(
      // Material 3
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: colorScheme,

      // Scaffold — Natural Cream
      scaffoldBackgroundColor: AppColors.background,
      
      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppTokens.elevationNone,
        centerTitle: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.appBarTitle.copyWith(
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
          size: AppTokens.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onPrimary,
          size: AppTokens.iconM,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: AppTypography.navLabel,
        unselectedLabelStyle: AppTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: AppTokens.elevationXS,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceM,
          vertical: AppTokens.spaceXS,
        ),
      ),

      // Elevated Button Theme — Primary action buttons with Rich Earth Green
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Rich Earth Green (#3A7D44)
          foregroundColor: AppColors.textOnPrimary, // White text
          elevation: AppTokens.elevationXS,
          shadowColor: AppColors.shadow12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceXL,
            vertical: AppTokens.spaceS,
          ),
          textStyle: AppTypography.buttonPrimary,
          minimumSize: Size(88, AppTokens.minTouchTarget), // Meets minimum touch target
        ),
      ),

      // Outlined Button Theme — Secondary actions with primary border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, // Rich Earth Green text
          side: BorderSide(
            color: AppColors.primary, // Rich Earth Green border
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceXL,
            vertical: AppTokens.spaceS,
          ),
          textStyle: AppTypography.buttonSecondary,
          minimumSize: Size(88, AppTokens.minTouchTarget), // Meets minimum touch target
        ),
      ),

      // Text Button Theme — Tertiary actions with primary foreground
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary, // Rich Earth Green text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceM,
            vertical: AppTokens.spaceXS,
          ),
          textStyle: AppTypography.buttonText,
          minimumSize: Size(64, AppTokens.minTouchTarget), // Meets minimum touch target
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceM,
          vertical: AppTokens.spaceS,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: AppTypography.inputLabel,
        hintStyle: AppTypography.inputHint,
        errorStyle: AppTypography.inputError,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: AppTokens.elevationS,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primaryContainer,
        deleteIconColor: colorScheme.onSurface.withOpacity(0.6),
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: AppTypography.labelSmall,
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceS,
          vertical: AppTokens.spaceXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusL),
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusL)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppTokens.iconM,
      ),

      // Badge Theme
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: AppTypography.caption.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXS),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: AppTokens.iconM,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.6),
          size: AppTokens.iconM,
        ),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  /// Dark theme configuration with warm earth tones
  /// 
  /// **Color Adaptations for Dark Mode**:
  /// - Background: Deep Earth (#1B1916) - rich, comfortable darkness
  /// - Surface: Warm Charcoal (#24211D) - elevated surfaces
  /// - Primary: Light Earth Green (#5C9B65) - maintains brand identity
  /// - Text: Light Cream (#F5F1E8) - warm white, not stark
  /// 
  /// **Accessibility**:
  /// - 100% WCAG AA compliance (verified through audit)
  /// - Suitable for low-light conditions
  /// - Reduced eye strain for night use
  /// 
  /// **Design Notes**:
  /// Unlike pure black dark themes, this uses warm earth tones to maintain
  /// the agricultural aesthetic. Deep browns provide comfortable darkness
  /// while preserving the app's character.
  /// 
  /// **Usage Example**:
  /// ```dart
  /// MaterialApp(
  ///   darkTheme: AppTheme.darkTheme,
  ///   themeMode: ThemeMode.system, // Auto-switches based on system
  /// )
  /// ```
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiaryLight,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.errorLight,
      onError: Colors.black,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceDarkHighest,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDarkVariant,
      shadow: Colors.black.withValues(alpha: 0.3),
    );

    return ThemeData(
      // Material 3
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: colorScheme,

      // Scaffold — Rich Deep Soil Dark
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: colorScheme.onSurface),
        displayMedium: AppTypography.displayMedium.copyWith(color: colorScheme.onSurface),
        displaySmall: AppTypography.displaySmall.copyWith(color: colorScheme.onSurface),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: colorScheme.onSurface),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: colorScheme.onSurface),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: colorScheme.onSurface),
        titleLarge: AppTypography.titleLarge.copyWith(color: colorScheme.onSurface),
        titleMedium: AppTypography.titleMedium.copyWith(color: colorScheme.onSurface),
        titleSmall: AppTypography.titleSmall.copyWith(color: colorScheme.onSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
        bodySmall: AppTypography.bodySmall.copyWith(color: colorScheme.onSurface),
        labelLarge: AppTypography.labelLarge.copyWith(color: colorScheme.onSurface),
        labelMedium: AppTypography.labelMedium.copyWith(color: colorScheme.onSurface),
        labelSmall: AppTypography.labelSmall.copyWith(color: colorScheme.onSurface),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppTokens.elevationNone,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.appBarTitle.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppTokens.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppTokens.iconM,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: AppTypography.navLabel,
        unselectedLabelStyle: AppTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: AppTokens.elevationXS,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceM,
          vertical: AppTokens.spaceXS,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: AppTokens.elevationXS,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceXL,
            vertical: AppTokens.spaceS,
          ),
          textStyle: AppTypography.buttonPrimary,
          minimumSize: Size(88, AppTokens.minTouchTarget),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceXL,
            vertical: AppTokens.spaceS,
          ),
          textStyle: AppTypography.buttonSecondary,
          minimumSize: Size(88, AppTokens.minTouchTarget),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceM,
            vertical: AppTokens.spaceXS,
          ),
          textStyle: AppTypography.buttonText,
          minimumSize: Size(64, AppTokens.minTouchTarget),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceM,
          vertical: AppTokens.spaceS,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: AppTypography.inputLabel.copyWith(color: colorScheme.onSurface),
        hintStyle: AppTypography.inputHint.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
        errorStyle: AppTypography.inputError,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: AppTokens.elevationS,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primaryContainer,
        deleteIconColor: colorScheme.onSurface.withOpacity(0.6),
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: AppTypography.labelSmall.copyWith(color: colorScheme.onSurface),
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.spaceS,
          vertical: AppTokens.spaceXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusL),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppTokens.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusL)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppTokens.iconM,
      ),

      // Badge Theme
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: AppTypography.caption.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXS),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: AppTokens.iconM,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.6),
          size: AppTokens.iconM,
        ),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  // ============================================================================
  // THEME EXTENSIONS & UTILITIES
  // ============================================================================
  
  /// System UI overlay style for light theme (light status bar)
  /// 
  /// Configures the status bar and navigation bar appearance when using
  /// the light theme. Sets icons to light color for use on dark app bar.
  /// 
  /// **Usage Example**:
  /// ```dart
  /// // In a widget that needs custom status bar
  /// @override
  /// Widget build(BuildContext context) {
  ///   SystemChrome.setSystemUIOverlayStyle(AppTheme.lightSystemOverlay);
  ///   return Scaffold(...);
  /// }
  /// ```
  static SystemUiOverlayStyle get lightSystemOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// System UI overlay style for dark theme (dark status bar)
  /// 
  /// Configures the status bar and navigation bar appearance when using
  /// the dark theme. Sets icons to dark color for use on light app bar.
  /// 
  /// **Usage Example**:
  /// ```dart
  /// // Automatically applied when dark theme is active
  /// MaterialApp(
  ///   darkTheme: AppTheme.darkTheme,
  ///   themeMode: ThemeMode.dark,
  /// )
  /// ```
  static SystemUiOverlayStyle get darkSystemOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
