class Phase3Config {
  // Location Service Configuration
  static const int defaultTrackingIntervalSeconds = 30;
  static const int lowBatteryTrackingIntervalSeconds = 120;
  static const int criticalBatteryTrackingIntervalSeconds = 300;
  static const int lowBatteryThreshold = 15;
  static const int criticalBatteryThreshold = 5;
  static const int locationTimeoutSeconds = 30;
  static const int maxOfflineQueueSize = 500;
  static const int locationBatchSize = 50;
  static const int maxLocationRetries = 3;
  
  // Notification Service Configuration
  static const int notificationHistoryDays = 30;
  static const int maxNotificationHistory = 1000;
  static const int maxNotificationsPerMinute = 5;
  static const int maxVisibleNotifications = 10;
  static const int fcmTokenRetries = 5;
  
  // Distance Calculation
  static const int distanceCacheHours = 24;
  static const int maxNearestMarkets = 10;
  
  // Deep Link Configuration
  static const String deepLinkScheme = 'agrolink';
  static const int deepLinkNavigationTimeoutSeconds = 30;
  
  // Feature Flags
  static const bool enableMockLocation = false;
  static const bool enableDebugNotifications = false;
  static const bool enableAnalytics = true;
}
