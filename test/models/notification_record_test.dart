import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/notification_record.dart';

void main() {
  group('NotificationRecord', () {
    test('should create NotificationRecord with all fields', () {
      final timestamp = DateTime.now();
      final payload = {'key': 'value'};

      final notification = NotificationRecord(
        id: '123',
        title: 'Test Notification',
        message: 'This is a test message',
        timestamp: timestamp,
        type: NotificationRecordType.order,
        read: false,
        deepLink: 'agrolink://order/123',
        payload: payload,
        iconUrl: 'https://example.com/icon.png',
      );

      expect(notification.id, '123');
      expect(notification.title, 'Test Notification');
      expect(notification.message, 'This is a test message');
      expect(notification.timestamp, timestamp);
      expect(notification.type, NotificationRecordType.order);
      expect(notification.read, false);
      expect(notification.deepLink, 'agrolink://order/123');
      expect(notification.payload, payload);
      expect(notification.iconUrl, 'https://example.com/icon.png');
    });

    test('should create NotificationRecord with default read status', () {
      final notification = NotificationRecord(
        id: '123',
        title: 'Test',
        message: 'Message',
        timestamp: DateTime.now(),
        type: NotificationRecordType.system,
      );

      expect(notification.read, false);
      expect(notification.deepLink, null);
      expect(notification.payload, null);
      expect(notification.iconUrl, null);
    });

    test('should convert to JSON correctly', () {
      final timestamp = DateTime.parse('2024-01-01T12:00:00Z');
      final notification = NotificationRecord(
        id: '123',
        title: 'Test',
        message: 'Message',
        timestamp: timestamp,
        type: NotificationRecordType.priceAlert,
        read: true,
        deepLink: 'agrolink://price/123',
        payload: {'price': 100},
        iconUrl: 'https://example.com/icon.png',
      );

      final json = notification.toJson();

      expect(json['id'], '123');
      expect(json['title'], 'Test');
      expect(json['message'], 'Message');
      expect(json['timestamp'], '2024-01-01T12:00:00.000Z');
      expect(json['type'], 'priceAlert');
      expect(json['read'], true);
      expect(json['deepLink'], 'agrolink://price/123');
      expect(json['payload'], {'price': 100});
      expect(json['iconUrl'], 'https://example.com/icon.png');
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'message': 'Message',
        'timestamp': '2024-01-01T12:00:00.000Z',
        'type': 'transport',
        'read': true,
        'deepLink': 'agrolink://transport/123',
        'payload': {'tripId': 'trip123'},
        'iconUrl': 'https://example.com/icon.png',
      };

      final notification = NotificationRecord.fromJson(json);

      expect(notification.id, '123');
      expect(notification.title, 'Test');
      expect(notification.message, 'Message');
      expect(notification.timestamp, DateTime.parse('2024-01-01T12:00:00.000Z'));
      expect(notification.type, NotificationRecordType.transport);
      expect(notification.read, true);
      expect(notification.deepLink, 'agrolink://transport/123');
      expect(notification.payload, {'tripId': 'trip123'});
      expect(notification.iconUrl, 'https://example.com/icon.png');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'message': 'Message',
        'timestamp': '2024-01-01T12:00:00.000Z',
        'type': 'system',
      };

      final notification = NotificationRecord.fromJson(json);

      expect(notification.read, false);
      expect(notification.deepLink, null);
      expect(notification.payload, null);
      expect(notification.iconUrl, null);
    });

    test('should fallback to system type for unknown type', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'message': 'Message',
        'timestamp': '2024-01-01T12:00:00.000Z',
        'type': 'unknownType',
      };

      final notification = NotificationRecord.fromJson(json);

      expect(notification.type, NotificationRecordType.system);
    });

    test('copyWith should create new instance with updated fields', () {
      final original = NotificationRecord(
        id: '123',
        title: 'Test',
        message: 'Message',
        timestamp: DateTime.now(),
        type: NotificationRecordType.order,
        read: false,
      );

      final updated = original.copyWith(read: true, title: 'Updated Test');

      expect(updated.id, original.id);
      expect(updated.title, 'Updated Test');
      expect(updated.read, true);
      expect(updated.message, original.message);
      expect(updated.type, original.type);
    });

    test('timeAgo should return correct time strings', () {
      final now = DateTime.now();
      
      // Just now
      final justNow = NotificationRecord(
        id: '1',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(seconds: 30)),
        type: NotificationRecordType.system,
      );
      expect(justNow.timeAgo, 'Just now');

      // Minutes ago
      final minutesAgo = NotificationRecord(
        id: '2',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: NotificationRecordType.system,
      );
      expect(minutesAgo.timeAgo, '5 minutes ago');

      // Hours ago
      final hoursAgo = NotificationRecord(
        id: '3',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: NotificationRecordType.system,
      );
      expect(hoursAgo.timeAgo, '3 hours ago');

      // Days ago
      final daysAgo = NotificationRecord(
        id: '4',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(days: 2)),
        type: NotificationRecordType.system,
      );
      expect(daysAgo.timeAgo, '2 days ago');
    });

    test('isRecent should return true for notifications within last hour', () {
      final now = DateTime.now();
      
      final recent = NotificationRecord(
        id: '1',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: NotificationRecordType.system,
      );
      expect(recent.isRecent, true);

      final notRecent = NotificationRecord(
        id: '2',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationRecordType.system,
      );
      expect(notRecent.isRecent, false);
    });

    test('isToday should return true for notifications from today', () {
      final now = DateTime.now();
      
      final today = NotificationRecord(
        id: '1',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationRecordType.system,
      );
      expect(today.isToday, true);

      final yesterday = NotificationRecord(
        id: '2',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationRecordType.system,
      );
      expect(yesterday.isToday, false);
    });

    test('isExpired should return true for notifications older than 30 days', () {
      final now = DateTime.now();
      
      final notExpired = NotificationRecord(
        id: '1',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(days: 29)),
        type: NotificationRecordType.system,
      );
      expect(notExpired.isExpired, false);

      final expired = NotificationRecord(
        id: '2',
        title: 'Test',
        message: 'Message',
        timestamp: now.subtract(const Duration(days: 31)),
        type: NotificationRecordType.system,
      );
      expect(expired.isExpired, true);
    });
  });

  group('NotificationRecordType', () {
    test('should have correct display names', () {
      expect(NotificationRecordType.order.displayName, 'Order');
      expect(NotificationRecordType.transport.displayName, 'Transport');
      expect(NotificationRecordType.priceAlert.displayName, 'Price Alert');
      expect(NotificationRecordType.system.displayName, 'System');
      expect(NotificationRecordType.marketing.displayName, 'Marketing');
    });

    test('should have correct icons', () {
      expect(NotificationRecordType.order.icon, '📦');
      expect(NotificationRecordType.transport.icon, '🚚');
      expect(NotificationRecordType.priceAlert.icon, '💰');
      expect(NotificationRecordType.system.icon, '⚙️');
      expect(NotificationRecordType.marketing.icon, '🎯');
    });

    test('should have correct channel IDs', () {
      expect(NotificationRecordType.order.channelId, 'orders');
      expect(NotificationRecordType.transport.channelId, 'transport');
      expect(NotificationRecordType.priceAlert.channelId, 'price_alerts');
      expect(NotificationRecordType.system.channelId, 'system');
      expect(NotificationRecordType.marketing.channelId, 'marketing');
    });

    test('should have correct channel names', () {
      expect(NotificationRecordType.order.channelName, 'Orders');
      expect(NotificationRecordType.transport.channelName, 'Transport & Delivery');
      expect(NotificationRecordType.priceAlert.channelName, 'Price Alerts');
      expect(NotificationRecordType.system.channelName, 'System Notifications');
      expect(NotificationRecordType.marketing.channelName, 'Marketing & Promotions');
    });
  });
}
