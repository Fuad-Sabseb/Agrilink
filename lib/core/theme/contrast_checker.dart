import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility for checking WCAG contrast ratios
class ContrastChecker {
  /// Calculate relative luminance of a color
  /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
  static double _relativeLuminance(Color color) {
    final r = _adjustChannel(color.red / 255.0);
    final g = _adjustChannel(color.green / 255.0);
    final b = _adjustChannel(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _adjustChannel(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return ((channel + 0.055) / 1.055).pow(2.4);
  }

  /// Calculate contrast ratio between two colors
  /// https://www.w3.org/TR/WCAG20/#contrast-ratiodef
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA standard for normal text (4.5:1)
  static bool meetsNormalTextAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AA standard for large text (3:1)
  static bool meetsLargeTextAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast meets WCAG AA standard for UI components (3:1)
  static bool meetsUIComponentAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast meets WCAG AAA standard for normal text (7:1)
  static bool meetsNormalTextAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Check if contrast meets WCAG AAA standard for large text (4.5:1)
  static bool meetsLargeTextAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Validate theme colors and return violations
  static List<ContrastViolation> validateTheme(ThemeData theme) {
    final violations = <ContrastViolation>[];

    // Check primary text on background
    final primaryText = theme.colorScheme.onSurface;
    final background = theme.colorScheme.surface;
    if (!meetsNormalTextAA(primaryText, background)) {
      violations.add(ContrastViolation(
        'Primary text on background',
        primaryText,
        background,
        contrastRatio(primaryText, background),
        4.5,
      ));
    }

    // Check primary button text
    final onPrimary = theme.colorScheme.onPrimary;
    final primary = theme.colorScheme.primary;
    if (!meetsNormalTextAA(onPrimary, primary)) {
      violations.add(ContrastViolation(
        'Text on primary button',
        onPrimary,
        primary,
        contrastRatio(onPrimary, primary),
        4.5,
      ));
    }

    // Check error text
    final error = theme.colorScheme.error;
    if (!meetsNormalTextAA(error, background)) {
      violations.add(ContrastViolation(
        'Error text on background',
        error,
        background,
        contrastRatio(error, background),
        4.5,
      ));
    }

    return violations;
  }

  /// Get recommended foreground color for background
  static Color getAccessibleForeground(Color background) {
    final ratio = contrastRatio(Colors.black, background);
    return ratio >= 4.5 ? Colors.black : Colors.white;
  }
}

class ContrastViolation {
  final String description;
  final Color foreground;
  final Color background;
  final double actualRatio;
  final double requiredRatio;

  ContrastViolation(
    this.description,
    this.foreground,
    this.background,
    this.actualRatio,
    this.requiredRatio,
  );

  @override
  String toString() {
    return 'Contrast violation: $description - '
        'Actual: ${actualRatio.toStringAsFixed(2)}:1, '
        'Required: ${requiredRatio.toStringAsFixed(2)}:1';
  }
}

extension on double {
  double pow(num exponent) {
    if (this == 0) return 0;
    return math.pow(this, exponent).toDouble();
  }
}
