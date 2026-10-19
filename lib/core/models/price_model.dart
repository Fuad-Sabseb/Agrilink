import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'price_model.g.dart';

/// Price Model
/// Represents current market price for a specific crop and grade
@HiveType(typeId: 4)
class CropPrice {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String marketId;

  @HiveField(2)
  final CropType cropType;

  @HiveField(3)
  final QualityGrade grade;

  @HiveField(4)
  final double pricePerKg; // ETB per kg

  @HiveField(5)
  final DateTime recordedAt;

  @HiveField(6)
  final String source; // 'field_collection', 'ecx', 'manual', etc.

  @HiveField(7)
  final double? priceChangePercent; // vs. previous day

  CropPrice({
    required this.id,
    required this.marketId,
    required this.cropType,
    required this.grade,
    required this.pricePerKg,
    required this.recordedAt,
    required this.source,
    this.priceChangePercent,
  });

  /// Check if price is fresh (within 24 hours)
  bool get isFresh {
    final hoursSinceRecorded = DateTime.now().difference(recordedAt).inHours;
    return hoursSinceRecorded < 24;
  }

  /// Get age in hours
  int get ageInHours {
    return DateTime.now().difference(recordedAt).inHours;
  }

  /// Is price increasing
  bool get isIncreasing {
    return priceChangePercent != null && priceChangePercent! > 0;
  }

  /// Is price decreasing
  bool get isDecreasing {
    return priceChangePercent != null && priceChangePercent! < 0;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marketId': marketId,
      'cropType': cropType.name,
      'grade': grade.name,
      'pricePerKg': pricePerKg,
      'recordedAt': recordedAt.toIso8601String(),
      'source': source,
      'priceChangePercent': priceChangePercent,
    };
  }

  /// Create from JSON
  factory CropPrice.fromJson(Map<String, dynamic> json) {
    return CropPrice(
      id: json['id'] as String,
      marketId: json['marketId'] as String,
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      grade: QualityGrade.values.firstWhere(
        (e) => e.name == json['grade'],
        orElse: () => QualityGrade.standard,
      ),
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      source: json['source'] as String,
      priceChangePercent: json['priceChangePercent'] != null
          ? (json['priceChangePercent'] as num).toDouble()
          : null,
    );
  }
}
