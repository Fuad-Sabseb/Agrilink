import 'package:hive/hive.dart';

part 'bureau_officer_model.g.dart';

/// Bureau Officer Model
/// Represents a government agricultural bureau officer
@HiveType(typeId: 24)
class BureauOfficer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String employeeId;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final OfficerRank rank;

  @HiveField(6)
  final String bureauName; // e.g., "Jimma Zone Agricultural Bureau"

  @HiveField(7)
  final List<String> assignedWoredas; // List of woreda IDs/names

  @HiveField(8)
  final String? profileImageUrl;

  @HiveField(9)
  final DateTime joinDate;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final String? specialization; // e.g., "Coffee Production", "Livestock"

  @HiveField(12)
  final int completedInspections;

  @HiveField(13)
  final DateTime? lastInspectionDate;

  BureauOfficer({
    required this.id,
    required this.fullName,
    required this.employeeId,
    required this.phoneNumber,
    required this.email,
    required this.rank,
    required this.bureauName,
    required this.assignedWoredas,
    this.profileImageUrl,
    required this.joinDate,
    this.isActive = true,
    this.specialization,
    this.completedInspections = 0,
    this.lastInspectionDate,
  });

  /// Years of service
  int get yearsOfService {
    return DateTime.now().difference(joinDate).inDays ~/ 365;
  }

  /// Check if officer covers a specific woreda
  bool coversWoreda(String woredaId) {
    return assignedWoredas.contains(woredaId);
  }

  /// Create a copy with updated fields
  BureauOfficer copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    OfficerRank? rank,
    String? bureauName,
    List<String>? assignedWoredas,
    String? profileImageUrl,
    bool? isActive,
    String? specialization,
    int? completedInspections,
    DateTime? lastInspectionDate,
  }) {
    return BureauOfficer(
      id: id,
      fullName: fullName ?? this.fullName,
      employeeId: employeeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      rank: rank ?? this.rank,
      bureauName: bureauName ?? this.bureauName,
      assignedWoredas: assignedWoredas ?? this.assignedWoredas,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      joinDate: joinDate,
      isActive: isActive ?? this.isActive,
      specialization: specialization ?? this.specialization,
      completedInspections: completedInspections ?? this.completedInspections,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'employeeId': employeeId,
      'phoneNumber': phoneNumber,
      'email': email,
      'rank': rank.name,
      'bureauName': bureauName,
      'assignedWoredas': assignedWoredas,
      'profileImageUrl': profileImageUrl,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'specialization': specialization,
      'completedInspections': completedInspections,
      'lastInspectionDate': lastInspectionDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory BureauOfficer.fromJson(Map<String, dynamic> json) {
    return BureauOfficer(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      employeeId: json['employeeId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      rank: OfficerRank.values.firstWhere(
        (e) => e.name == json['rank'],
        orElse: () => OfficerRank.fieldOfficer,
      ),
      bureauName: json['bureauName'] as String,
      assignedWoredas: List<String>.from(json['assignedWoredas'] as List),
      profileImageUrl: json['profileImageUrl'] as String?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      specialization: json['specialization'] as String?,
      completedInspections: json['completedInspections'] as int? ?? 0,
      lastInspectionDate: json['lastInspectionDate'] != null
          ? DateTime.parse(json['lastInspectionDate'] as String)
          : null,
    );
  }
}

/// Officer Rank Enum
@HiveType(typeId: 25)
enum OfficerRank {
  @HiveField(0)
  fieldOfficer,
  @HiveField(1)
  seniorOfficer,
  @HiveField(2)
  supervisor,
  @HiveField(3)
  coordinator,
  @HiveField(4)
  director,
}

/// Extension for officer rank display
extension OfficerRankExtension on OfficerRank {
  String get displayName {
    switch (this) {
      case OfficerRank.fieldOfficer:
        return 'Field Officer';
      case OfficerRank.seniorOfficer:
        return 'Senior Officer';
      case OfficerRank.supervisor:
        return 'Supervisor';
      case OfficerRank.coordinator:
        return 'Coordinator';
      case OfficerRank.director:
        return 'Director';
    }
  }

  String get afaanOromoo {
    switch (this) {
      case OfficerRank.fieldOfficer:
        return 'Ogeessa Dirree';
      case OfficerRank.seniorOfficer:
        return 'Ogeessa Ol\'aanaa';
      case OfficerRank.supervisor:
        return 'To\'ataa';
      case OfficerRank.coordinator:
        return 'Qindeessaa';
      case OfficerRank.director:
        return 'Daayireektara';
    }
  }
}
