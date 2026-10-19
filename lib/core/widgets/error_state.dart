import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// ErrorState Widget
/// Production-ready error state for API failures and network issues
/// Displays error icon, message, and retry button
///
/// **Validates: Requirements 15.3, 15.4, 15.5**

/// Error type enumeration
enum ErrorType {
  network,
  server,
  client,
  generic,
}

/// Error state widget for error scenarios
class ErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Type of error (affects icon and styling)
  final ErrorType errorType;

  /// Optional retry button callback
  final VoidCallback? onRetry;

  /// Retry button text
  final String retryLabel;

  /// Icon size
  final double iconSize;

  /// Custom icon (overrides errorType icon)
  final IconData? customIcon;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.errorType = ErrorType.generic,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.iconSize = 80.0,
    this.customIcon,
    this.semanticLabel,
  });

  /// Factory constructor for network errors
  factory ErrorState.network({
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return ErrorState(
      message: message ?? 'No internet connection. Please check your network and try again.',
      errorType: ErrorType.network,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  /// Factory constructor for server errors (500-599)
  factory ErrorState.server({
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return ErrorState(
      message: message ?? 'Server error. Please try again later.',
      errorType: ErrorType.server,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  /// Factory constructor for client errors (400-499)
  factory ErrorState.client({
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Go Back',
  }) {
    return ErrorState(
      message: message ?? 'Invalid request. Please try again.',
      errorType: ErrorType.client,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  /// Factory constructor for generic errors
  factory ErrorState.generic({
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return ErrorState(
      message: message ?? 'Something went wrong. Please try again.',
      errorType: ErrorType.generic,
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off_outlined;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.client:
        return Icons.warning_amber_outlined;
      case ErrorType.generic:
        return Icons.error_outline;
    }
  }

  Color _getIconColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (errorType) {
      case ErrorType.network:
        return theme.colorScheme.error;
      case ErrorType.server:
        return theme.colorScheme.error;
      case ErrorType.client:
        return AppColors.warning;
      case ErrorType.generic:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? 'Error: $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error Icon
              Icon(
                _getIcon(),
                size: iconSize,
                color: _getIconColor(context),
              ),
              const SizedBox(height: 24),

              // Error Message
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              // Retry Button
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact error banner for inline error display
class ErrorBanner extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Error type
  final ErrorType errorType;

  /// Optional retry button callback
  final VoidCallback? onRetry;

  /// Whether to show close button
  final bool showCloseButton;

  /// Close callback
  final VoidCallback? onClose;

  const ErrorBanner({
    super.key,
    required this.message,
    this.errorType = ErrorType.generic,
    this.onRetry,
    this.showCloseButton = false,
    this.onClose,
  });

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (errorType) {
      case ErrorType.network:
        return theme.colorScheme.errorContainer;
      case ErrorType.server:
        return theme.colorScheme.errorContainer;
      case ErrorType.client:
        return AppColors.secondary.withValues(alpha: 0.1);
      case ErrorType.generic:
        return theme.colorScheme.errorContainer;
    }
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (errorType) {
      case ErrorType.network:
        return theme.colorScheme.onErrorContainer;
      case ErrorType.server:
        return theme.colorScheme.onErrorContainer;
      case ErrorType.client:
        return AppColors.secondary;
      case ErrorType.generic:
        return theme.colorScheme.onErrorContainer;
    }
  }

  IconData _getIcon() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.error;
      case ErrorType.client:
        return Icons.warning_amber;
      case ErrorType.generic:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            size: 24,
            color: _getTextColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(context),
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(color: _getTextColor(context)),
              ),
            ),
          ],
          if (showCloseButton && onClose != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              color: _getTextColor(context),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper function to determine error type from exception
ErrorType getErrorTypeFromException(dynamic error) {
  final errorString = error.toString().toLowerCase();

  if (errorString.contains('socket') ||
      errorString.contains('network') ||
      errorString.contains('connection') ||
      errorString.contains('offline')) {
    return ErrorType.network;
  }

  if (errorString.contains('500') ||
      errorString.contains('502') ||
      errorString.contains('503') ||
      errorString.contains('504')) {
    return ErrorType.server;
  }

  if (errorString.contains('400') ||
      errorString.contains('401') ||
      errorString.contains('403') ||
      errorString.contains('404')) {
    return ErrorType.client;
  }

  return ErrorType.generic;
}

/// Helper function to get user-friendly error message
String getUserFriendlyErrorMessage(dynamic error) {
  final errorString = error.toString().toLowerCase();

  if (errorString.contains('socket') ||
      errorString.contains('network') ||
      errorString.contains('connection')) {
    return 'No internet connection. Please check your network.';
  }

  if (errorString.contains('timeout')) {
    return 'Request timed out. Please try again.';
  }

  if (errorString.contains('500') || errorString.contains('server')) {
    return 'Server error. Please try again later.';
  }

  if (errorString.contains('401') || errorString.contains('unauthorized')) {
    return 'Session expired. Please login again.';
  }

  if (errorString.contains('403') || errorString.contains('forbidden')) {
    return 'You don\'t have permission to access this.';
  }

  if (errorString.contains('404') || errorString.contains('not found')) {
    return 'Resource not found.';
  }

  return 'Something went wrong. Please try again.';
}
