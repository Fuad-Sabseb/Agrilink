import 'package:hive/hive.dart';
import 'notification_record.dart';

part 'notification_rate_limit.g.dart';

/// NotificationRateLimit Model
/// Tracks notification timestamps per type to implement rate limiting
/// Prevents notification spam by throttling notifications of the same type
@HiveType(typeId: 15)
class NotificationRateLimit extends HiveObject {
  @HiveField(0)
  final int typeIndex;

  @HiveField(1)
  final List<DateTime> recentNotifications;

  @HiveField(2)
  final int maxPerMinute;

  NotificationRateLimit({
    required this.typeIndex,
    required this.recentNotifications,
    this.maxPerMinute = 5,
  });

  /// Create a new NotificationRateLimit for a specific type
  factory NotificationRateLimit.create({
    required NotificationRecordType type,
    int maxPerMinute = 5,
  }) {
    return NotificationRateLimit(
      typeIndex: type.index,
      recentNotifications: [],
      maxPerMinute: maxPerMinute,
    );
  }

  /// Get the notification type from the stored index
  NotificationRecordType get type => NotificationRecordType.values[typeIndex];

  /// Check if a new notification should be throttled based on rate limits
  /// Returns true if the notification should be throttled (not shown)
  bool shouldThrottle() {
    // Clean up old notifications (older than 1 minute)
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    // Count notifications within the last minute
    final recentCount = recentNotifications
        .where((timestamp) => timestamp.isAfter(oneMinuteAgo))
        .length;
    
    // Throttle if we've exceeded the limit
    return recentCount >= maxPerMinute;
  }

  /// Add a new notification timestamp to track rate limits
  /// Automatically cleans up timestamps older than 1 minute
  /// Returns a new NotificationRateLimit instance (immutable pattern)
  NotificationRateLimit addNotification() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    // Filter out notifications older than 1 minute and add the new one
    final updatedNotifications = recentNotifications
        .where((timestamp) => timestamp.isAfter(oneMinuteAgo))
        .toList()
      ..add(now);
    
    return NotificationRateLimit(
      typeIndex: typeIndex,
      recentNotifications: updatedNotifications,
      maxPerMinute: maxPerMinute,
    );
  }

  /// Get the number of recent notifications (within last minute)
  int get recentNotificationCount {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    return recentNotifications
        .where((timestamp) => timestamp.isAfter(oneMinuteAgo))
        .length;
  }

  /// Get the time remaining until the next notification can be shown
  /// Returns null if a notification can be shown immediately
  Duration? get timeUntilNextAllowed {
    if (!shouldThrottle()) {
      return null;
    }
    
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    // Find the oldest notification within the last minute
    final recentTimestamps = recentNotifications
        .where((timestamp) => timestamp.isAfter(oneMinuteAgo))
        .toList()
      ..sort();
    
    if (recentTimestamps.isEmpty) {
      return null;
    }
    
    // The oldest notification will expire first
    final oldestTimestamp = recentTimestamps.first;
    final expiryTime = oldestTimestamp.add(const Duration(minutes: 1));
    
    return expiryTime.difference(now);
  }

  /// Create a copy with updated fields
  NotificationRateLimit copyWith({
    int? typeIndex,
    List<DateTime>? recentNotifications,
    int? maxPerMinute,
  }) {
    return NotificationRateLimit(
      typeIndex: typeIndex ?? this.typeIndex,
      recentNotifications: recentNotifications ?? this.recentNotifications,
      maxPerMinute: maxPerMinute ?? this.maxPerMinute,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'recent_notifications': recentNotifications.map((dt) => dt.toIso8601String()).toList(),
      'max_per_minute': maxPerMinute,
    };
  }

  /// Create from JSON
  factory NotificationRateLimit.fromJson(Map<String, dynamic> json) {
    final type = NotificationRecordType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationRecordType.system,
    );
    
    final recentNotifications = (json['recent_notifications'] as List<dynamic>?)
            ?.map((dateStr) => DateTime.parse(dateStr as String))
            .toList() ??
        [];
    
    return NotificationRateLimit(
      typeIndex: type.index,
      recentNotifications: recentNotifications,
      maxPerMinute: json['max_per_minute'] as int? ?? 5,
    );
  }

  @override
  String toString() {
    return 'NotificationRateLimit(type: ${type.name}, recentCount: $recentNotificationCount, maxPerMinute: $maxPerMinute)';
  }
}
