import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utilities for accessibility compliance
class AccessibilityUtils {
  /// Minimum tap target size per Material Design guidelines
  static const double minTapTargetSize = 48.0;

  /// Check if a widget size meets minimum tap target requirements
  static bool meetsTapTargetSize(Size size) {
    return size.width >= minTapTargetSize && size.height >= minTapTargetSize;
  }

  /// Wrap a widget with minimum tap target padding if needed
  static Widget ensureTapTargetSize(Widget child, {Size? currentSize}) {
    if (currentSize != null && meetsTapTargetSize(currentSize)) {
      return child;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: minTapTargetSize,
        minHeight: minTapTargetSize,
      ),
      child: child,
    );
  }

  /// Announce a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce loading state
  static void announceLoading(BuildContext context) {
    announce(context, 'Loading...');
  }

  /// Announce data loaded
  static void announceDataLoaded(BuildContext context, int itemCount) {
    announce(context, 'Loaded $itemCount items');
  }

  /// Announce error
  static void announceError(BuildContext context, String error) {
    announce(context, 'Error: $error');
  }

  /// Announce success
  static void announceSuccess(BuildContext context, String message) {
    announce(context, 'Success: $message');
  }

  /// Create semantic label for a button
  static String buttonLabel(String text, {String? hint}) {
    if (hint != null) {
      return '$text. $hint';
    }
    return '$text button';
  }

  /// Create semantic label for an input field
  static String inputLabel(String label, {bool required = false, String? hint}) {
    final buffer = StringBuffer(label);
    if (required) {
      buffer.write(', required');
    }
    if (hint != null) {
      buffer.write('. $hint');
    }
    return buffer.toString();
  }

  /// Create semantic label for an image
  static String imageLabel(String description) {
    return 'Image: $description';
  }

  /// Create semantic label for an icon
  static String iconLabel(String purpose) {
    return '$purpose icon';
  }

  /// Wrap widget with Semantics for better accessibility
  static Widget wrapWithSemantics(
    Widget child, {
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? link,
    bool? header,
    bool excludeSemantics = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      link: link ?? false,
      header: header ?? false,
      excludeSemantics: excludeSemantics,
      onTap: onTap,
      child: child,
    );
  }

  /// Check if device has screen reader enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation;
  }

  /// Get recommended font size for accessibility
  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return baseSize * textScaleFactor;
  }

  /// Check if text will overflow at current scale
  static bool willTextOverflow(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }
}

/// Extension for adding semantic labels to common widgets
extension AccessibleWidget on Widget {
  /// Add semantic label to widget
  Widget withSemantics(
    String label, {
    String? hint,
    bool isButton = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      child: this,
    );
  }

  /// Ensure minimum tap target size
  Widget withMinTapTarget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AccessibilityUtils.minTapTargetSize,
        minHeight: AccessibilityUtils.minTapTargetSize,
      ),
      child: this,
    );
  }
}
