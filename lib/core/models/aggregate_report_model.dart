import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'aggregate_report_model.g.dart';

/// Aggregate Report Model
/// Represents aggregated crop data at woreda/zone level
@HiveType(typeId: 31)
class AggregateReport {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String woredaId;

  @HiveField(2)
  final String woredaName;

  @HiveField(3)
  final String? zoneId;

  @HiveField(4)
  final String? zoneName;

  @HiveField(5)
  final DateTime reportDate;

  @HiveField(6)
  final ReportPeriod period; // Weekly, Monthly, Seasonal

  @HiveField(7)
  final List<CropVolumeData> cropVolumes;

  @HiveField(8)
  final int totalFarms;

  @HiveField(9)
  final int activeCooperatives;

  @HiveField(10)
  final double totalHectares;

  @HiveField(11)
  final int totalFarmers;

  @HiveField(12)
  final String generatedBy; // Officer ID

  @HiveField(13)
  final String generatedByName;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final Map<String, dynamic>? metadata; // Additional flexible data

  AggregateReport({
    required this.id,
    required this.woredaId,
    required this.woredaName,
    this.zoneId,
    this.zoneName,
    required this.reportDate,
    required this.period,
    required this.cropVolumes,
    required this.totalFarms,
    required this.activeCooperatives,
    required this.totalHectares,
    required this.totalFarmers,
    required this.generatedBy,
    required this.generatedByName,
    this.notes,
    this.metadata,
  });

  /// Total expected harvest across all crops (kg)
  double get totalExpectedHarvest {
    return cropVolumes.fold(0.0, (sum, crop) => sum + crop.expectedVolume);
  }

  /// Total actual harvest across all crops (kg)
  double get totalActualHarvest {
    return cropVolumes.fold(0.0, (sum, crop) => sum + (crop.actualVolume ?? 0));
  }

  /// Average yield per hectare (kg/ha)
  double get averageYieldPerHectare {
    if (totalHectares == 0) return 0;
    return totalActualHarvest / totalHectares;
  }

  /// Harvest completion rate (percentage)
  double get harvestCompletionRate {
    if (totalExpectedHarvest == 0) return 0;
    return (totalActualHarvest / totalExpectedHarvest) * 100;
  }

  /// Get volume data for a specific crop
  CropVolumeData? getCropVolume(CropType cropType) {
    try {
      return cropVolumes.firstWhere((c) => c.cropType == cropType);
    } catch (e) {
      return null;
    }
  }

  /// Create a copy with updated fields
  AggregateReport copyWith({
    DateTime? reportDate,
    List<CropVolumeData>? cropVolumes,
    int? totalFarms,
    int? activeCooperatives,
    double? totalHectares,
    int? totalFarmers,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return AggregateReport(
      id: id,
      woredaId: woredaId,
      woredaName: woredaName,
      zoneId: zoneId,
      zoneName: zoneName,
      reportDate: reportDate ?? this.reportDate,
      period: period,
      cropVolumes: cropVolumes ?? this.cropVolumes,
      totalFarms: totalFarms ?? this.totalFarms,
      activeCooperatives: activeCooperatives ?? this.activeCooperatives,
      totalHectares: totalHectares ?? this.totalHectares,
      totalFarmers: totalFarmers ?? this.totalFarmers,
      generatedBy: generatedBy,
      generatedByName: generatedByName,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'woredaId': woredaId,
      'woredaName': woredaName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'reportDate': reportDate.toIso8601String(),
      'period': period.name,
      'cropVolumes': cropVolumes.map((c) => c.toJson()).toList(),
      'totalFarms': totalFarms,
      'activeCooperatives': activeCooperatives,
      'totalHectares': totalHectares,
      'totalFarmers': totalFarmers,
      'generatedBy': generatedBy,
      'generatedByName': generatedByName,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory AggregateReport.fromJson(Map<String, dynamic> json) {
    return AggregateReport(
      id: json['id'] as String,
      woredaId: json['woredaId'] as String,
      woredaName: json['woredaName'] as String,
      zoneId: json['zoneId'] as String?,
      zoneName: json['zoneName'] as String?,
      reportDate: DateTime.parse(json['reportDate'] as String),
      period: ReportPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => ReportPeriod.monthly,
      ),
      cropVolumes: (json['cropVolumes'] as List)
          .map((c) => CropVolumeData.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalFarms: json['totalFarms'] as int,
      activeCooperatives: json['activeCooperatives'] as int,
      totalHectares: (json['totalHectares'] as num).toDouble(),
      totalFarmers: json['totalFarmers'] as int,
      generatedBy: json['generatedBy'] as String,
      generatedByName: json['generatedByName'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Crop Volume Data
/// Aggregated volume data for a specific crop type
@HiveType(typeId: 32)
class CropVolumeData {
  @HiveField(0)
  final CropType cropType;

  @HiveField(1)
  final double hectares;

  @HiveField(2)
  final double expectedVolume; // kg

  @HiveField(3)
  final double? actualVolume; // kg (null if harvest not started)

  @HiveField(4)
  final int farmCount;

  @HiveField(5)
  final QualityGrade? averageGrade;

  @HiveField(6)
  final double? averagePrice; // ETB per kg

  @HiveField(7)
  final HarvestStatus harvestStatus;

  @HiveField(8)
  final DateTime? estimatedHarvestDate;

  CropVolumeData({
    required this.cropType,
    required this.hectares,
    required this.expectedVolume,
    this.actualVolume,
    required this.farmCount,
    this.averageGrade,
    this.averagePrice,
    this.harvestStatus = HarvestStatus.preHarvest,
    this.estimatedHarvestDate,
  });

  /// Yield per hectare (kg/ha)
  double get yieldPerHectare {
    if (hectares == 0) return 0;
    return (actualVolume ?? expectedVolume) / hectares;
  }

  /// Harvest achievement rate (percentage)
  double? get harvestAchievementRate {
    if (actualVolume == null || expectedVolume == 0) return null;
    return (actualVolume! / expectedVolume) * 100;
  }

  /// Estimated total value (ETB)
  double? get estimatedValue {
    if (averagePrice == null) return null;
    return (actualVolume ?? expectedVolume) * averagePrice!;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType.name,
      'hectares': hectares,
      'expectedVolume': expectedVolume,
      'actualVolume': actualVolume,
      'farmCount': farmCount,
      'averageGrade': averageGrade?.name,
      'averagePrice': averagePrice,
      'harvestStatus': harvestStatus.name,
      'estimatedHarvestDate': estimatedHarvestDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CropVolumeData.fromJson(Map<String, dynamic> json) {
    return CropVolumeData(
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      hectares: (json['hectares'] as num).toDouble(),
      expectedVolume: (json['expectedVolume'] as num).toDouble(),
      actualVolume: json['actualVolume'] != null
          ? (json['actualVolume'] as num).toDouble()
          : null,
      farmCount: json['farmCount'] as int,
      averageGrade: json['averageGrade'] != null
          ? QualityGrade.values.firstWhere(
              (e) => e.name == json['averageGrade'],
              orElse: () => QualityGrade.standard,
            )
          : null,
      averagePrice: json['averagePrice'] != null
          ? (json['averagePrice'] as num).toDouble()
          : null,
      harvestStatus: HarvestStatus.values.firstWhere(
        (e) => e.name == json['harvestStatus'],
        orElse: () => HarvestStatus.preHarvest,
      ),
      estimatedHarvestDate: json['estimatedHarvestDate'] != null
          ? DateTime.parse(json['estimatedHarvestDate'] as String)
          : null,
    );
  }
}

/// Report Period Enum
@HiveType(typeId: 33)
enum ReportPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  quarterly,
  @HiveField(3)
  seasonal,
  @HiveField(4)
  annual,
}

/// Harvest Status Enum
@HiveType(typeId: 34)
enum HarvestStatus {
  @HiveField(0)
  preHarvest,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  delayed,
}

/// Extension for report period display
extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.quarterly:
        return 'Quarterly';
      case ReportPeriod.seasonal:
        return 'Seasonal';
      case ReportPeriod.annual:
        return 'Annual';
    }
  }
}

/// Extension for harvest status display
extension HarvestStatusExtension on HarvestStatus {
  String get displayName {
    switch (this) {
      case HarvestStatus.preHarvest:
        return 'Pre-Harvest';
      case HarvestStatus.inProgress:
        return 'In Progress';
      case HarvestStatus.completed:
        return 'Completed';
      case HarvestStatus.delayed:
        return 'Delayed';
    }
  }
}
