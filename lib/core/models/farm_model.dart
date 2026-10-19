import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'farm_model.g.dart';

/// Farm Model
/// Represents a farm with location and crop plots
@HiveType(typeId: 1)
class Farm {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String farmerId;

  @HiveField(2)
  final String farmName;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final double totalHectares;

  @HiveField(6)
  final String woreda;

  @HiveField(7)
  final String kebele;

  @HiveField(8)
  final List<CropPlot> cropPlots;

  @HiveField(9)
  final DateTime createdAt;

  Farm({
    required this.id,
    required this.farmerId,
    required this.farmName,
    required this.latitude,
    required this.longitude,
    required this.totalHectares,
    required this.woreda,
    required this.kebele,
    this.cropPlots = const [],
    required this.createdAt,
  });

  /// Calculate total cultivated hectares
  double get cultivatedHectares {
    return cropPlots.fold(0.0, (sum, plot) => sum + plot.hectares);
  }

  /// Calculate available hectares
  double get availableHectares {
    return totalHectares - cultivatedHectares;
  }

  /// Create a copy with updated fields
  Farm copyWith({
    String? farmName,
    double? latitude,
    double? longitude,
    double? totalHectares,
    String? woreda,
    String? kebele,
    List<CropPlot>? cropPlots,
  }) {
    return Farm(
      id: id,
      farmerId: farmerId,
      farmName: farmName ?? this.farmName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalHectares: totalHectares ?? this.totalHectares,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      cropPlots: cropPlots ?? this.cropPlots,
      createdAt: createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmName': farmName,
      'latitude': latitude,
      'longitude': longitude,
      'totalHectares': totalHectares,
      'woreda': woreda,
      'kebele': kebele,
      'cropPlots': cropPlots.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmName: json['farmName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      totalHectares: (json['totalHectares'] as num).toDouble(),
      woreda: json['woreda'] as String,
      kebele: json['kebele'] as String,
      cropPlots: (json['cropPlots'] as List<dynamic>?)
              ?.map((e) => CropPlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
