import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/location_coordinate.dart';

void main() {
  group('LocationCoordinate', () {
    group('Constructor validation', () {
      test('should create LocationCoordinate with valid Ethiopia coordinates',
          () {
        // Jimma coordinates (valid)
        final coordinate = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
        );

        expect(coordinate.latitude, 7.6804);
        expect(coordinate.longitude, 36.8352);
        expect(coordinate.timestamp, isNotNull);
      });

      test('should create LocationCoordinate with custom timestamp', () {
        final customTimestamp = DateTime(2024, 1, 15, 10, 30);
        final coordinate = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: customTimestamp,
        );

        expect(coordinate.timestamp, equals(customTimestamp));
      });

      test('should accept coordinates at Ethiopia northern boundary', () {
        // 15°N is the northern boundary
        final coordinate = LocationCoordinate(
          latitude: 15.0,
          longitude: 36.0,
        );

        expect(coordinate.latitude, 15.0);
      });

      test('should accept coordinates at Ethiopia southern boundary', () {
        // 3°N is the southern boundary
        final coordinate = LocationCoordinate(
          latitude: 3.0,
          longitude: 36.0,
        );

        expect(coordinate.latitude, 3.0);
      });

      test('should accept coordinates at Ethiopia eastern boundary', () {
        // 48°E is the eastern boundary
        final coordinate = LocationCoordinate(
          latitude: 9.0,
          longitude: 48.0,
        );

        expect(coordinate.longitude, 48.0);
      });

      test('should accept coordinates at Ethiopia western boundary', () {
        // 33°E is the western boundary
        final coordinate = LocationCoordinate(
          latitude: 9.0,
          longitude: 33.0,
        );

        expect(coordinate.longitude, 33.0);
      });

      test('should reject latitude below 3°N', () {
        expect(
          () => LocationCoordinate(
            latitude: 2.9,
            longitude: 36.0,
          ),
          throwsA(isA<InvalidLocationException>().having(
            (e) => e.message,
            'message',
            contains('outside Ethiopia bounds'),
          )),
        );
      });

      test('should reject latitude above 15°N', () {
        expect(
          () => LocationCoordinate(
            latitude: 15.1,
            longitude: 36.0,
          ),
          throwsA(isA<InvalidLocationException>().having(
            (e) => e.message,
            'message',
            contains('outside Ethiopia bounds'),
          )),
        );
      });

      test('should reject longitude below 33°E', () {
        expect(
          () => LocationCoordinate(
            latitude: 9.0,
            longitude: 32.9,
          ),
          throwsA(isA<InvalidLocationException>().having(
            (e) => e.message,
            'message',
            contains('outside Ethiopia bounds'),
          )),
        );
      });

      test('should reject longitude above 48°E', () {
        expect(
          () => LocationCoordinate(
            latitude: 9.0,
            longitude: 48.1,
          ),
          throwsA(isA<InvalidLocationException>().having(
            (e) => e.message,
            'message',
            contains('outside Ethiopia bounds'),
          )),
        );
      });

      test('should reject null island coordinates (0.0, 0.0)', () {
        expect(
          () => LocationCoordinate(
            latitude: 0.0,
            longitude: 0.0,
          ),
          throwsA(isA<InvalidLocationException>().having(
            (e) => e.message,
            'message',
            contains('null island'),
          )),
        );
      });
    });

    group('JSON serialization', () {
      test('should convert LocationCoordinate to JSON', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final coordinate = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );

        final json = coordinate.toJson();

        expect(json['latitude'], 7.6804);
        expect(json['longitude'], 36.8352);
        expect(json['timestamp'], timestamp.toIso8601String());
      });

      test('should create LocationCoordinate from JSON', () {
        final json = {
          'latitude': 7.6804,
          'longitude': 36.8352,
          'timestamp': '2024-01-15T10:30:00.000',
        };

        final coordinate = LocationCoordinate.fromJson(json);

        expect(coordinate.latitude, 7.6804);
        expect(coordinate.longitude, 36.8352);
        expect(coordinate.timestamp, DateTime.parse('2024-01-15T10:30:00.000'));
      });

      test('should create LocationCoordinate from JSON without timestamp', () {
        final json = {
          'latitude': 7.6804,
          'longitude': 36.8352,
        };

        final coordinate = LocationCoordinate.fromJson(json);

        expect(coordinate.latitude, 7.6804);
        expect(coordinate.longitude, 36.8352);
        expect(coordinate.timestamp, isNotNull);
      });

      test('should handle numeric types in JSON (int to double)', () {
        final json = {
          'latitude': 7, // int instead of double
          'longitude': 36, // int instead of double
          'timestamp': '2024-01-15T10:30:00.000',
        };

        final coordinate = LocationCoordinate.fromJson(json);

        expect(coordinate.latitude, 7.0);
        expect(coordinate.longitude, 36.0);
      });

      test('should validate coordinates when creating from JSON', () {
        final json = {
          'latitude': 0.0,
          'longitude': 0.0,
          'timestamp': '2024-01-15T10:30:00.000',
        };

        expect(
          () => LocationCoordinate.fromJson(json),
          throwsA(isA<InvalidLocationException>()),
        );
      });
    });

    group('copyWith', () {
      test('should copy LocationCoordinate with updated latitude', () {
        final original = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
        );

        final copied = original.copyWith(latitude: 8.0);

        expect(copied.latitude, 8.0);
        expect(copied.longitude, 36.8352);
        expect(copied.timestamp, original.timestamp);
      });

      test('should copy LocationCoordinate with updated longitude', () {
        final original = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
        );

        final copied = original.copyWith(longitude: 37.0);

        expect(copied.latitude, 7.6804);
        expect(copied.longitude, 37.0);
      });

      test('should copy LocationCoordinate with updated timestamp', () {
        final original = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
        );

        final newTimestamp = DateTime(2024, 2, 20);
        final copied = original.copyWith(timestamp: newTimestamp);

        expect(copied.timestamp, newTimestamp);
      });

      test('should validate new coordinates in copyWith', () {
        final original = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
        );

        expect(
          () => original.copyWith(latitude: 0.0, longitude: 0.0),
          throwsA(isA<InvalidLocationException>()),
        );
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all fields are equal', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final coord1 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );
        final coord2 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );

        expect(coord1, equals(coord2));
        expect(coord1.hashCode, equals(coord2.hashCode));
      });

      test('should not be equal when latitude differs', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final coord1 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );
        final coord2 = LocationCoordinate(
          latitude: 7.6805,
          longitude: 36.8352,
          timestamp: timestamp,
        );

        expect(coord1, isNot(equals(coord2)));
      });

      test('should not be equal when longitude differs', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final coord1 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );
        final coord2 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8353,
          timestamp: timestamp,
        );

        expect(coord1, isNot(equals(coord2)));
      });

      test('should not be equal when timestamp differs', () {
        final coord1 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: DateTime(2024, 1, 15, 10, 30),
        );
        final coord2 = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: DateTime(2024, 1, 15, 10, 31),
        );

        expect(coord1, isNot(equals(coord2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final coordinate = LocationCoordinate(
          latitude: 7.6804,
          longitude: 36.8352,
          timestamp: timestamp,
        );

        final str = coordinate.toString();

        expect(str, contains('7.680400'));
        expect(str, contains('36.835200'));
        expect(str, contains('2024-01-15'));
      });
    });

    group('InvalidLocationException', () {
      test('should have message property', () {
        final exception = InvalidLocationException('Test message');

        expect(exception.message, 'Test message');
      });

      test('should have formatted toString', () {
        final exception = InvalidLocationException('Test message');

        expect(
          exception.toString(),
          'InvalidLocationException: Test message',
        );
      });
    });
  });
}
