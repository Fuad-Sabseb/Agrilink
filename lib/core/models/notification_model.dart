import 'package:hive/hive.dart';

part 'notification_model.g.dart';

/// AppNotification Model - Represents an in-app notification
@HiveType(typeId: 30)
class AppNotification {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final NotificationType type;

  @HiveField(5)
  final NotificationPriority priority;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final DateTime? readAt;

  @HiveField(8)
  final String? actionUrl;

  @HiveField(9)
  final Map<String, dynamic>? data;

  @HiveField(10)
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    this.data,
    required this.createdAt,
  });

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
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
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 1;

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Create a copy with updated fields
  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      priority: priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      createdAt: createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'actionUrl': actionUrl,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      actionUrl: json['actionUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Notification Type Enum
@HiveType(typeId: 31)
enum NotificationType {
  @HiveField(0)
  order, // Order-related notifications

  @HiveField(1)
  transport, // Transport/trip notifications

  @HiveField(2)
  produce, // Produce/market notifications

  @HiveField(3)
  system, // System announcements

  @HiveField(4)
  marketing, // Promotional notifications
}

/// Notification Priority Enum
@HiveType(typeId: 32)
enum NotificationPriority {
  @HiveField(0)
  low, // Low priority (marketing, tips)

  @HiveField(1)
  normal, // Normal priority (most notifications)

  @HiveField(2)
  high, // High priority (orders, payments, urgent updates)
}

/// Extension for notification type display
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.order:
        return 'Order';
      case NotificationType.transport:
        return 'Transport';
      case NotificationType.produce:
        return 'Produce';
      case NotificationType.system:
        return 'System';
      case NotificationType.marketing:
        return 'Marketing';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.order:
        return '📦';
      case NotificationType.transport:
        return '🚚';
      case NotificationType.produce:
        return '🌾';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.marketing:
        return '🎯';
    }
  }

  String get color {
    switch (this) {
      case NotificationType.order:
        return '#28A745'; // Green
      case NotificationType.transport:
        return '#FF9800'; // Orange
      case NotificationType.produce:
        return '#8BC34A'; // Light green
      case NotificationType.system:
        return '#17A2B8'; // Blue
      case NotificationType.marketing:
        return '#9C27B0'; // Purple
    }
  }
}

/// Extension for notification priority display
extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
    }
  }

  String get color {
    switch (this) {
      case NotificationPriority.low:
        return '#6C757D'; // Gray
      case NotificationPriority.normal:
        return '#17A2B8'; // Blue
      case NotificationPriority.high:
        return '#DC3545'; // Red
    }
  }
}
