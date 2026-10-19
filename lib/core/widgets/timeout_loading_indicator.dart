import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/widgets/loading_indicator.dart';

/// TimeoutLoadingIndicator
/// Loading indicator with automatic timeout handling
/// Shows timeout message after specified duration (default 30 seconds)
///
/// **Validates: Requirements 14.7**

class TimeoutLoadingIndicator extends StatefulWidget {
  /// Duration before showing timeout message
  final Duration timeout;

  /// Optional loading message
  final String? loadingMessage;

  /// Timeout message to display
  final String timeoutMessage;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Retry button label
  final String retryLabel;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const TimeoutLoadingIndicator({
    super.key,
    this.timeout = const Duration(seconds: 30),
    this.loadingMessage,
    this.timeoutMessage = 'This is taking longer than expected. Please try again.',
    this.onRetry,
    this.retryLabel = 'Retry',
    this.semanticLabel,
  });

  @override
  State<TimeoutLoadingIndicator> createState() => _TimeoutLoadingIndicatorState();
}

class _TimeoutLoadingIndicatorState extends State<TimeoutLoadingIndicator> {
  Timer? _timer;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(widget.timeout, () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  void _handleRetry() {
    setState(() {
      _hasTimedOut = false;
    });
    _timer?.cancel();
    _startTimer();
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasTimedOut) {
      return Semantics(
        label: widget.semanticLabel ?? 'Request timed out',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 80,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Request Timeout',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.timeoutMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(widget.retryLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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

    return LoadingIndicator(
      message: widget.loadingMessage,
      centered: true,
      semanticLabel: widget.semanticLabel,
    );
  }
}

/// Extension to add timeout handling to Future operations
extension FutureWithTimeout<T> on Future<T> {
  /// Execute future with timeout and automatic error handling
  Future<T> withTimeout({
    Duration timeout = const Duration(seconds: 30),
    String? timeoutMessage,
  }) {
    return this.timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException(
          timeoutMessage ?? 'Operation timed out after ${timeout.inSeconds} seconds',
          timeout,
        );
      },
    );
  }
}

/// Mixin for widgets that need timeout handling
mixin TimeoutHandlerMixin<T extends StatefulWidget> on State<T> {
  final Map<String, Timer> _timers = {};

  /// Start a timeout timer
  void startTimeout(
    String key, {
    required Duration duration,
    required VoidCallback onTimeout,
  }) {
    cancelTimeout(key);
    _timers[key] = Timer(duration, () {
      _timers.remove(key);
      if (mounted) {
        onTimeout();
      }
    });
  }

  /// Cancel a timeout timer
  void cancelTimeout(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Cancel all timeout timers
  void cancelAllTimeouts() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    cancelAllTimeouts();
    super.dispose();
  }
}
