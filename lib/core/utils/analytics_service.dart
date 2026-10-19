import 'dart:developer' as developer;

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  void logLocationPermissionRequest(String result) {
    developer.log(
      'Location permission requested',
      name: 'LocationAnalytics',
      error: {'result': result},
    );
  }

  void logLocationAcquisition({
    required bool success,
    required Duration duration,
    String? error,
  }) {
    developer.log(
      'Location acquisition',
      name: 'LocationAnalytics',
      error: {
        'success': success,
        'duration_ms': duration.inMilliseconds,
        'error': error,
      },
    );
  }

  void logTrackingEvent(String event, {Map<String, dynamic>? data}) {
    developer.log(
      event,
      name: 'LocationAnalytics',
      error: data,
    );
  }

  void logNotificationEvent(String event, {Map<String, dynamic>? data}) {
    developer.log(
      event,
      name: 'NotificationAnalytics',
      error: data,
    );
  }

  void logDeepLinkNavigation({
    required String deepLink,
    required bool success,
    String? error,
  }) {
    developer.log(
      'Deep link navigation',
      name: 'DeepLinkAnalytics',
      error: {
        'deep_link': deepLink,
        'success': success,
        'error': error,
      },
    );
  }
}
