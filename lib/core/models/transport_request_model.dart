import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'transport_request_model.g.dart';

/// Transport Request Model
/// Represents a farmer's request for transport services
@HiveType(typeId: 19)
class TransportRequest {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String farmerId;

  @HiveField(2)
  final CropType cropType;

  @HiveField(3)
  final double quantityKg;

  @HiveField(4)
  final String pickupLocation;

  @HiveField(5)
  final String deliveryLocation;

  @HiveField(6)
  final DateTime requestedPickupDate;

  @HiveField(7)
  final RequestStatus status;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? matchedAt;

  @HiveField(10)
  final String? matchedTransporterId;

  @HiveField(11)
  final String? matchedVehicleId;

  @HiveField(12)
  final double? agreedPrice;

  @HiveField(13)
  final String? specialInstructions;

  @HiveField(14)
  final bool requiresRefrigeration;

  @HiveField(15)
  final List<String>? responseTransporterIds; // Transporters who responded

  TransportRequest({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.quantityKg,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.requestedPickupDate,
    this.status = RequestStatus.pending,
    required this.createdAt,
    this.matchedAt,
    this.matchedTransporterId,
    this.matchedVehicleId,
    this.agreedPrice,
    this.specialInstructions,
    this.requiresRefrigeration = false,
    this.responseTransporterIds,
  });

  /// Get quantity in quintals
  double get quantityQuintals => quantityKg / 100.0;

  /// Get quantity in tons
  double get quantityTons => quantityKg / 1000.0;

  /// Check if request is pending (awaiting responses)
  bool get isPending => status == RequestStatus.pending;

  /// Check if request has been matched
  bool get isMatched => status == RequestStatus.matched;

  /// Check if request is active (not cancelled or expired)
  bool get isActive =>
      status != RequestStatus.cancelled && status != RequestStatus.expired;

  /// Get hours since request was created
  int get hoursSinceCreated {
    return DateTime.now().difference(createdAt).inHours;
  }

  /// Get response count
  int get responseCount => responseTransporterIds?.length ?? 0;

  /// Create a copy with updated fields
  TransportRequest copyWith({
    RequestStatus? status,
    DateTime? matchedAt,
    String? matchedTransporterId,
    String? matchedVehicleId,
    double? agreedPrice,
    String? specialInstructions,
    List<String>? responseTransporterIds,
  }) {
    return TransportRequest(
      id: id,
      farmerId: farmerId,
      cropType: cropType,
      quantityKg: quantityKg,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      requestedPickupDate: requestedPickupDate,
      status: status ?? this.status,
      createdAt: createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
      matchedTransporterId: matchedTransporterId ?? this.matchedTransporterId,
      matchedVehicleId: matchedVehicleId ?? this.matchedVehicleId,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      requiresRefrigeration: requiresRefrigeration,
      responseTransporterIds:
          responseTransporterIds ?? this.responseTransporterIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cropType': cropType.name,
      'quantityKg': quantityKg,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'requestedPickupDate': requestedPickupDate.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'matchedAt': matchedAt?.toIso8601String(),
      'matchedTransporterId': matchedTransporterId,
      'matchedVehicleId': matchedVehicleId,
      'agreedPrice': agreedPrice,
      'specialInstructions': specialInstructions,
      'requiresRefrigeration': requiresRefrigeration,
      'responseTransporterIds': responseTransporterIds,
    };
  }

  /// Create from JSON
  factory TransportRequest.fromJson(Map<String, dynamic> json) {
    return TransportRequest(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      quantityKg: (json['quantityKg'] as num).toDouble(),
      pickupLocation: json['pickupLocation'] as String,
      deliveryLocation: json['deliveryLocation'] as String,
      requestedPickupDate:
          DateTime.parse(json['requestedPickupDate'] as String),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      matchedAt: json['matchedAt'] != null
          ? DateTime.parse(json['matchedAt'] as String)
          : null,
      matchedTransporterId: json['matchedTransporterId'] as String?,
      matchedVehicleId: json['matchedVehicleId'] as String?,
      agreedPrice: (json['agreedPrice'] as num?)?.toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
      requiresRefrigeration: json['requiresRefrigeration'] as bool? ?? false,
      responseTransporterIds: (json['responseTransporterIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Request Status Enum
@HiveType(typeId: 20)
enum RequestStatus {
  @HiveField(0)
  pending, // Awaiting transporter responses

  @HiveField(1)
  matched, // Transporter matched, awaiting trip creation

  @HiveField(2)
  accepted, // Transporter accepted, trip created

  @HiveField(3)
  cancelled, // Cancelled by farmer

  @HiveField(4)
  expired, // Expired without match
}

/// Extension for request status display
extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.matched:
        return 'Matched';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.expired:
        return 'Expired';
    }
  }

  String get displayNameOm {
    switch (this) {
      case RequestStatus.pending:
        return 'Eegaa Jira';
      case RequestStatus.matched:
        return 'Walitti Fidame';
      case RequestStatus.accepted:
        return 'Fudhatame';
      case RequestStatus.cancelled:
        return 'Haqame';
      case RequestStatus.expired:
        return 'Yeroon Darbeera';
    }
  }

  String get color {
    switch (this) {
      case RequestStatus.pending:
        return '#FF9800'; // Orange
      case RequestStatus.matched:
        return '#17A2B8'; // Info blue
      case RequestStatus.accepted:
        return '#28A745'; // Success green
      case RequestStatus.cancelled:
        return '#6C757D'; // Gray
      case RequestStatus.expired:
        return '#DC3545'; // Error red
    }
  }

  String get icon {
    switch (this) {
      case RequestStatus.pending:
        return '⏳';
      case RequestStatus.matched:
        return '🤝';
      case RequestStatus.accepted:
        return '✅';
      case RequestStatus.cancelled:
        return '❌';
      case RequestStatus.expired:
        return '⏰';
    }
  }
}
