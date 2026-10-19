import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// AgriLink Theme Configuration
/// Material 3 theme with light and dark modes
/// Primary color: #4CAF50 (Material Green 500)
class AppTheme {
  // Private constructor
  AppTheme._();

  // ============================================================================
  // LIGHT THEME — Earth-Tones Agricultural (Bold Approach)
  // ============================================================================
  
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryVeryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: const Color(0xFFF3ECE4),
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE8F2FC),
      onTertiaryContainer: const Color(0xFF1E3A5F),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFCEBEA),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceLight,
      onSurfaceVariant: AppColors.textSecondary,
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
        elevation: 0,
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
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
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
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonPrimary,
          minimumSize: const Size(88, 44),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonSecondary,
          minimumSize: const Size(88, 44),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.buttonText,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
        elevation: 4,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
        size: 24,
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
          borderRadius: BorderRadius.circular(4),
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
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.6),
          size: 24,
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
  
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF224227),
      onPrimaryContainer: const Color(0xFFD3E7D6),
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF4A3425),
      onSecondaryContainer: const Color(0xFFE8DDD5),
      tertiary: const Color(0xFF6BA4E8),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF1E3A5F),
      onTertiaryContainer: const Color(0xFFD6E8FD),
      error: const Color(0xFFE57373),
      onError: Colors.black,
      errorContainer: const Color(0xFF5C1D1D),
      onErrorContainer: const Color(0xFFFFCDD2),
      surface: const Color(0xFF24211D),
      onSurface: AppColors.background,
      surfaceContainerHighest: const Color(0xFF2E2A24),
      onSurfaceVariant: AppColors.disabled,
      outline: const Color(0xFF453F36),
      outlineVariant: const Color(0xFF38332C),
      shadow: Colors.black.withValues(alpha: 0.3),
    );

    return ThemeData(
      // Material 3
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: colorScheme,

      // Scaffold — Rich Deep Soil Dark
      scaffoldBackgroundColor: const Color(0xFF1B1916),
      
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
        elevation: 0,
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
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
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
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonPrimary,
          minimumSize: const Size(88, 44),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonSecondary,
          minimumSize: const Size(88, 44),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.buttonText,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
        elevation: 4,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
        size: 24,
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
          borderRadius: BorderRadius.circular(4),
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
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.6),
          size: 24,
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
  
  /// Get system overlay style for light status bar
  static SystemUiOverlayStyle get lightSystemOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Get system overlay style for dark status bar
  static SystemUiOverlayStyle get darkSystemOverlay => const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
