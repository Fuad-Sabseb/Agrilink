import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NotificationErrorHandler - Utility for notification error handling
/// 
/// Handles Firebase Cloud Messaging errors, deep link failures,
/// and token registration with retry logic.
/// 
/// Requirements: 20
class NotificationErrorHandler {
  /// Handle FCM errors with appropriate retry logic
  /// 
  /// Categorizes Firebase exceptions and implements retry strategies.
  /// Returns true if error was handled and should be retried.
  static Future<bool> handleFCMError(
    Exception error,
    String operation,
  ) async {
    print('[NotificationErrorHandler] FCM Error in $operation: $error');
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          print('[NotificationErrorHandler] Permission denied - user needs to grant notification permission');
          return false; // Don't retry, user action required
        
        case 'unavailable':
          print('[NotificationErrorHandler] FCM service unavailable - will retry');
          return true; // Retry
        
        case 'deadline-exceeded':
          print('[NotificationErrorHandler] Request timeout - will retry');
          return true; // Retry
        
        case 'unauthenticated':
          print('[NotificationErrorHandler] Authentication failed - token may be invalid');
          return false; // Don't retry, re-auth required
        
        default:
          print('[NotificationErrorHandler] Unknown FCM error: ${error.code}');
          return false;
      }
    }
    
    // Generic exception - retry with backoff
    return true;
  }

  /// Handle deep link navigation errors
  /// 
  /// Logs deep link failures and provides fallback behavior.
  /// Returns true if error was handled gracefully.
  static Future<bool> handleDeepLinkError(
    String deepLink,
    Exception error,
  ) async {
    print('[NotificationErrorHandler] Deep link navigation failed: $deepLink');
    print('[NotificationErrorHandler] Error: $error');
    
    // Log error with diagnostic information
    await _logDeepLinkFailure(deepLink, error);
    
    // Fall back to home screen (handled by DeepLinkService)
    return true;
  }

  /// Handle FCM token registration failures with exponential backoff retry
  /// 
  /// Implements retry logic: 1s, 2s, 4s, 8s delays.
  /// Returns true if registration succeeded after retry.
  static Future<bool> retryTokenRegistration(
    Future<void> Function() registrationFunction,
  ) async {
    const maxRetries = 4;
    const retryDelays = [1, 2, 4, 8]; // seconds
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await registrationFunction();
        print('[NotificationErrorHandler] Token registration succeeded on attempt ${attempt + 1}');
        return true;
      } catch (error) {
        print('[NotificationErrorHandler] Token registration failed on attempt ${attempt + 1}: $error');
        
        if (attempt < maxRetries - 1) {
          final delay = retryDelays[attempt];
          print('[NotificationErrorHandler] Retrying in $delay seconds...');
          await Future.delayed(Duration(seconds: delay));
        }
      }
    }
    
    print('[NotificationErrorHandler] Token registration failed after $maxRetries attempts');
    return false;
  }

  /// Store pending deep link when authentication is required
  /// 
  /// Saves deep link to SharedPreferences for processing after auth.
  static Future<void> storePendingDeepLink(String deepLink) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_deep_link', deepLink);
      print('[NotificationErrorHandler] Stored pending deep link: $deepLink');
    } catch (error) {
      print('[NotificationErrorHandler] Failed to store pending deep link: $error');
    }
  }

  /// Log deep link failure with diagnostic info
  static Future<void> _logDeepLinkFailure(String deepLink, Exception error) async {
    // In production, this would send to analytics/crash reporting service
    final diagnosticInfo = {
      'deepLink': deepLink,
      'error': error.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    print('[NotificationErrorHandler] Deep link failure diagnostic: $diagnosticInfo');
    
    // Store locally for debugging
    try {
      final prefs = await SharedPreferences.getInstance();
      final failures = prefs.getStringList('deep_link_failures') ?? [];
      failures.add(diagnosticInfo.toString());
      
      // Keep only last 10 failures
      if (failures.length > 10) {
        failures.removeAt(0);
      }
      
      await prefs.setStringList('deep_link_failures', failures);
    } catch (e) {
      print('[NotificationErrorHandler] Failed to log deep link failure: $e');
    }
  }

  /// Get user-friendly error message for notification errors
  static String getUserMessage(Exception error, String currentLang) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return _getPermissionDeniedMessage(currentLang);
        case 'unavailable':
          return _getServiceUnavailableMessage(currentLang);
        default:
          return _getGenericErrorMessage(currentLang);
      }
    }
    
    return _getGenericErrorMessage(currentLang);
  }

  static String _getPermissionDeniedMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Hayyama beeksisa dhowwameera. Mee qindaa\'ina keessaa hayyama kennuu.';
      case 'am':
        return 'የማሳወቂያ ፈቃድ ተከልክሏል። እባክዎ ከቅንብሮች ፈቃድ ይስጡ።';
      default:
        return 'Notification permission denied. Please enable it in Settings.';
    }
  }

  static String _getServiceUnavailableMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Tajaajilli beeksisa amma hin argamu. Mee booda yaali.';
      case 'am':
        return 'የማሳወቂያ አገልግሎት አሁን አይገኝም። እባክዎ ቆየት ብለው ይሞክሩ።';
      default:
        return 'Notification service is currently unavailable. Please try again later.';
    }
  }

  static String _getGenericErrorMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Dogongora beeksisa uumameera. Mee ammas yaali.';
      case 'am':
        return 'የማሳወቂያ ስህተት ተከስቷል። እባክዎ እንደገና ይሞክሩ።';
      default:
        return 'A notification error occurred. Please try again.';
    }
  }
}
