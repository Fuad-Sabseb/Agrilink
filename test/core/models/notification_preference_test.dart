import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/notification_preference.dart';
import 'package:agrolink/core/models/notification_model.dart';

void main() {
  group('NotificationPreference Model Tests', () {
    test('Should create NotificationPreference with all fields', () {
      // Arrange & Act
      final preference = NotificationPreference(
        type: NotificationType.order,
        enabled: true,
        soundEnabled: true,
        customSound: 'custom.mp3',
      );

      // Assert
      expect(preference.type, NotificationType.order);
      expect(preference.enabled, true);
      expect(preference.soundEnabled, true);
      expect(preference.customSound, 'custom.mp3');
    });

    test('Should create NotificationPreference with default values', () {
      // Arrange & Act
      final preference = NotificationPreference(
        type: NotificationType.system,
      );

      // Assert
      expect(preference.type, NotificationType.system);
      expect(preference.enabled, true);
      expect(preference.soundEnabled, true);
      expect(preference.customSound, null);
    });

    test('Should copy NotificationPreference with updated fields', () {
      // Arrange
      final original = NotificationPreference(
        type: NotificationType.transport,
        enabled: true,
        soundEnabled: true,
      );

      // Act
      final updated = original.copyWith(
        enabled: false,
        soundEnabled: false,
      );

      // Assert
      expect(updated.type, NotificationType.transport);
      expect(updated.enabled, false);
      expect(updated.soundEnabled, false);
      expect(original.enabled, true); // Original should not change
    });

    test('Should convert NotificationPreference to JSON', () {
      // Arrange
      final preference = NotificationPreference(
        type: NotificationType.produce,
        enabled: false,
        soundEnabled: true,
        customSound: 'alert.wav',
      );

      // Act
      final json = preference.toJson();

      // Assert
      expect(json['type'], 'produce');
      expect(json['enabled'], false);
      expect(json['soundEnabled'], true);
      expect(json['customSound'], 'alert.wav');
    });

    test('Should create NotificationPreference from JSON', () {
      // Arrange
      final json = {
        'type': 'marketing',
        'enabled': false,
        'soundEnabled': false,
        'customSound': null,
      };

      // Act
      final preference = NotificationPreference.fromJson(json);

      // Assert
      expect(preference.type, NotificationType.marketing);
      expect(preference.enabled, false);
      expect(preference.soundEnabled, false);
      expect(preference.customSound, null);
    });

    test('Should handle unknown type in JSON gracefully', () {
      // Arrange
      final json = {
        'type': 'unknown_type',
        'enabled': true,
        'soundEnabled': true,
      };

      // Act
      final preference = NotificationPreference.fromJson(json);

      // Assert - should default to system type
      expect(preference.type, NotificationType.system);
    });

    test('Should return default preferences for all notification types', () {
      // Act
      final defaults = NotificationPreference.getDefaults();

      // Assert
      expect(defaults.length, 5);
      expect(defaults[0].type, NotificationType.order);
      expect(defaults[0].enabled, true);
      expect(defaults[0].soundEnabled, true);

      expect(defaults[1].type, NotificationType.transport);
      expect(defaults[1].enabled, true);

      expect(defaults[2].type, NotificationType.produce);
      expect(defaults[2].enabled, true);

      expect(defaults[3].type, NotificationType.system);
      expect(defaults[3].enabled, true);

      // Marketing should be disabled by default
      expect(defaults[4].type, NotificationType.marketing);
      expect(defaults[4].enabled, false);
      expect(defaults[4].soundEnabled, false);
    });

    test('Should get default preference for specific type', () {
      // Act
      final orderDefault = NotificationPreference.getDefaultForType(
        NotificationType.order,
      );
      final marketingDefault = NotificationPreference.getDefaultForType(
        NotificationType.marketing,
      );

      // Assert
      expect(orderDefault.type, NotificationType.order);
      expect(orderDefault.enabled, true);
      expect(orderDefault.soundEnabled, true);

      expect(marketingDefault.type, NotificationType.marketing);
      expect(marketingDefault.enabled, false);
      expect(marketingDefault.soundEnabled, false);
    });

    test('Should test equality operator', () {
      // Arrange
      final pref1 = NotificationPreference(
        type: NotificationType.order,
        enabled: true,
        soundEnabled: true,
        customSound: 'sound.mp3',
      );
      final pref2 = NotificationPreference(
        type: NotificationType.order,
        enabled: true,
        soundEnabled: true,
        customSound: 'sound.mp3',
      );
      final pref3 = NotificationPreference(
        type: NotificationType.order,
        enabled: false,
        soundEnabled: true,
      );

      // Assert
      expect(pref1 == pref2, true);
      expect(pref1 == pref3, false);
    });

    test('Should test hashCode', () {
      // Arrange
      final pref1 = NotificationPreference(
        type: NotificationType.transport,
        enabled: true,
        soundEnabled: false,
      );
      final pref2 = NotificationPreference(
        type: NotificationType.transport,
        enabled: true,
        soundEnabled: false,
      );

      // Assert
      expect(pref1.hashCode, pref2.hashCode);
    });

    test('Should convert to string correctly', () {
      // Arrange
      final preference = NotificationPreference(
        type: NotificationType.system,
        enabled: true,
        soundEnabled: false,
        customSound: 'beep.mp3',
      );

      // Act
      final string = preference.toString();

      // Assert
      expect(
        string,
        'NotificationPreference(type: system, enabled: true, soundEnabled: false, customSound: beep.mp3)',
      );
    });
  });
}
