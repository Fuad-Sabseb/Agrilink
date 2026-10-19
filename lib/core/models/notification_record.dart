import 'package:hive/hive.dart';

part 'notification_record.g.dart';

/// NotificationRecord Model
/// Represents a push notification record for history and persistence
/// This is used for Phase 3 push notification infrastructure
@HiveType(typeId: 35)
class NotificationRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final NotificationRecordType type;

  @HiveField(5)
  final bool read;

  @HiveField(6)
  final String? deepLink;

  @HiveField(7)
  final Map<String, dynamic>? payload;

  @HiveField(8)
  final String? iconUrl;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.read = false,
    this.deepLink,
    this.payload,
    this.iconUrl,
  });

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if notification is recent (within last hour)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 1;

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Check if notification is older than 30 days
  bool get isExpired => DateTime.now().difference(timestamp).inDays > 30;

  /// Create a copy with updated fields
  NotificationRecord copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationRecordType? type,
    bool? read,
    String? deepLink,
    Map<String, dynamic>? payload,
    String? iconUrl,
  }) {
    return NotificationRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      read: read ?? this.read,
      deepLink: deepLink ?? this.deepLink,
      payload: payload ?? this.payload,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'read': read,
      'deepLink': deepLink,
      'payload': payload,
      'iconUrl': iconUrl,
    };
  }

  /// Create from JSON
  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationRecordType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationRecordType.system,
      ),
      read: json['read'] as bool? ?? false,
      deepLink: json['deepLink'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotificationRecord(id: $id, title: $title, type: ${type.name}, read: $read, timestamp: $timestamp)';
  }
}

/// Notification Type Enum for NotificationRecord
/// Defines the categories/channels for push notifications
@HiveType(typeId: 36)
enum NotificationRecordType {
  @HiveField(0)
  order, // Order-related notifications

  @HiveField(1)
  transport, // Transport/delivery notifications

  @HiveField(2)
  priceAlert, // Price alert notifications

  @HiveField(3)
  system, // System announcements and updates

  @HiveField(4)
  marketing, // Promotional and marketing notifications
}

/// Extension for notification type display
extension NotificationRecordTypeExtension on NotificationRecordType {
  /// Get display name for the notification type
  String get displayName {
    switch (this) {
      case NotificationRecordType.order:
        return 'Order';
      case NotificationRecordType.transport:
        return 'Transport';
      case NotificationRecordType.priceAlert:
        return 'Price Alert';
      case NotificationRecordType.system:
        return 'System';
      case NotificationRecordType.marketing:
        return 'Marketing';
    }
  }

  /// Get icon emoji for the notification type
  String get icon {
    switch (this) {
      case NotificationRecordType.order:
        return '📦';
      case NotificationRecordType.transport:
        return '🚚';
      case NotificationRecordType.priceAlert:
        return '💰';
      case NotificationRecordType.system:
        return '⚙️';
      case NotificationRecordType.marketing:
        return '🎯';
    }
  }

  /// Get color hex code for the notification type
  String get color {
    switch (this) {
      case NotificationRecordType.order:
        return '#28A745'; // Green
      case NotificationRecordType.transport:
        return '#FF9800'; // Orange
      case NotificationRecordType.priceAlert:
        return '#FFC107'; // Amber
      case NotificationRecordType.system:
        return '#17A2B8'; // Blue
      case NotificationRecordType.marketing:
        return '#9C27B0'; // Purple
    }
  }

  /// Get channel ID for Android notification channels
  String get channelId {
    switch (this) {
      case NotificationRecordType.order:
        return 'orders';
      case NotificationRecordType.transport:
        return 'transport';
      case NotificationRecordType.priceAlert:
        return 'price_alerts';
      case NotificationRecordType.system:
        return 'system';
      case NotificationRecordType.marketing:
        return 'marketing';
    }
  }

  /// Get channel name for Android notification channels
  String get channelName {
    switch (this) {
      case NotificationRecordType.order:
        return 'Orders';
      case NotificationRecordType.transport:
        return 'Transport & Delivery';
      case NotificationRecordType.priceAlert:
        return 'Price Alerts';
      case NotificationRecordType.system:
        return 'System Notifications';
      case NotificationRecordType.marketing:
        return 'Marketing & Promotions';
    }
  }

  /// Get channel description for Android notification channels
  String get channelDescription {
    switch (this) {
      case NotificationRecordType.order:
        return 'Notifications about order status and updates';
      case NotificationRecordType.transport:
        return 'Notifications about transport and delivery tracking';
      case NotificationRecordType.priceAlert:
        return 'Notifications about price changes and market updates';
      case NotificationRecordType.system:
        return 'Important system announcements and updates';
      case NotificationRecordType.marketing:
        return 'Promotional offers and marketing messages';
    }
  }
}
