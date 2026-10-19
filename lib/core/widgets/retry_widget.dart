import 'package:flutter/material.dart';

/// RetryWidget
/// Provides retry functionality for failed operations
/// Displays error message with retry button
///
/// **Validates: Requirements 14.10, 14.11**

/// Widget that displays retry UI for failed operations
class RetryWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Callback for retry action
  final VoidCallback onRetry;

  /// Retry button label
  final String retryLabel;

  /// Optional icon
  final IconData? icon;

  /// Icon size
  final double iconSize;

  /// Icon color
  final Color? iconColor;

  /// Whether to center the content
  final bool centered;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const RetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
    this.icon,
    this.iconSize = 64.0,
    this.iconColor,
    this.centered = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Semantics(
      label: semanticLabel ?? '$message. $retryLabel button',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
        ),
      ),
    );

    if (centered) {
      return Center(child: content);
    }

    return content;
  }
}

/// Compact retry banner
class RetryBanner extends StatelessWidget {
  /// Error message
  final String message;

  /// Retry callback
  final VoidCallback onRetry;

  /// Retry button label
  final String retryLabel;

  const RetryBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              retryLabel,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mixin for widgets that need retry functionality
mixin RetryMixin<T extends StatefulWidget> on State<T> {
  int _retryCount = 0;
  static const int maxRetries = 3;

  /// Current retry count
  int get retryCount => _retryCount;

  /// Whether max retries reached
  bool get maxRetriesReached => _retryCount >= maxRetries;

  /// Reset retry count
  void resetRetryCount() {
    _retryCount = 0;
  }

  /// Increment retry count
  void incrementRetryCount() {
    _retryCount++;
  }

  /// Execute operation with automatic retry
  Future<T?> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration? delayBetweenRetries,
    void Function(dynamic error, int attempt)? onRetryAttempt,
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        final result = await operation();
        resetRetryCount();
        return result;
      } catch (error) {
        attempt++;
        incrementRetryCount();

        if (attempt >= maxAttempts) {
          rethrow;
        }

        onRetryAttempt?.call(error, attempt);

        if (delayBetweenRetries != null) {
          await Future.delayed(delayBetweenRetries);
        }
      }
    }

    return null;
  }

  /// Execute operation with exponential backoff retry
  Future<T?> executeWithExponentialRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    void Function(dynamic error, int attempt, Duration nextDelay)? onRetryAttempt,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        final result = await operation();
        resetRetryCount();
        return result;
      } catch (error) {
        attempt++;
        incrementRetryCount();

        if (attempt >= maxAttempts) {
          rethrow;
        }

        onRetryAttempt?.call(error, attempt, currentDelay);

        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }

    return null;
  }
}

/// State container for retry operations
class RetryState<T> {
  final T? data;
  final dynamic error;
  final bool isLoading;
  final int retryCount;

  const RetryState({
    this.data,
    this.error,
    this.isLoading = false,
    this.retryCount = 0,
  });

  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get isEmpty => !hasData && !hasError && !isLoading;

  RetryState<T> copyWith({
    T? data,
    dynamic error,
    bool? isLoading,
    int? retryCount,
  }) {
    return RetryState<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  RetryState<T> asLoading() => copyWith(isLoading: true, error: null);
  RetryState<T> asError(dynamic error) => copyWith(error: error, isLoading: false);
  RetryState<T> asSuccess(T data) => copyWith(data: data, error: null, isLoading: false);
  RetryState<T> incrementRetry() => copyWith(retryCount: retryCount + 1);
  RetryState<T> resetRetry() => copyWith(retryCount: 0);
}
