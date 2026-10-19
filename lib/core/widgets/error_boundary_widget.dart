import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Error Boundary Widget
/// Wraps widgets to catch and handle errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Capture errors in the widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        widget.onError?.call(details.exception, details.stack);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          ErrorFallbackWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    return widget.child;
  }
}

/// Default error fallback widget
class ErrorFallbackWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const ErrorFallbackWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _getUserFriendlyMessage(error),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }

    if (errorString.contains('permission')) {
      return 'Permission denied. Please check your app permissions.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Your session has expired. Please log in again.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    return 'An unexpected error occurred. Please try again later.';
  }
}

/// Error Snackbar Helper
class ErrorSnackbar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Success Snackbar Helper
class SuccessSnackbar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Loading Overlay
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    hide(); // Remove any existing overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Global error handler setup
class GlobalErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Catch errors in async operations
    // Note: In production, send errors to a logging service
  }

  static void _logError(Object error, StackTrace? stackTrace) {
    // In production, send to error tracking service (e.g., Sentry, Firebase Crashlytics)
    // For now, just print in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('❌ Error: $error');
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
  }

  /// Handle API errors
  static String getApiErrorMessage(dynamic error) {
    if (error is Map) {
      return error['message'] as String? ??
          error['error'] as String? ??
          'An error occurred';
    }
    return error.toString();
  }
}
