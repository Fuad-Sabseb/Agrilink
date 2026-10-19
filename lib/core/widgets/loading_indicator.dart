import 'package:flutter/material.dart';

/// LoadingIndicator Widget
/// Production-ready loading indicator for short operations (< 30 seconds)
/// Supports centered and inline layouts with optional message
///
/// **Validates: Requirements 14.4, 14.5, 14.7**

/// Standard loading indicator with optional message
class LoadingIndicator extends StatelessWidget {
  /// Optional message to display below the spinner
  final String? message;

  /// Whether to center the indicator (true) or inline (false)
  final bool centered;

  /// Size of the circular progress indicator
  final double size;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const LoadingIndicator({
    super.key,
    this.message,
    this.centered = true,
    this.size = 40.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Semantics(
      label: semanticLabel ?? message ?? 'Loading',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (centered) {
      return Center(child: indicator);
    }

    return indicator;
  }
}

/// Small inline loading indicator (e.g., for buttons)
class InlineLoadingIndicator extends StatelessWidget {
  /// Size of the spinner
  final double size;

  /// Color of the spinner
  final Color? color;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const InlineLoadingIndicator({
    super.key,
    this.size = 20.0,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading',
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color!)
              : null,
        ),
      ),
    );
  }
}

/// Loading overlay that covers the entire screen
class LoadingOverlay extends StatelessWidget {
  /// Optional message to display
  final String? message;

  /// Whether to show a semi-transparent background
  final bool withBackground;

  /// Background color
  final Color? backgroundColor;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const LoadingOverlay({
    super.key,
    this.message,
    this.withBackground = true,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: withBackground
          ? (backgroundColor ??
              theme.colorScheme.surface.withValues(alpha: 0.8))
          : Colors.transparent,
      child: LoadingIndicator(
        message: message,
        centered: true,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

/// Shows a loading dialog
Future<void> showLoadingDialog(
  BuildContext context, {
  String? message,
  bool barrierDismissible = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: LoadingIndicator(
          message: message,
          centered: true,
        ),
      ),
    ),
  );
}
