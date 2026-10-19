import 'package:hive/hive.dart';
import 'notification_model.dart';

part 'notification_preference.g.dart';

/// NotificationPreference Model
/// Represents user preferences for each notification channel/category
@HiveType(typeId: 12)
class NotificationPreference extends HiveObject {
  @HiveField(0)
  final NotificationType type;

  @HiveField(1)
  final bool enabled;

  @HiveField(2)
  final bool soundEnabled;

  @HiveField(3)
  final String? customSound;

  NotificationPreference({
    required this.type,
    this.enabled = true,
    this.soundEnabled = true,
    this.customSound,
  });

  /// Create a copy with updated fields
  NotificationPreference copyWith({
    NotificationType? type,
    bool? enabled,
    bool? soundEnabled,
    String? customSound,
  }) {
    return NotificationPreference(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      customSound: customSound ?? this.customSound,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'customSound': customSound,
    };
  }

  /// Create from JSON
  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      enabled: json['enabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      customSound: json['customSound'] as String?,
    );
  }

  /// Get default preferences for all notification types
  static List<NotificationPreference> getDefaults() {
    return [
      NotificationPreference(
        type: NotificationType.order,
        enabled: true,
        soundEnabled: true,
      ),
      NotificationPreference(
        type: NotificationType.transport,
        enabled: true,
        soundEnabled: true,
      ),
      NotificationPreference(
        type: NotificationType.produce,
        enabled: true,
        soundEnabled: true,
      ),
      NotificationPreference(
        type: NotificationType.system,
        enabled: true,
        soundEnabled: true,
      ),
      NotificationPreference(
        type: NotificationType.marketing,
        enabled: false, // Marketing notifications disabled by default
        soundEnabled: false,
      ),
    ];
  }

  /// Get default preference for a specific notification type
  static NotificationPreference getDefaultForType(NotificationType type) {
    return getDefaults().firstWhere(
      (pref) => pref.type == type,
      orElse: () => NotificationPreference(
        type: type,
        enabled: true,
        soundEnabled: true,
      ),
    );
  }

  @override
  String toString() {
    return 'NotificationPreference(type: ${type.name}, enabled: $enabled, soundEnabled: $soundEnabled, customSound: $customSound)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreference &&
        other.type == type &&
        other.enabled == enabled &&
        other.soundEnabled == soundEnabled &&
        other.customSound == customSound;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        enabled.hashCode ^
        soundEnabled.hashCode ^
        (customSound?.hashCode ?? 0);
  }
}
