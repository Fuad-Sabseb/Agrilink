import 'dart:math';
import 'package:flutter/material.dart';
import 'colors.dart';

/// WCAG AA Contrast Verification Report
/// 
/// This file provides comprehensive contrast ratio calculations and verification
/// for all color combinations in the Agricultural Earth-Tone color system.
/// 
/// WCAG AA Standards:
/// - Normal text (< 18pt or < 14pt bold): Minimum contrast ratio of 4.5:1
/// - Large text (≥ 18pt or ≥ 14pt bold): Minimum contrast ratio of 3:1
/// - UI components and graphical objects: Minimum contrast ratio of 3:1

class ContrastVerification {
  ContrastVerification._();

  /// Calculate relative luminance of a color according to WCAG 2.1
  /// Formula: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize RGB color channel value
  static double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Calculate contrast ratio between two colors
  /// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 is lighter
  static double contrastRatio(Color color1, Color color2) {
    final lum1 = _relativeLuminance(color1);
    final lum2 = _relativeLuminance(color2);
    final lighter = max(lum1, lum2);
    final darker = min(lum1, lum2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast ratio meets WCAG AA for normal text (4.5:1)
  static bool meetsAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast ratio meets WCAG AA for large text (3:1)
  static bool meetsAALarge(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast ratio meets WCAG AAA for normal text (7:1)
  static bool meetsAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Format contrast ratio result as string
  static String formatRatio(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);
    final meetsAA = ratio >= 4.5;
    final meetsAALarge = ratio >= 3.0;
    final meetsAAA = ratio >= 7.0;

    String status;
    if (meetsAAA) {
      status = '✓ AAA';
    } else if (meetsAA) {
      status = '✓ AA';
    } else if (meetsAALarge) {
      status = '✓ AA Large';
    } else {
      status = '✗ FAIL';
    }

    return '${ratio.toStringAsFixed(2)}:1 - $status';
  }

  /// Generate complete contrast verification report
  static Map<String, dynamic> generateReport() {
    final report = <String, dynamic>{};

    // Light Theme Verification
    report['lightTheme'] = {
      'background': _verifyBackgroundCombinations('light'),
      'surface': _verifySurfaceCombinations('light'),
      'buttons': _verifyButtonCombinations('light'),
      'cards': _verifyCardCombinations('light'),
      'status': _verifyStatusColors('light'),
      'roles': _verifyRoleColors('light'),
    };

    // Dark Theme Verification
    report['darkTheme'] = {
      'background': _verifyBackgroundCombinations('dark'),
      'surface': _verifySurfaceCombinations('dark'),
      'buttons': _verifyButtonCombinations('dark'),
      'cards': _verifyCardCombinations('dark'),
      'status': _verifyStatusColors('dark'),
      'roles': _verifyRoleColors('dark'),
    };

    return report;
  }

  /// Verify text on background color combinations
  static Map<String, String> _verifyBackgroundCombinations(String theme) {
    final bg = theme == 'light' ? AppColors.background : AppColors.backgroundDark;
    
    return {
      'textPrimary on background': formatRatio(
        theme == 'light' ? AppColors.textPrimary : AppColors.textPrimaryDark,
        bg,
      ),
      'textSecondary on background': formatRatio(
        theme == 'light' ? AppColors.textSecondary : AppColors.textSecondaryDark,
        bg,
      ),
      'textTertiary on background': formatRatio(
        theme == 'light' ? AppColors.textTertiary : AppColors.textTertiaryDark,
        bg,
      ),
      'primary on background': formatRatio(AppColors.primary, bg),
      'secondary on background': formatRatio(AppColors.secondary, bg),
      'tertiary on background': formatRatio(AppColors.tertiary, bg),
      'accent on background': formatRatio(AppColors.accent, bg),
      'error on background': formatRatio(AppColors.error, bg),
      'success on background': formatRatio(AppColors.success, bg),
      'warning on background': formatRatio(AppColors.warning, bg),
    };
  }

  /// Verify text on surface color combinations
  static Map<String, String> _verifySurfaceCombinations(String theme) {
    final surf = theme == 'light' ? AppColors.surface : AppColors.surfaceDark;
    
    return {
      'textPrimary on surface': formatRatio(
        theme == 'light' ? AppColors.textPrimary : AppColors.textPrimaryDark,
        surf,
      ),
      'textSecondary on surface': formatRatio(
        theme == 'light' ? AppColors.textSecondary : AppColors.textSecondaryDark,
        surf,
      ),
      'textTertiary on surface': formatRatio(
        theme == 'light' ? AppColors.textTertiary : AppColors.textTertiaryDark,
        surf,
      ),
      'primary on surface': formatRatio(AppColors.primary, surf),
      'secondary on surface': formatRatio(AppColors.secondary, surf),
      'tertiary on surface': formatRatio(AppColors.tertiary, surf),
    };
  }

  /// Verify button text on button background combinations
  static Map<String, String> _verifyButtonCombinations(String theme) {
    return {
      'textOnPrimary on primary': formatRatio(
        AppColors.textOnPrimary,
        AppColors.primary,
      ),
      'textOnPrimary on secondary': formatRatio(
        AppColors.textOnPrimary,
        AppColors.secondary,
      ),
      'textOnPrimary on tertiary': formatRatio(
        AppColors.textOnPrimary,
        AppColors.tertiary,
      ),
      'textOnPrimary on accent': formatRatio(
        AppColors.textOnPrimary,
        AppColors.accent,
      ),
      'textOnPrimary on success': formatRatio(
        AppColors.textOnPrimary,
        AppColors.success,
      ),
      'textOnPrimary on error': formatRatio(
        AppColors.textOnPrimary,
        AppColors.error,
      ),
      'textOnPrimary on warning': formatRatio(
        AppColors.textOnPrimary,
        AppColors.warning,
      ),
      'textPrimary on primaryVeryLight': formatRatio(
        theme == 'light' ? AppColors.textPrimary : AppColors.textPrimaryDark,
        AppColors.primaryVeryLight,
      ),
      'textPrimary on secondaryVeryLight': formatRatio(
        theme == 'light' ? AppColors.textPrimary : AppColors.textPrimaryDark,
        AppColors.secondaryVeryLight,
      ),
    };
  }

  /// Verify card combinations
  static Map<String, String> _verifyCardCombinations(String theme) {
    final surf = theme == 'light' ? AppColors.surface : AppColors.surfaceDark;
    final textPrimary = theme == 'light' ? AppColors.textPrimary : AppColors.textPrimaryDark;
    
    return {
      'textPrimary on surface (cards)': formatRatio(textPrimary, surf),
      'primary on surface (icons)': formatRatio(AppColors.primary, surf),
      'accent on surface (icons)': formatRatio(AppColors.accent, surf),
      'border on surface': formatRatio(
        theme == 'light' ? AppColors.border : AppColors.borderDark,
        surf,
      ),
    };
  }

  /// Verify status color combinations
  static Map<String, String> _verifyStatusColors(String theme) {
    final bg = theme == 'light' ? AppColors.background : AppColors.backgroundDark;
    
    return {
      'success on background': formatRatio(AppColors.success, bg),
      'warning on background': formatRatio(AppColors.warning, bg),
      'error on background': formatRatio(AppColors.error, bg),
      'info on background': formatRatio(AppColors.info, bg),
      'textOnPrimary on success': formatRatio(AppColors.textOnPrimary, AppColors.success),
      'textOnPrimary on error': formatRatio(AppColors.textOnPrimary, AppColors.error),
      'textOnPrimary on warning': formatRatio(AppColors.textOnPrimary, AppColors.warning),
      'errorContainer text': formatRatio(AppColors.onErrorContainer, AppColors.errorContainer),
    };
  }

  /// Verify role-specific color combinations
  static Map<String, String> _verifyRoleColors(String theme) {
    final bg = theme == 'light' ? AppColors.background : AppColors.backgroundDark;
    
    return {
      'roleFarmer on background': formatRatio(AppColors.roleFarmer, bg),
      'roleBuyer on background': formatRatio(AppColors.roleBuyer, bg),
      'roleTransporter on background': formatRatio(AppColors.roleTransporter, bg),
      'roleBureau on background': formatRatio(AppColors.roleBureau, bg),
      'textOnPrimary on roleFarmer': formatRatio(AppColors.textOnPrimary, AppColors.roleFarmer),
      'textOnPrimary on roleBuyer': formatRatio(AppColors.textOnPrimary, AppColors.roleBuyer),
      'textOnPrimary on roleTransporter': formatRatio(AppColors.textOnPrimary, AppColors.roleTransporter),
      'textOnPrimary on roleBureau': formatRatio(AppColors.textOnPrimary, AppColors.roleBureau),
      'primaryContainer text': formatRatio(AppColors.onPrimaryContainer, AppColors.primaryContainer),
      'secondaryContainer text': formatRatio(AppColors.onSecondaryContainer, AppColors.secondaryContainer),
      'tertiaryContainer text': formatRatio(AppColors.onTertiaryContainer, AppColors.tertiaryContainer),
    };
  }

  /// Print complete contrast verification report to console
  static void printReport() {
    final report = generateReport();
    
    print('═══════════════════════════════════════════════════════════════════');
    print('  WCAG AA CONTRAST VERIFICATION REPORT');
    print('  Agricultural Earth-Tone Color System');
    print('═══════════════════════════════════════════════════════════════════');
    print('');
    print('Standards:');
    print('  ✓ AA      : 4.5:1 (normal text) - REQUIRED');
    print('  ✓ AA Large: 3.0:1 (large text ≥18pt or ≥14pt bold)');
    print('  ✓ AAA     : 7.0:1 (enhanced contrast)');
    print('  ✗ FAIL    : Below WCAG AA standards');
    print('');
    
    // Light Theme Report
    print('═══════════════════════════════════════════════════════════════════');
    print('  LIGHT THEME VERIFICATION');
    print('═══════════════════════════════════════════════════════════════════');
    print('');
    
    _printSection('Background Combinations', report['lightTheme']['background']);
    _printSection('Surface Combinations', report['lightTheme']['surface']);
    _printSection('Button Combinations', report['lightTheme']['buttons']);
    _printSection('Card Combinations', report['lightTheme']['cards']);
    _printSection('Status Colors', report['lightTheme']['status']);
    _printSection('Role-Specific Colors', report['lightTheme']['roles']);
    
    // Dark Theme Report
    print('═══════════════════════════════════════════════════════════════════');
    print('  DARK THEME VERIFICATION');
    print('═══════════════════════════════════════════════════════════════════');
    print('');
    
    _printSection('Background Combinations', report['darkTheme']['background']);
    _printSection('Surface Combinations', report['darkTheme']['surface']);
    _printSection('Button Combinations', report['darkTheme']['buttons']);
    _printSection('Card Combinations', report['darkTheme']['cards']);
    _printSection('Status Colors', report['darkTheme']['status']);
    _printSection('Role-Specific Colors', report['darkTheme']['roles']);
    
    print('═══════════════════════════════════════════════════════════════════');
    print('  VERIFICATION COMPLETE');
    print('═══════════════════════════════════════════════════════════════════');
  }

  /// Print a section of the report
  static void _printSection(String title, Map<String, String> data) {
    print('─── $title ───');
    print('');
    data.forEach((key, value) {
      final padding = ' ' * (50 - key.length);
      print('  $key$padding$value');
    });
    print('');
  }

  /// Generate markdown report for documentation
  static String generateMarkdownReport() {
    final report = generateReport();
    final buffer = StringBuffer();
    
    buffer.writeln('# WCAG AA Contrast Verification Report');
    buffer.writeln('');
    buffer.writeln('**Agricultural Earth-Tone Color System**');
    buffer.writeln('');
    buffer.writeln('## Standards');
    buffer.writeln('');
    buffer.writeln('- **✓ AA**: 4.5:1 minimum for normal text - REQUIRED');
    buffer.writeln('- **✓ AA Large**: 3.0:1 minimum for large text (≥18pt or ≥14pt bold)');
    buffer.writeln('- **✓ AAA**: 7.0:1 enhanced contrast');
    buffer.writeln('- **✗ FAIL**: Below WCAG AA standards');
    buffer.writeln('');
    
    // Light Theme
    buffer.writeln('## Light Theme Verification');
    buffer.writeln('');
    _addMarkdownSection(buffer, 'Background Combinations', report['lightTheme']['background']);
    _addMarkdownSection(buffer, 'Surface Combinations', report['lightTheme']['surface']);
    _addMarkdownSection(buffer, 'Button Combinations', report['lightTheme']['buttons']);
    _addMarkdownSection(buffer, 'Card Combinations', report['lightTheme']['cards']);
    _addMarkdownSection(buffer, 'Status Colors', report['lightTheme']['status']);
    _addMarkdownSection(buffer, 'Role-Specific Colors', report['lightTheme']['roles']);
    
    // Dark Theme
    buffer.writeln('## Dark Theme Verification');
    buffer.writeln('');
    _addMarkdownSection(buffer, 'Background Combinations', report['darkTheme']['background']);
    _addMarkdownSection(buffer, 'Surface Combinations', report['darkTheme']['surface']);
    _addMarkdownSection(buffer, 'Button Combinations', report['darkTheme']['buttons']);
    _addMarkdownSection(buffer, 'Card Combinations', report['darkTheme']['cards']);
    _addMarkdownSection(buffer, 'Status Colors', report['darkTheme']['status']);
    _addMarkdownSection(buffer, 'Role-Specific Colors', report['darkTheme']['roles']);
    
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('*Generated: ${DateTime.now().toIso8601String()}*');
    
    return buffer.toString();
  }

  /// Add a section to markdown report
  static void _addMarkdownSection(StringBuffer buffer, String title, Map<String, String> data) {
    buffer.writeln('### $title');
    buffer.writeln('');
    buffer.writeln('| Color Combination | Contrast Ratio | Status |');
    buffer.writeln('|---|---|---|');
    
    data.forEach((key, value) {
      final parts = value.split(' - ');
      final ratio = parts[0];
      final status = parts.length > 1 ? parts[1] : '';
      buffer.writeln('| $key | $ratio | $status |');
    });
    
    buffer.writeln('');
  }
}
