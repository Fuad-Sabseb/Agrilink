import 'package:hive/hive.dart';

part 'vehicle_model.g.dart';

/// Vehicle Model
/// Represents a transport vehicle with capacity and specifications
@HiveType(typeId: 8)
class Vehicle {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transporterId;

  @HiveField(2)
  final VehicleType vehicleType;

  @HiveField(3)
  final String plateNumber;

  @HiveField(4)
  final double capacityQuintals; // 1 quintal = 100 kg

  @HiveField(5)
  final String model; // e.g., "Isuzu NQR", "Toyota Hilux"

  @HiveField(6)
  final int? yearManufactured;

  @HiveField(7)
  final bool isActive; // Currently in service

  @HiveField(8)
  final VehicleCondition condition;

  @HiveField(9)
  final DateTime registeredAt;

  @HiveField(10)
  final DateTime? lastMaintenanceDate;

  @HiveField(11)
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.transporterId,
    required this.vehicleType,
    required this.plateNumber,
    required this.capacityQuintals,
    required this.model,
    this.yearManufactured,
    this.isActive = true,
    this.condition = VehicleCondition.good,
    required this.registeredAt,
    this.lastMaintenanceDate,
    this.imageUrl,
  });

  /// Get capacity in tons (1 ton = 10 quintals)
  double get capacityTons {
    return capacityQuintals / 10.0;
  }

  /// Get capacity in kilograms
  double get capacityKg {
    return capacityQuintals * 100.0;
  }

  /// Calculate vehicle age
  int? get vehicleAge {
    if (yearManufactured == null) return null;
    return DateTime.now().year - yearManufactured!;
  }

  /// Check if maintenance is due (> 3 months since last service)
  bool get isMaintenanceDue {
    if (lastMaintenanceDate == null) return true;
    final monthsSinceMaintenance =
        DateTime.now().difference(lastMaintenanceDate!).inDays ~/ 30;
    return monthsSinceMaintenance > 3;
  }

  /// Create a copy with updated fields
  Vehicle copyWith({
    VehicleType? vehicleType,
    String? plateNumber,
    double? capacityQuintals,
    String? model,
    int? yearManufactured,
    bool? isActive,
    VehicleCondition? condition,
    DateTime? lastMaintenanceDate,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id,
      transporterId: transporterId,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      capacityQuintals: capacityQuintals ?? this.capacityQuintals,
      model: model ?? this.model,
      yearManufactured: yearManufactured ?? this.yearManufactured,
      isActive: isActive ?? this.isActive,
      condition: condition ?? this.condition,
      registeredAt: registeredAt,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transporterId': transporterId,
      'vehicleType': vehicleType.name,
      'plateNumber': plateNumber,
      'capacityQuintals': capacityQuintals,
      'model': model,
      'yearManufactured': yearManufactured,
      'isActive': isActive,
      'condition': condition.name,
      'registeredAt': registeredAt.toIso8601String(),
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  /// Create from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      transporterId: json['transporterId'] as String,
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == json['vehicleType'],
        orElse: () => VehicleType.truck,
      ),
      plateNumber: json['plateNumber'] as String,
      capacityQuintals: (json['capacityQuintals'] as num).toDouble(),
      model: json['model'] as String,
      yearManufactured: json['yearManufactured'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      condition: VehicleCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => VehicleCondition.good,
      ),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Vehicle Type Enum
@HiveType(typeId: 14)
enum VehicleType {
  @HiveField(0)
  truck, // Large cargo truck (10+ tons)

  @HiveField(1)
  pickup, // Pickup truck (1-3 tons)

  @HiveField(2)
  miniTruck, // Small truck (3-7 tons)

  @HiveField(3)
  lorry, // Medium lorry (7-10 tons)
}

/// Vehicle Condition Enum
@HiveType(typeId: 15)
enum VehicleCondition {
  @HiveField(0)
  excellent,

  @HiveField(1)
  good,

  @HiveField(2)
  fair,

  @HiveField(3)
  needsMaintenance,
}

/// Extension for vehicle type display
extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.lorry:
        return 'Lorry';
    }
  }

  String get displayNameOm {
    switch (this) {
      case VehicleType.truck:
        return 'Konkolaataa Guddaa';
      case VehicleType.pickup:
        return 'Pikaappii';
      case VehicleType.miniTruck:
        return 'Konkolaataa Xixiqqaa';
      case VehicleType.lorry:
        return 'Loorii';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.truck:
        return '🚚';
      case VehicleType.pickup:
        return '🛻';
      case VehicleType.miniTruck:
        return '🚐';
      case VehicleType.lorry:
        return '🚛';
    }
  }

  /// Typical capacity range in quintals
  String get capacityRange {
    switch (this) {
      case VehicleType.truck:
        return '100-200 quintals';
      case VehicleType.pickup:
        return '10-30 quintals';
      case VehicleType.miniTruck:
        return '30-70 quintals';
      case VehicleType.lorry:
        return '70-100 quintals';
    }
  }
}

/// Extension for vehicle condition display
extension VehicleConditionExtension on VehicleCondition {
  String get displayName {
    switch (this) {
      case VehicleCondition.excellent:
        return 'Excellent';
      case VehicleCondition.good:
        return 'Good';
      case VehicleCondition.fair:
        return 'Fair';
      case VehicleCondition.needsMaintenance:
        return 'Needs Maintenance';
    }
  }

  String get color {
    switch (this) {
      case VehicleCondition.excellent:
        return '#28A745';
      case VehicleCondition.good:
        return '#5CB85C';
      case VehicleCondition.fair:
        return '#FFC107';
      case VehicleCondition.needsMaintenance:
        return '#FF5722';
    }
  }
}
