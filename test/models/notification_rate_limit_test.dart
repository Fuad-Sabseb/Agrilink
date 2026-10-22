import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/notification_rate_limit.dart';
import 'package:agrolink/core/models/notification_record.dart';

void main() {
  group('NotificationRateLimit', () {
    test('should create NotificationRateLimit with all fields', () {
      final now = DateTime.now();
      final recentNotifications = [
        now.subtract(const Duration(seconds: 30)),
        now.subtract(const Duration(seconds: 15)),
      ];

      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: recentNotifications,
        maxPerMinute: 5,
      );

      expect(rateLimit.typeIndex, NotificationRecordType.order.index);
      expect(rateLimit.recentNotifications, recentNotifications);
      expect(rateLimit.maxPerMinute, 5);
      expect(rateLimit.type, NotificationRecordType.order);
    });

    test('should create with factory method', () {
      final rateLimit = NotificationRateLimit.create(
        type: NotificationRecordType.transport,
        maxPerMinute: 10,
      );

      expect(rateLimit.type, NotificationRecordType.transport);
      expect(rateLimit.recentNotifications, isEmpty);
      expect(rateLimit.maxPerMinute, 10);
    });

    test('should create with default maxPerMinute', () {
      final rateLimit = NotificationRateLimit.create(
        type: NotificationRecordType.priceAlert,
      );

      expect(rateLimit.maxPerMinute, 5);
    });

    test('shouldThrottle returns false when under limit', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(seconds: 30)),
          now.subtract(const Duration(seconds: 15)),
        ],
        maxPerMinute: 5,
      );

      expect(rateLimit.shouldThrottle(), false);
    });

    test('shouldThrottle returns true when at limit', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(seconds: 50)),
          now.subtract(const Duration(seconds: 40)),
          now.subtract(const Duration(seconds: 30)),
          now.subtract(const Duration(seconds: 20)),
          now.subtract(const Duration(seconds: 10)),
        ],
        maxPerMinute: 5,
      );

      expect(rateLimit.shouldThrottle(), true);
    });

    test('shouldThrottle returns true when over limit', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.transport.index,
        recentNotifications: [
          now.subtract(const Duration(seconds: 55)),
          now.subtract(const Duration(seconds: 45)),
          now.subtract(const Duration(seconds: 35)),
          now.subtract(const Duration(seconds: 25)),
          now.subtract(const Duration(seconds: 15)),
          now.subtract(const Duration(seconds: 5)),
        ],
        maxPerMinute: 5,
      );

      expect(rateLimit.shouldThrottle(), true);
    });

    test('shouldThrottle ignores old notifications (older than 1 minute)', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(minutes: 2)),
          now.subtract(const Duration(minutes: 1, seconds: 30)),
          now.subtract(const Duration(seconds: 30)),
          now.subtract(const Duration(seconds: 15)),
        ],
        maxPerMinute: 5,
      );

      // Only 2 notifications within the last minute, so should not throttle
      expect(rateLimit.shouldThrottle(), false);
    });

    test('addNotification adds new timestamp and returns new instance', () {
      final now = DateTime.now();
      final original = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(seconds: 30)),
        ],
        maxPerMinute: 5,
      );

      final updated = original.addNotification();

      // Original should be unchanged
      expect(original.recentNotifications.length, 1);
      
      // Updated should have new timestamp
      expect(updated.recentNotifications.length, 2);
      expect(updated.typeIndex, original.typeIndex);
      expect(updated.maxPerMinute, original.maxPerMinute);
    });

    test('addNotification cleans up old timestamps', () {
      final now = DateTime.now();
      final original = NotificationRateLimit(
        typeIndex: NotificationRecordType.priceAlert.index,
        recentNotifications: [
          now.subtract(const Duration(minutes: 2)),
          now.subtract(const Duration(minutes: 1, seconds: 30)),
          now.subtract(const Duration(seconds: 30)),
        ],
        maxPerMinute: 5,
      );

      final updated = original.addNotification();

      // Should only keep notifications from last minute + new one
      expect(updated.recentNotifications.length, 2);
      
      // All timestamps should be within last minute
      for (final timestamp in updated.recentNotifications) {
        final age = now.difference(timestamp);
        expect(age.inMinutes, lessThan(1));
      }
    });

    test('recentNotificationCount returns correct count', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(minutes: 2)), // Old - not counted
          now.subtract(const Duration(seconds: 50)),
          now.subtract(const Duration(seconds: 30)),
          now.subtract(const Duration(seconds: 15)),
        ],
        maxPerMinute: 5,
      );

      expect(rateLimit.recentNotificationCount, 3);
    });

    test('timeUntilNextAllowed returns null when not throttled', () {
      final now = DateTime.now();
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          now.subtract(const Duration(seconds: 30)),
        ],
        maxPerMinute: 5,
      );

      expect(rateLimit.timeUntilNextAllowed, null);
    });

    test('timeUntilNextAllowed returns duration when throttled', () {
      final now = DateTime.now();
      final oldestTimestamp = now.subtract(const Duration(seconds: 50));
      
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.order.index,
        recentNotifications: [
          oldestTimestamp,
          now.subtract(const Duration(seconds: 40)),
          now.subtract(const Duration(seconds: 30)),
          now.subtract(const Duration(seconds: 20)),
          now.subtract(const Duration(seconds: 10)),
        ],
        maxPerMinute: 5,
      );

      final timeUntilNext = rateLimit.timeUntilNextAllowed;
      expect(timeUntilNext, isNotNull);
      
      // Should be approximately 10 seconds (60 - 50)
      expect(timeUntilNext!.inSeconds, greaterThan(5));
      expect(timeUntilNext.inSeconds, lessThanOrEqualTo(15));
    });

    test('copyWith creates new instance with updated fields', () {
      final original = NotificationRateLimit.create(
        type: NotificationRecordType.order,
        maxPerMinute: 5,
      );

      final updated = original.copyWith(
        maxPerMinute: 10,
        recentNotifications: [DateTime.now()],
      );

      expect(updated.typeIndex, original.typeIndex);
      expect(updated.maxPerMinute, 10);
      expect(updated.recentNotifications.length, 1);
      expect(original.maxPerMinute, 5);
      expect(original.recentNotifications, isEmpty);
    });

    test('toJson converts correctly', () {
      final now = DateTime.parse('2024-01-01T12:00:00Z');
      final timestamp1 = now.subtract(const Duration(seconds: 30));
      final timestamp2 = now.subtract(const Duration(seconds: 15));
      
      final rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.transport.index,
        recentNotifications: [timestamp1, timestamp2],
        maxPerMinute: 7,
      );

      final json = rateLimit.toJson();

      expect(json['type'], 'transport');
      expect(json['recent_notifications'], [
        timestamp1.toIso8601String(),
        timestamp2.toIso8601String(),
      ]);
      expect(json['max_per_minute'], 7);
    });

    test('fromJson creates correctly', () {
      final json = {
        'type': 'priceAlert',
        'recent_notifications': [
          '2024-01-01T12:00:00.000Z',
          '2024-01-01T12:00:30.000Z',
        ],
        'max_per_minute': 8,
      };

      final rateLimit = NotificationRateLimit.fromJson(json);

      expect(rateLimit.type, NotificationRecordType.priceAlert);
      expect(rateLimit.recentNotifications.length, 2);
      expect(rateLimit.recentNotifications[0], DateTime.parse('2024-01-01T12:00:00.000Z'));
      expect(rateLimit.recentNotifications[1], DateTime.parse('2024-01-01T12:00:30.000Z'));
      expect(rateLimit.maxPerMinute, 8);
    });

    test('fromJson handles missing recent_notifications', () {
      final json = {
        'type': 'system',
        'max_per_minute': 5,
      };

      final rateLimit = NotificationRateLimit.fromJson(json);

      expect(rateLimit.type, NotificationRecordType.system);
      expect(rateLimit.recentNotifications, isEmpty);
      expect(rateLimit.maxPerMinute, 5);
    });

    test('fromJson handles default maxPerMinute', () {
      final json = {
        'type': 'marketing',
        'recent_notifications': [],
      };

      final rateLimit = NotificationRateLimit.fromJson(json);

      expect(rateLimit.maxPerMinute, 5);
    });

    test('fromJson falls back to system type for unknown type', () {
      final json = {
        'type': 'unknownType',
        'recent_notifications': [],
        'max_per_minute': 5,
      };

      final rateLimit = NotificationRateLimit.fromJson(json);

      expect(rateLimit.type, NotificationRecordType.system);
    });

    test('toString returns correct format', () {
      final rateLimit = NotificationRateLimit.create(
        type: NotificationRecordType.order,
        maxPerMinute: 5,
      );

      final result = rateLimit.toString();

      expect(result, contains('NotificationRateLimit'));
      expect(result, contains('type: order'));
      expect(result, contains('recentCount: 0'));
      expect(result, contains('maxPerMinute: 5'));
    });

    test('rate limiting scenario - gradual throttling', () {
      var rateLimit = NotificationRateLimit.create(
        type: NotificationRecordType.order,
        maxPerMinute: 3,
      );

      // First notification - should not throttle
      expect(rateLimit.shouldThrottle(), false);
      rateLimit = rateLimit.addNotification();

      // Second notification - should not throttle
      expect(rateLimit.shouldThrottle(), false);
      rateLimit = rateLimit.addNotification();

      // Third notification - should not throttle
      expect(rateLimit.shouldThrottle(), false);
      rateLimit = rateLimit.addNotification();

      // Fourth notification - should throttle (at limit)
      expect(rateLimit.shouldThrottle(), true);
    });

    test('rate limiting scenario - recovery after timeout', () {
      final now = DateTime.now();
      
      // Create rate limit with 5 old notifications (> 1 minute ago)
      var rateLimit = NotificationRateLimit(
        typeIndex: NotificationRecordType.priceAlert.index,
        recentNotifications: [
          now.subtract(const Duration(minutes: 2)),
          now.subtract(const Duration(minutes: 1, seconds: 30)),
          now.subtract(const Duration(minutes: 1, seconds: 20)),
          now.subtract(const Duration(minutes: 1, seconds: 10)),
          now.subtract(const Duration(minutes: 1, seconds: 5)),
        ],
        maxPerMinute: 5,
      );

      // Should not throttle because old notifications are ignored
      expect(rateLimit.shouldThrottle(), false);
      
      // Add a new notification
      rateLimit = rateLimit.addNotification();
      
      // Should still not throttle (only 1 recent notification after cleanup)
      expect(rateLimit.shouldThrottle(), false);
      expect(rateLimit.recentNotificationCount, 1);
    });

    test('rate limiting with different types maintains separate limits', () {
      final orderLimit = NotificationRateLimit.create(
        type: NotificationRecordType.order,
        maxPerMinute: 3,
      );
      
      final transportLimit = NotificationRateLimit.create(
        type: NotificationRecordType.transport,
        maxPerMinute: 3,
      );

      // Different types should be independent
      expect(orderLimit.type, NotificationRecordType.order);
      expect(transportLimit.type, NotificationRecordType.transport);
      expect(orderLimit.typeIndex, isNot(equals(transportLimit.typeIndex)));
    });
  });
}
