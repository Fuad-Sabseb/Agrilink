import 'package:hive/hive.dart';

part 'farmer_model.g.dart';

/// Farmer Profile Model
/// Represents a registered farmer in the system
@HiveType(typeId: 0)
class Farmer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String woreda;

  @HiveField(4)
  final String kebele;

  @HiveField(5)
  final String? cooperativeName;

  @HiveField(6)
  final DateTime registeredAt;

  @HiveField(7)
  final List<String> farmIds; // References to Farm models

  Farmer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.woreda,
    required this.kebele,
    this.cooperativeName,
    required this.registeredAt,
    this.farmIds = const [],
  });

  /// Create a copy with updated fields
  Farmer copyWith({
    String? name,
    String? phoneNumber,
    String? woreda,
    String? kebele,
    String? cooperativeName,
    List<String>? farmIds,
  }) {
    return Farmer(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      registeredAt: registeredAt,
      farmIds: farmIds ?? this.farmIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'woreda': woreda,
      'kebele': kebele,
      'cooperativeName': cooperativeName,
      'registeredAt': registeredAt.toIso8601String(),
      'farmIds': farmIds,
    };
  }

  /// Create from JSON
  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      woreda: json['woreda'] as String,
      kebele: json['kebele'] as String,
      cooperativeName: json['cooperativeName'] as String?,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      farmIds: (json['farmIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
