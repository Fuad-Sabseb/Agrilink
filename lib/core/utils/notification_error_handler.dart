import 'dart:developer' as developer;

class NotificationErrorHandler {
  static void handleFCMError(dynamic error) {
    developer.log(
      'FCM Error: $error',
      name: 'NotificationService',
      error: error,
    );
  }

  static void handleDeepLinkError(String deepLink, dynamic error) {
    developer.log(
      'Deep link navigation failed: $deepLink',
      name: 'DeepLinkService',
      error: error,
    );
  }

  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'NotificationService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
