import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'trip_model.g.dart';

/// Trip Model
/// Represents a complete transport trip with multi-step transaction flow
/// Flow: Request Transport → Trip Matched → In Transit → Delivered
@HiveType(typeId: 21)
class Trip {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transportRequestId;

  @HiveField(2)
  final String farmerId;

  @HiveField(3)
  final String transporterId;

  @HiveField(4)
  final String vehicleId;

  @HiveField(5)
  final String routeId;

  @HiveField(6)
  final CropType cropType;

  @HiveField(7)
  final double quantityKg;

  @HiveField(8)
  final String pickupLocation;

  @HiveField(9)
  final String deliveryLocation;

  @HiveField(10)
  final double totalCost;

  @HiveField(11)
  final TripStatus status;

  @HiveField(12)
  final DateTime createdAt; // Trip created (matched)

  @HiveField(13)
  final DateTime? scheduledPickupTime;

  @HiveField(14)
  final DateTime? actualPickupTime;

  @HiveField(15)
  final DateTime? estimatedArrivalTime;

  @HiveField(16)
  final DateTime? actualDeliveryTime;

  @HiveField(17)
  final String? currentLocation; // For live tracking

  @HiveField(18)
  final double? currentDistanceKm; // Distance from pickup

  @HiveField(19)
  final String? farmerNotes;

  @HiveField(20)
  final String? transporterNotes;

  @HiveField(21)
  final double? farmerRating; // 1-5 rating by farmer

  @HiveField(22)
  final double? transporterRating; // 1-5 rating by transporter

  @HiveField(23)
  final List<TripStatusUpdate>? statusUpdates; // Timeline of updates

  Trip({
    required this.id,
    required this.transportRequestId,
    required this.farmerId,
    required this.transporterId,
    required this.vehicleId,
    required this.routeId,
    required this.cropType,
    required this.quantityKg,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.totalCost,
    this.status = TripStatus.matched,
    required this.createdAt,
    this.scheduledPickupTime,
    this.actualPickupTime,
    this.estimatedArrivalTime,
    this.actualDeliveryTime,
    this.currentLocation,
    this.currentDistanceKm,
    this.farmerNotes,
    this.transporterNotes,
    this.farmerRating,
    this.transporterRating,
    this.statusUpdates,
  });

  /// Get quantity in quintals
  double get quantityQuintals => quantityKg / 100.0;

  /// Get quantity in tons
  double get quantityTons => quantityKg / 1000.0;

  /// Check if trip is active (not completed or cancelled)
  bool get isActive =>
      status != TripStatus.delivered && status != TripStatus.cancelled;

  /// Check if trip is in transit
  bool get isInTransit => status == TripStatus.inTransit;

  /// Check if trip is completed
  bool get isCompleted => status == TripStatus.delivered;

  /// Get trip duration (pickup to delivery)
  Duration? get tripDuration {
    if (actualPickupTime == null || actualDeliveryTime == null) return null;
    return actualDeliveryTime!.difference(actualPickupTime!);
  }

  /// Get estimated time remaining
  Duration? get estimatedTimeRemaining {
    if (estimatedArrivalTime == null) return null;
    final remaining = estimatedArrivalTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calculate progress percentage (0-100)
  int? get progressPercentage {
    if (status == TripStatus.matched) return 0;
    if (status == TripStatus.inTransit && currentDistanceKm != null) {
      // Assuming we have route distance somewhere
      return 50; // Simplified for now
    }
    if (status == TripStatus.delivered) return 100;
    return null;
  }

  /// Get current status step (1-4 for UI display)
  int get currentStep {
    switch (status) {
      case TripStatus.matched:
        return 1;
      case TripStatus.pickedUp:
        return 2;
      case TripStatus.inTransit:
        return 3;
      case TripStatus.delivered:
        return 4;
      case TripStatus.cancelled:
        return 0;
    }
  }

  /// Check if trip can be cancelled
  bool get canBeCancelled {
    return status == TripStatus.matched || status == TripStatus.pickedUp;
  }

  /// Check if trip can be rated
  bool get canBeRated {
    return status == TripStatus.delivered && farmerRating == null;
  }

  /// Create a copy with updated fields
  Trip copyWith({
    TripStatus? status,
    DateTime? scheduledPickupTime,
    DateTime? actualPickupTime,
    DateTime? estimatedArrivalTime,
    DateTime? actualDeliveryTime,
    String? currentLocation,
    double? currentDistanceKm,
    String? farmerNotes,
    String? transporterNotes,
    double? farmerRating,
    double? transporterRating,
    List<TripStatusUpdate>? statusUpdates,
  }) {
    return Trip(
      id: id,
      transportRequestId: transportRequestId,
      farmerId: farmerId,
      transporterId: transporterId,
      vehicleId: vehicleId,
      routeId: routeId,
      cropType: cropType,
      quantityKg: quantityKg,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      totalCost: totalCost,
      status: status ?? this.status,
      createdAt: createdAt,
      scheduledPickupTime: scheduledPickupTime ?? this.scheduledPickupTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      currentLocation: currentLocation ?? this.currentLocation,
      currentDistanceKm: currentDistanceKm ?? this.currentDistanceKm,
      farmerNotes: farmerNotes ?? this.farmerNotes,
      transporterNotes: transporterNotes ?? this.transporterNotes,
      farmerRating: farmerRating ?? this.farmerRating,
      transporterRating: transporterRating ?? this.transporterRating,
      statusUpdates: statusUpdates ?? this.statusUpdates,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transportRequestId': transportRequestId,
      'farmerId': farmerId,
      'transporterId': transporterId,
      'vehicleId': vehicleId,
      'routeId': routeId,
      'cropType': cropType.name,
      'quantityKg': quantityKg,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'totalCost': totalCost,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledPickupTime': scheduledPickupTime?.toIso8601String(),
      'actualPickupTime': actualPickupTime?.toIso8601String(),
      'estimatedArrivalTime': estimatedArrivalTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'currentLocation': currentLocation,
      'currentDistanceKm': currentDistanceKm,
      'farmerNotes': farmerNotes,
      'transporterNotes': transporterNotes,
      'farmerRating': farmerRating,
      'transporterRating': transporterRating,
      'statusUpdates': statusUpdates?.map((u) => u.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      transportRequestId: json['transportRequestId'] as String,
      farmerId: json['farmerId'] as String,
      transporterId: json['transporterId'] as String,
      vehicleId: json['vehicleId'] as String,
      routeId: json['routeId'] as String,
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      quantityKg: (json['quantityKg'] as num).toDouble(),
      pickupLocation: json['pickupLocation'] as String,
      deliveryLocation: json['deliveryLocation'] as String,
      totalCost: (json['totalCost'] as num).toDouble(),
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.matched,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledPickupTime: json['scheduledPickupTime'] != null
          ? DateTime.parse(json['scheduledPickupTime'] as String)
          : null,
      actualPickupTime: json['actualPickupTime'] != null
          ? DateTime.parse(json['actualPickupTime'] as String)
          : null,
      estimatedArrivalTime: json['estimatedArrivalTime'] != null
          ? DateTime.parse(json['estimatedArrivalTime'] as String)
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'] as String)
          : null,
      currentLocation: json['currentLocation'] as String?,
      currentDistanceKm: (json['currentDistanceKm'] as num?)?.toDouble(),
      farmerNotes: json['farmerNotes'] as String?,
      transporterNotes: json['transporterNotes'] as String?,
      farmerRating: (json['farmerRating'] as num?)?.toDouble(),
      transporterRating: (json['transporterRating'] as num?)?.toDouble(),
      statusUpdates: (json['statusUpdates'] as List<dynamic>?)
          ?.map((u) => TripStatusUpdate.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Trip Status Enum - Multi-step transaction flow
/// Flow: Request Transport → Trip Matched → In Transit → Delivered
@HiveType(typeId: 22)
enum TripStatus {
  @HiveField(0)
  matched, // Step 1: Trip Matched (transporter accepted)

  @HiveField(1)
  pickedUp, // Step 2: Cargo picked up

  @HiveField(2)
  inTransit, // Step 3: In Transit (on the way)

  @HiveField(3)
  delivered, // Step 4: Delivered (completed)

  @HiveField(4)
  cancelled, // Cancelled at any stage
}

/// Trip Status Update - For timeline display
@HiveType(typeId: 23)
class TripStatusUpdate {
  @HiveField(0)
  final TripStatus status;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String? note;

  @HiveField(3)
  final String? location;

  TripStatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'location': location,
    };
  }

  factory TripStatusUpdate.fromJson(Map<String, dynamic> json) {
    return TripStatusUpdate(
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.matched,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// Extension for trip status display
extension TripStatusExtension on TripStatus {
  String get displayName {
    switch (this) {
      case TripStatus.matched:
        return 'Trip Matched';
      case TripStatus.pickedUp:
        return 'Picked Up';
      case TripStatus.inTransit:
        return 'In Transit';
      case TripStatus.delivered:
        return 'Delivered';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get displayNameOm {
    switch (this) {
      case TripStatus.matched:
        return 'Imala Walitti Fidame';
      case TripStatus.pickedUp:
        return 'Fudhatamuus Jalqabe';
      case TripStatus.inTransit:
        return 'Karaa Irra';
      case TripStatus.delivered:
        return 'Geeffame';
      case TripStatus.cancelled:
        return 'Haqame';
    }
  }

  String get displayNameAm {
    switch (this) {
      case TripStatus.matched:
        return 'ጉዞ ተዛምዷል';
      case TripStatus.pickedUp:
        return 'ተወስዷል';
      case TripStatus.inTransit:
        return 'በመንገድ ላይ';
      case TripStatus.delivered:
        return 'ደርሷል';
      case TripStatus.cancelled:
        return 'ተሰርዟል';
    }
  }

  String get color {
    switch (this) {
      case TripStatus.matched:
        return '#17A2B8'; // Info blue
      case TripStatus.pickedUp:
        return '#FFC107'; // Amber
      case TripStatus.inTransit:
        return '#FF9800'; // Orange
      case TripStatus.delivered:
        return '#28A745'; // Success green
      case TripStatus.cancelled:
        return '#DC3545'; // Error red
    }
  }

  String get icon {
    switch (this) {
      case TripStatus.matched:
        return '🤝';
      case TripStatus.pickedUp:
        return '📦';
      case TripStatus.inTransit:
        return '🚚';
      case TripStatus.delivered:
        return '✅';
      case TripStatus.cancelled:
        return '❌';
    }
  }

  /// Get step number (1-4)
  int get stepNumber {
    switch (this) {
      case TripStatus.matched:
        return 1;
      case TripStatus.pickedUp:
        return 2;
      case TripStatus.inTransit:
        return 3;
      case TripStatus.delivered:
        return 4;
      case TripStatus.cancelled:
        return 0;
    }
  }

  /// Get description for timeline
  String get description {
    switch (this) {
      case TripStatus.matched:
        return 'Transporter accepted your request and trip is scheduled';
      case TripStatus.pickedUp:
        return 'Cargo has been picked up from your location';
      case TripStatus.inTransit:
        return 'Shipment is on the way to destination';
      case TripStatus.delivered:
        return 'Cargo successfully delivered';
      case TripStatus.cancelled:
        return 'Trip was cancelled';
    }
  }
}
