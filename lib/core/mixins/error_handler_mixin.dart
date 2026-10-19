import 'package:flutter/material.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/widgets/error_state.dart';

/// ErrorHandlerMixin
/// Production-ready error handling mixin for stateful widgets with network calls
/// Provides helper methods for error message extraction and display
///
/// **Validates: Requirements 14.3, 14.4, 14.5**

mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Extract user-friendly error message from exception
  String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network unreachable')) {
      return 'No internet connection. Please check your network.';
    }

    if (errorString.contains('connection refused')) {
      return 'Cannot connect to server. Please try again later.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }

    // HTTP status errors
    if (errorString.contains('500') || errorString.contains('internal server error')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('502') || errorString.contains('bad gateway')) {
      return 'Service temporarily unavailable. Please try again.';
    }

    if (errorString.contains('503') || errorString.contains('service unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    if (errorString.contains('504') || errorString.contains('gateway timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'You don\'t have permission to access this resource.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Resource not found.';
    }

    if (errorString.contains('400') || errorString.contains('bad request')) {
      return 'Invalid request. Please check your input.';
    }

    if (errorString.contains('422') || errorString.contains('unprocessable')) {
      return 'Invalid data. Please check your input.';
    }

    // Generic error message
    if (error is Exception) {
      // Try to extract message from exception
      final match = RegExp(r'Exception: (.+)').firstMatch(error.toString());
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  /// Get error type from exception
  ErrorType getErrorType(dynamic error) {
    if (error == null) {
      return ErrorType.generic;
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('offline') ||
        errorString.contains('host lookup')) {
      return ErrorType.network;
    }

    // Server errors (500-599)
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('server error')) {
      return ErrorType.server;
    }

    // Client errors (400-499)
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404') ||
        errorString.contains('422')) {
      return ErrorType.client;
    }

    return ErrorType.generic;
  }

  /// Show error message in a SnackBar
  void showErrorSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration ?? const Duration(seconds: 4),
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

  /// Show error from exception in a SnackBar
  void showErrorFromException(dynamic error, {Duration? duration}) {
    final message = getErrorMessage(error);
    showErrorSnackBar(message, duration: duration);
  }

  /// Show success message in a SnackBar
  void showSuccessSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message in a SnackBar
  void showInfoSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message in a SnackBar
  void showWarningSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Handle error and show appropriate UI
  /// Returns true if error was handled, false otherwise
  bool handleError(dynamic error, {VoidCallback? onRetry}) {
    if (error == null) return false;

    final errorMessage = getErrorMessage(error);

    // For 401 errors, might want to navigate to login
    if (errorMessage.contains('Session expired') || 
        errorMessage.contains('login again')) {
      showErrorSnackBar(errorMessage);
      // Could add navigation to login here if needed
      return true;
    }

    // Show error snackbar
    showErrorSnackBar(errorMessage);
    return true;
  }

  /// Execute an async operation with error handling
  /// Automatically catches and displays errors
  Future<R?> executeWithErrorHandling<R>(
    Future<R> Function() operation, {
    String? errorMessage,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (errorMessage != null) {
        showErrorSnackBar(errorMessage);
      } else {
        showErrorFromException(error);
      }
      onError?.call();
      return null;
    }
  }
}
