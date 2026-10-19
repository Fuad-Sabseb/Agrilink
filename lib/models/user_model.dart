import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String password; // Always empty for security

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final DateTime createdAt;

  // Phase 2: New fields
  @HiveField(7)
  final String? email;

  @HiveField(8)
  final String? woreda;

  @HiveField(9)
  final String? kebele;

  @HiveField(10)
  final String? cooperativeName;

  @HiveField(11)
  final bool isVerified;

  @HiveField(12)
  final DateTime? lastLoginAt;

  @HiveField(13)
  final Map<String, dynamic>? roleData;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.role,
    required this.location,
    required this.createdAt,
    this.email,
    this.woreda,
    this.kebele,
    this.cooperativeName,
    this.isVerified = false,
    this.lastLoginAt,
    this.roleData,
  });

  /// Create UserModel from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      password: '', // Never store password
      role: json['role'] as String,
      location: json['location'] as String? ?? 'Not specified',
      createdAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : DateTime.now(),
      email: json['email'] as String?,
      woreda: json['woreda'] as String?,
      kebele: json['kebele'] as String?,
      cooperativeName: json['cooperativeName'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      roleData: json['roleData'] as Map<String, dynamic>?,
    );
  }

  /// Convert UserModel to JSON (for storage/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'location': location,
      'registeredAt': createdAt.toIso8601String(),
      if (email != null) 'email': email,
      if (woreda != null) 'woreda': woreda,
      if (kebele != null) 'kebele': kebele,
      if (cooperativeName != null) 'cooperativeName': cooperativeName,
      'isVerified': isVerified,
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (roleData != null) 'roleData': roleData,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? role,
    String? location,
    DateTime? createdAt,
    String? email,
    String? woreda,
    String? kebele,
    String? cooperativeName,
    bool? isVerified,
    DateTime? lastLoginAt,
    Map<String, dynamic>? roleData,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      password: '', // Always empty
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      isVerified: isVerified ?? this.isVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      roleData: roleData ?? this.roleData,
    );
  }
}
