import 'package:hive/hive.dart';

part 'market_model.g.dart';

/// Market Model
/// Represents a physical market location
@HiveType(typeId: 3)
class Market {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String woreda;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final bool isPrimary; // Jimma Town = true, secondary markets = false

  @HiveField(6)
  final double distanceFromJimmaKm;

  Market({
    required this.id,
    required this.name,
    required this.woreda,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
    required this.distanceFromJimmaKm,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'woreda': woreda,
      'latitude': latitude,
      'longitude': longitude,
      'isPrimary': isPrimary,
      'distanceFromJimmaKm': distanceFromJimmaKm,
    };
  }

  /// Create from JSON
  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] as String,
      name: json['name'] as String,
      woreda: json['woreda'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isPrimary: json['isPrimary'] as bool,
      distanceFromJimmaKm: (json['distanceFromJimmaKm'] as num).toDouble(),
    );
  }
}
