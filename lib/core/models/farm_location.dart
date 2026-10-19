import 'package:hive/hive.dart';
import 'location_coordinate.dart';

part 'farm_location.g.dart';

@HiveType(typeId: 13)
class FarmLocation extends HiveObject {
  @HiveField(0)
  final String farmId;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String woredaId;

  @HiveField(5)
  final DateTime registeredAt;

  @HiveField(6)
  final int sourceIndex;

  FarmLocation({
    required this.farmId,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.woredaId,
    required this.registeredAt,
    required this.sourceIndex,
  });

  factory FarmLocation.create({
    required String farmId,
    required double latitude,
    required double longitude,
    String? address,
    required String woredaId,
    required DateTime registeredAt,
    required LocationSource source,
  }) {
    return FarmLocation(
      farmId: farmId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      woredaId: woredaId,
      registeredAt: registeredAt,
      sourceIndex: source.index,
    );
  }

  LocationCoordinate get coordinate => LocationCoordinate(
        latitude: latitude,
        longitude: longitude,
        timestamp: registeredAt,
      );

  LocationSource get source => LocationSource.values[sourceIndex];

  Map<String, dynamic> toJson() => {
        'farm_id': farmId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'woreda_id': woredaId,
        'registered_at': registeredAt.toIso8601String(),
        'source': source.name,
      };

  factory FarmLocation.fromJson(Map<String, dynamic> json) {
    return FarmLocation.create(
      farmId: json['farm_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      woredaId: json['woreda_id'] as String,
      registeredAt: DateTime.parse(json['registered_at'] as String),
      source: LocationSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => LocationSource.manual,
      ),
    );
  }

  factory FarmLocation.fromCoordinate({
    required String farmId,
    required LocationCoordinate coordinate,
    String? address,
    required String woredaId,
    required LocationSource source,
  }) {
    return FarmLocation.create(
      farmId: farmId,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      address: address,
      woredaId: woredaId,
      registeredAt: DateTime.now(),
      source: source,
    );
  }
}

@HiveType(typeId: 17)
enum LocationSource {
  @HiveField(0)
  gps,
  @HiveField(1)
  manual,
  @HiveField(2)
  network,
}
