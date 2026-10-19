import 'package:hive/hive.dart';
import 'notification_record.dart';

part 'notification_rate_limit.g.dart';

@HiveType(typeId: 15)
class NotificationRateLimit extends HiveObject {
  @HiveField(0)
  final int typeIndex;

  @HiveField(1)
  List<DateTime> recentNotifications;

  @HiveField(2)
  final int maxPerMinute;

  NotificationRateLimit({
    required this.typeIndex,
    List<DateTime>? recentNotifications,
    this.maxPerMinute = 5,
  }) : recentNotifications = recentNotifications ?? [];

  factory NotificationRateLimit.create({
    required NotificationRecordType type,
    List<DateTime>? recentNotifications,
    int maxPerMinute = 5,
  }) {
    return NotificationRateLimit(
      typeIndex: type.index,
      recentNotifications: recentNotifications,
      maxPerMinute: maxPerMinute,
    );
  }

  NotificationRecordType get type => NotificationRecordType.values[typeIndex];

  bool shouldThrottle() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    recentNotifications.removeWhere((time) => time.isBefore(oneMinuteAgo));
    return recentNotifications.length >= maxPerMinute;
  }

  void addNotification() {
    final now = DateTime.now();
    recentNotifications.add(now);
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    recentNotifications.removeWhere((time) => time.isBefore(oneMinuteAgo));
    save();
  }

  int get currentCount => recentNotifications.length;
}
