import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/farm_location.dart';
import 'package:agrolink/core/models/location_coordinate.dart';

void main() {
  group('FarmLocation Model Tests', () {
    test('Create FarmLocation with all fields', () {
      final farmLocation = FarmLocation.create(
        farmId: 'farm123',
        latitude: 9.0,
        longitude: 38.74,
        address: 'Addis Ababa, Ethiopia',
        woredaId: 'woreda456',
        registeredAt: DateTime(2024, 1, 15, 10, 30),
        source: LocationSource.gps,
      );

      expect(farmLocation.farmId, 'farm123');
      expect(farmLocation.latitude, 9.0);
      expect(farmLocation.longitude, 38.74);
      expect(farmLocation.address, 'Addis Ababa, Ethiopia');
      expect(farmLocation.woredaId, 'woreda456');
      expect(farmLocation.source, LocationSource.gps);
      expect(farmLocation.registeredAt, DateTime(2024, 1, 15, 10, 30));
    });

    test('Create FarmLocation without optional address', () {
      final farmLocation = FarmLocation.create(
        farmId: 'farm456',
        latitude: 8.5,
        longitude: 39.5,
        woredaId: 'woreda789',
        registeredAt: DateTime(2024, 2, 1),
        source: LocationSource.manual,
      );

      expect(farmLocation.farmId, 'farm456');
      expect(farmLocation.address, null);
      expect(farmLocation.source, LocationSource.manual);
    });

    test('Get coordinate from FarmLocation', () {
      final farmLocation = FarmLocation.create(
        farmId: 'farm789',
        latitude: 10.5,
        longitude: 40.25,
        woredaId: 'woreda111',
        registeredAt: DateTime(2024, 3, 10, 14, 20),
        source: LocationSource.network,
      );

      final coordinate = farmLocation.coordinate;

      expect(coordinate.latitude, 10.5);
      expect(coordinate.longitude, 40.25);
      expect(coordinate.timestamp, DateTime(2024, 3, 10, 14, 20));
    });

    test('LocationSource enum values', () {
      expect(LocationSource.values.length, 3);
      expect(LocationSource.values, [
        LocationSource.gps,
        LocationSource.manual,
        LocationSource.network,
      ]);
    });

    test('FarmLocation toJson serialization', () {
      final farmLocation = FarmLocation.create(
        farmId: 'farm111',
        latitude: 7.8,
        longitude: 36.2,
        address: 'Test Address',
        woredaId: 'woreda222',
        registeredAt: DateTime(2024, 4, 1, 8, 0),
        source: LocationSource.gps,
      );

      final json = farmLocation.toJson();

      expect(json['farm_id'], 'farm111');
      expect(json['latitude'], 7.8);
      expect(json['longitude'], 36.2);
      expect(json['address'], 'Test Address');
      expect(json['woreda_id'], 'woreda222');
      expect(json['registered_at'], '2024-04-01T08:00:00.000');
      expect(json['source'], 'gps');
    });

    test('FarmLocation fromJson deserialization', () {
      final json = {
        'farm_id': 'farm333',
        'latitude': 12.5,
        'longitude': 42.8,
        'address': 'Test Location',
        'woreda_id': 'woreda444',
        'registered_at': '2024-05-15T16:30:00.000',
        'source': 'manual',
      };

      final farmLocation = FarmLocation.fromJson(json);

      expect(farmLocation.farmId, 'farm333');
      expect(farmLocation.latitude, 12.5);
      expect(farmLocation.longitude, 42.8);
      expect(farmLocation.address, 'Test Location');
      expect(farmLocation.woredaId, 'woreda444');
      expect(farmLocation.registeredAt, DateTime(2024, 5, 15, 16, 30));
      expect(farmLocation.source, LocationSource.manual);
    });

    test('FarmLocation fromJson with null address', () {
      final json = {
        'farm_id': 'farm555',
        'latitude': 6.5,
        'longitude': 37.0,
        'address': null,
        'woreda_id': 'woreda666',
        'registered_at': '2024-06-01T12:00:00.000',
        'source': 'network',
      };

      final farmLocation = FarmLocation.fromJson(json);

      expect(farmLocation.farmId, 'farm555');
      expect(farmLocation.address, null);
      expect(farmLocation.source, LocationSource.network);
    });

    test('FarmLocation fromCoordinate factory', () {
      final coordinate = LocationCoordinate(
        latitude: 11.2,
        longitude: 43.5,
        timestamp: DateTime(2024, 7, 1, 10, 0),
      );

      final farmLocation = FarmLocation.fromCoordinate(
        farmId: 'farm777',
        coordinate: coordinate,
        address: 'From Coordinate',
        woredaId: 'woreda888',
        source: LocationSource.gps,
      );

      expect(farmLocation.farmId, 'farm777');
      expect(farmLocation.latitude, 11.2);
      expect(farmLocation.longitude, 43.5);
      expect(farmLocation.address, 'From Coordinate');
      expect(farmLocation.woredaId, 'woreda888');
      expect(farmLocation.source, LocationSource.gps);
    });

    test('FarmLocation toJson/fromJson round trip', () {
      final original = FarmLocation.create(
        farmId: 'farm999',
        latitude: 9.5,
        longitude: 38.5,
        address: 'Round Trip Test',
        woredaId: 'woreda000',
        registeredAt: DateTime(2024, 8, 1, 9, 30),
        source: LocationSource.manual,
      );

      final json = original.toJson();
      final restored = FarmLocation.fromJson(json);

      expect(restored.farmId, original.farmId);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.address, original.address);
      expect(restored.woredaId, original.woredaId);
      expect(restored.registeredAt, original.registeredAt);
      expect(restored.source, original.source);
    });

    test('FarmLocation with invalid LocationSource falls back to manual', () {
      final json = {
        'farm_id': 'farm_invalid',
        'latitude': 8.0,
        'longitude': 39.0,
        'woreda_id': 'woreda_test',
        'registered_at': '2024-09-01T12:00:00.000',
        'source': 'invalid_source', // Invalid source
      };

      final farmLocation = FarmLocation.fromJson(json);

      // Should fall back to manual as per the orElse in fromJson
      expect(farmLocation.source, LocationSource.manual);
    });
  });
}
