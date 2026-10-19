import 'package:hive/hive.dart';

part 'inspection_model.g.dart';

/// Inspection Model
/// Represents a cooperative or farm inspection check-in
@HiveType(typeId: 26)
class Inspection {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String officerId; // Bureau officer conducting inspection

  @HiveField(2)
  final String officerName;

  @HiveField(3)
  final InspectionType type;

  @HiveField(4)
  final String? cooperativeId;

  @HiveField(5)
  final String? cooperativeName;

  @HiveField(6)
  final String? farmId;

  @HiveField(7)
  final String? farmName;

  @HiveField(8)
  final String woredaId;

  @HiveField(9)
  final String woredaName;

  @HiveField(10)
  final DateTime checkInTime;

  @HiveField(11)
  final DateTime? checkOutTime;

  @HiveField(12)
  final InspectionStatus status;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  final List<InspectionFinding> findings;

  @HiveField(15)
  final double? latitude;

  @HiveField(16)
  final double? longitude;

  @HiveField(17)
  final List<String> photoUrls;

  @HiveField(18)
  final String? signature; // Base64 encoded signature

  @HiveField(19)
  final int farmersInterviewed;

  @HiveField(20)
  final double? estimatedCropVolume; // In kg

  Inspection({
    required this.id,
    required this.officerId,
    required this.officerName,
    required this.type,
    this.cooperativeId,
    this.cooperativeName,
    this.farmId,
    this.farmName,
    required this.woredaId,
    required this.woredaName,
    required this.checkInTime,
    this.checkOutTime,
    this.status = InspectionStatus.inProgress,
    this.notes,
    this.findings = const [],
    this.latitude,
    this.longitude,
    this.photoUrls = const [],
    this.signature,
    this.farmersInterviewed = 0,
    this.estimatedCropVolume,
  });

  /// Duration of inspection
  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  /// Format duration as hours and minutes
  String? get formattedDuration {
    final dur = duration;
    if (dur == null) return null;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Check if inspection is complete
  bool get isComplete => status == InspectionStatus.completed;

  /// Check if inspection is in progress
  bool get isInProgress => status == InspectionStatus.inProgress;

  /// Count of issues found
  int get issueCount {
    return findings
        .where((f) => f.severity == FindingSeverity.critical ||
            f.severity == FindingSeverity.major)
        .length;
  }

  /// Create a copy with updated fields
  Inspection copyWith({
    DateTime? checkOutTime,
    InspectionStatus? status,
    String? notes,
    List<InspectionFinding>? findings,
    double? latitude,
    double? longitude,
    List<String>? photoUrls,
    String? signature,
    int? farmersInterviewed,
    double? estimatedCropVolume,
  }) {
    return Inspection(
      id: id,
      officerId: officerId,
      officerName: officerName,
      type: type,
      cooperativeId: cooperativeId,
      cooperativeName: cooperativeName,
      farmId: farmId,
      farmName: farmName,
      woredaId: woredaId,
      woredaName: woredaName,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      findings: findings ?? this.findings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrls: photoUrls ?? this.photoUrls,
      signature: signature ?? this.signature,
      farmersInterviewed: farmersInterviewed ?? this.farmersInterviewed,
      estimatedCropVolume: estimatedCropVolume ?? this.estimatedCropVolume,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officerId': officerId,
      'officerName': officerName,
      'type': type.name,
      'cooperativeId': cooperativeId,
      'cooperativeName': cooperativeName,
      'farmId': farmId,
      'farmName': farmName,
      'woredaId': woredaId,
      'woredaName': woredaName,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'findings': findings.map((f) => f.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
      'signature': signature,
      'farmersInterviewed': farmersInterviewed,
      'estimatedCropVolume': estimatedCropVolume,
    };
  }

  /// Create from JSON
  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] as String,
      officerId: json['officerId'] as String,
      officerName: json['officerName'] as String,
      type: InspectionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InspectionType.routine,
      ),
      cooperativeId: json['cooperativeId'] as String?,
      cooperativeName: json['cooperativeName'] as String?,
      farmId: json['farmId'] as String?,
      farmName: json['farmName'] as String?,
      woredaId: json['woredaId'] as String,
      woredaName: json['woredaName'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      status: InspectionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InspectionStatus.inProgress,
      ),
      notes: json['notes'] as String?,
      findings: (json['findings'] as List?)
              ?.map((f) => InspectionFinding.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? []),
      signature: json['signature'] as String?,
      farmersInterviewed: json['farmersInterviewed'] as int? ?? 0,
      estimatedCropVolume: json['estimatedCropVolume'] as double?,
    );
  }
}

/// Inspection Finding
/// Represents an observation or issue found during inspection
@HiveType(typeId: 27)
class InspectionFinding {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category; // e.g., "Crop Quality", "Storage", "Documentation"

  @HiveField(2)
  final String description;

  @HiveField(3)
  final FindingSeverity severity;

  @HiveField(4)
  final String? recommendation;

  @HiveField(5)
  final DateTime timestamp;

  InspectionFinding({
    required this.id,
    required this.category,
    required this.description,
    required this.severity,
    this.recommendation,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'severity': severity.name,
      'recommendation': recommendation,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory InspectionFinding.fromJson(Map<String, dynamic> json) {
    return InspectionFinding(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      severity: FindingSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => FindingSeverity.minor,
      ),
      recommendation: json['recommendation'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Inspection Type Enum
@HiveType(typeId: 28)
enum InspectionType {
  @HiveField(0)
  routine,
  @HiveField(1)
  followUp,
  @HiveField(2)
  complaint,
  @HiveField(3)
  preHarvest,
  @HiveField(4)
  postHarvest,
  @HiveField(5)
  emergency,
}

/// Inspection Status Enum
@HiveType(typeId: 29)
enum InspectionStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

/// Finding Severity Enum
@HiveType(typeId: 30)
enum FindingSeverity {
  @HiveField(0)
  minor,
  @HiveField(1)
  moderate,
  @HiveField(2)
  major,
  @HiveField(3)
  critical,
}

/// Extension for inspection type display
extension InspectionTypeExtension on InspectionType {
  String get displayName {
    switch (this) {
      case InspectionType.routine:
        return 'Routine Inspection';
      case InspectionType.followUp:
        return 'Follow-up Inspection';
      case InspectionType.complaint:
        return 'Complaint Investigation';
      case InspectionType.preHarvest:
        return 'Pre-Harvest Assessment';
      case InspectionType.postHarvest:
        return 'Post-Harvest Review';
      case InspectionType.emergency:
        return 'Emergency Inspection';
    }
  }
}

/// Extension for inspection status display
extension InspectionStatusExtension on InspectionStatus {
  String get displayName {
    switch (this) {
      case InspectionStatus.scheduled:
        return 'Scheduled';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Extension for finding severity display
extension FindingSeverityExtension on FindingSeverity {
  String get displayName {
    switch (this) {
      case FindingSeverity.minor:
        return 'Minor';
      case FindingSeverity.moderate:
        return 'Moderate';
      case FindingSeverity.major:
        return 'Major';
      case FindingSeverity.critical:
        return 'Critical';
    }
  }
}
