import 'package:hive/hive.dart';

part 'produce_model.g.dart';

/// Produce Model - Represents agricultural produce listed by farmers
/// Status: available, reserved, sold, expired
@HiveType(typeId: 1)
class ProduceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String farmerId;

  @HiveField(2)
  final String farmerName;

  @HiveField(3)
  final String cropName;

  @HiveField(4)
  final String cropType; // grain, vegetable, fruit, legume, spice

  @HiveField(5)
  final double quantity;

  @HiveField(6)
  final String unit; // kg, quintal, ton, bag, liter

  @HiveField(7)
  final double pricePerUnit;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final String status; // available, reserved, sold, expired

  @HiveField(10)
  final String? qualityGrade; // A, B, C

  @HiveField(11)
  final DateTime? harvestDate;

  @HiveField(12)
  final String location; // City or Woreda

  @HiveField(13)
  final String? imageUrl;

  @HiveField(14)
  final List<String>? imageUrls; // Multiple images

  @HiveField(15)
  final bool isOrganic;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime? updatedAt;

  ProduceModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropName,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.description,
    required this.status,
    this.qualityGrade,
    this.harvestDate,
    required this.location,
    this.imageUrl,
    this.imageUrls,
    this.isOrganic = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calculate total value
  double get totalValue => quantity * pricePerUnit;

  /// Check if produce is available for purchase
  bool get isAvailable => status == 'available' && quantity > 0;

  /// Check if harvest is recent (within 30 days)
  bool get isRecentHarvest {
    if (harvestDate == null) return false;
    return DateTime.now().difference(harvestDate!).inDays <= 30;
  }

  /// Create a copy with updated fields
  ProduceModel copyWith({
    String? farmerId,
    String? farmerName,
    String? cropName,
    String? cropType,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    String? description,
    String? status,
    String? qualityGrade,
    DateTime? harvestDate,
    String? location,
    String? imageUrl,
    List<String>? imageUrls,
    bool? isOrganic,
    DateTime? updatedAt,
  }) {
    return ProduceModel(
      id: id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      cropName: cropName ?? this.cropName,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      description: description ?? this.description,
      status: status ?? this.status,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      harvestDate: harvestDate ?? this.harvestDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isOrganic: isOrganic ?? this.isOrganic,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropName': cropName,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'status': status,
      'qualityGrade': qualityGrade,
      'harvestDate': harvestDate?.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'isOrganic': isOrganic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ProduceModel.fromJson(Map<String, dynamic> json) {
    return ProduceModel(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      cropName: json['cropName'] as String,
      cropType: json['cropType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      description: json['description'] as String,
      status: json['status'] as String,
      qualityGrade: json['qualityGrade'] as String?,
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'] as String)
          : null,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isOrganic: json['isOrganic'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
