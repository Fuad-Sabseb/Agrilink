import 'package:hive/hive.dart';

part 'crop_plot_model.g.dart';

/// Crop Type Enum
@HiveType(typeId: 10)
enum CropType {
  @HiveField(0)
  coffee,
  @HiveField(1)
  maize,
  @HiveField(2)
  teff,
  @HiveField(3)
  wheat,
  @HiveField(4)
  potato,
  @HiveField(5)
  sorghum,
  @HiveField(6)
  barley,
  @HiveField(7)
  beans,
  @HiveField(8)
  other,
}

/// Quality Grade Enum
@HiveType(typeId: 11)
enum QualityGrade {
  @HiveField(0)
  premium,
  @HiveField(1)
  grade1,
  @HiveField(2)
  grade2,
  @HiveField(3)
  grade3,
  @HiveField(4)
  standard,
}

/// Crop Plot Model
/// Represents a crop plot within a farm
@HiveType(typeId: 2)
class CropPlot {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CropType cropType;

  @HiveField(2)
  final double hectares;

  @HiveField(3)
  final QualityGrade expectedGrade;

  @HiveField(4)
  final double expectedYieldPerHectare; // kg/hectare

  @HiveField(5)
  final DateTime plantingDate;

  @HiveField(6)
  final DateTime expectedHarvestDate;

  @HiveField(7)
  final String? notes;

  CropPlot({
    required this.id,
    required this.cropType,
    required this.hectares,
    required this.expectedGrade,
    required this.expectedYieldPerHectare,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.notes,
  });

  /// Calculate total expected harvest
  double get expectedTotalHarvest {
    return hectares * expectedYieldPerHectare;
  }

  /// Check if harvest is ready
  bool get isHarvestReady {
    return DateTime.now().isAfter(expectedHarvestDate);
  }

  /// Days until harvest
  int get daysUntilHarvest {
    return expectedHarvestDate.difference(DateTime.now()).inDays;
  }

  /// Create a copy with updated fields
  CropPlot copyWith({
    CropType? cropType,
    double? hectares,
    QualityGrade? expectedGrade,
    double? expectedYieldPerHectare,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    String? notes,
  }) {
    return CropPlot(
      id: id,
      cropType: cropType ?? this.cropType,
      hectares: hectares ?? this.hectares,
      expectedGrade: expectedGrade ?? this.expectedGrade,
      expectedYieldPerHectare:
          expectedYieldPerHectare ?? this.expectedYieldPerHectare,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropType': cropType.name,
      'hectares': hectares,
      'expectedGrade': expectedGrade.name,
      'expectedYieldPerHectare': expectedYieldPerHectare,
      'plantingDate': plantingDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from JSON
  factory CropPlot.fromJson(Map<String, dynamic> json) {
    return CropPlot(
      id: json['id'] as String,
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      hectares: (json['hectares'] as num).toDouble(),
      expectedGrade: QualityGrade.values.firstWhere(
        (e) => e.name == json['expectedGrade'],
        orElse: () => QualityGrade.standard,
      ),
      expectedYieldPerHectare:
          (json['expectedYieldPerHectare'] as num).toDouble(),
      plantingDate: DateTime.parse(json['plantingDate'] as String),
      expectedHarvestDate:
          DateTime.parse(json['expectedHarvestDate'] as String),
      notes: json['notes'] as String?,
    );
  }
}

/// Extension for crop type display names
extension CropTypeExtension on CropType {
  String get displayName {
    switch (this) {
      case CropType.coffee:
        return 'Coffee';
      case CropType.maize:
        return 'Maize';
      case CropType.teff:
        return 'Teff';
      case CropType.wheat:
        return 'Wheat';
      case CropType.potato:
        return 'Potato';
      case CropType.sorghum:
        return 'Sorghum';
      case CropType.barley:
        return 'Barley';
      case CropType.beans:
        return 'Beans';
      case CropType.other:
        return 'Other';
    }
  }

  String get afaanOromoo {
    switch (this) {
      case CropType.coffee:
        return 'Buna';
      case CropType.maize:
        return 'Boqqoo';
      case CropType.teff:
        return 'Xaafii';
      case CropType.wheat:
        return 'Qamadii';
      case CropType.potato:
        return 'Dinnichii';
      case CropType.sorghum:
        return 'Maskee';
      case CropType.barley:
        return 'Garbuu';
      case CropType.beans:
        return 'Aatarii';
      case CropType.other:
        return 'Kan Biraa';
    }
  }
}

/// Extension for quality grade display names
extension QualityGradeExtension on QualityGrade {
  String get displayName {
    switch (this) {
      case QualityGrade.premium:
        return 'Premium';
      case QualityGrade.grade1:
        return 'Grade 1';
      case QualityGrade.grade2:
        return 'Grade 2';
      case QualityGrade.grade3:
        return 'Grade 3';
      case QualityGrade.standard:
        return 'Standard';
    }
  }

  String get afaanOromoo {
    switch (this) {
      case QualityGrade.premium:
        return 'Olaanaa';
      case QualityGrade.grade1:
        return 'Sadarkaa 1';
      case QualityGrade.grade2:
        return 'Sadarkaa 2';
      case QualityGrade.grade3:
        return 'Sadarkaa 3';
      case QualityGrade.standard:
        return 'Waliigalaa';
    }
  }
}
