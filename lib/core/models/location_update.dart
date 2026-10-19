import 'package:hive/hive.dart';
import 'location_coordinate.dart';

part 'location_update.g.dart';

@HiveType(typeId: 10)
class LocationUpdate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transportTripId;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool synced;

  LocationUpdate({
    required this.id,
    required this.transportTripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.synced = false,
  });

  LocationCoordinate get coordinate => LocationCoordinate(
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'transport_trip_id': transportTripId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      id: json['id'] as String,
      transportTripId: json['transport_trip_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  factory LocationUpdate.fromCoordinate({
    required String id,
    required String transportTripId,
    required LocationCoordinate coordinate,
    bool synced = false,
  }) {
    return LocationUpdate(
      id: id,
      transportTripId: transportTripId,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      timestamp: coordinate.timestamp,
      synced: synced,
    );
  }

  LocationUpdate copyWith({
    String? id,
    String? transportTripId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? synced,
  }) {
    return LocationUpdate(
      id: id ?? this.id,
      transportTripId: transportTripId ?? this.transportTripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }
}
