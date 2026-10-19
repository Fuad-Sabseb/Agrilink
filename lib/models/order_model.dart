import 'package:hive/hive.dart';

part 'order_model.g.dart';

/// Order Model - Represents a purchase order between buyer and farmer
/// Status flow: pending → confirmed → in_transit → delivered → completed
/// Can also be: cancelled, rejected
@HiveType(typeId: 2)
class OrderModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String produceId;

  @HiveField(2)
  final String produceName;

  @HiveField(3)
  final String buyerId;

  @HiveField(4)
  final String buyerName;

  @HiveField(5)
  final String farmerId;

  @HiveField(6)
  final String farmerName;

  @HiveField(7)
  final double quantityOrdered;

  @HiveField(8)
  final String unit;

  @HiveField(9)
  final double pricePerUnit;

  @HiveField(10)
  final double totalPrice;

  @HiveField(11)
  final String status;

  @HiveField(12)
  final String pickupLocation;

  @HiveField(13)
  final String deliveryLocation;

  @HiveField(14)
  final String? deliveryInstructions;

  @HiveField(15)
  final String? transportRequestId; // Links to transport request

  @HiveField(16)
  final DateTime? estimatedDeliveryDate;

  @HiveField(17)
  final DateTime? actualDeliveryDate;

  @HiveField(18)
  final String paymentMethod; // cash, mobile_money, bank_transfer, on_delivery

  @HiveField(19)
  final String paymentStatus; // pending, paid, partial, refunded

  @HiveField(20)
  final String? cancellationReason;

  @HiveField(21)
  final DateTime createdAt;

  @HiveField(22)
  final DateTime? updatedAt;

  @HiveField(23)
  final DateTime? confirmedAt;

  @HiveField(24)
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.produceId,
    required this.produceName,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.farmerName,
    required this.quantityOrdered,
    required this.unit,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.status,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.deliveryInstructions,
    this.transportRequestId,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    required this.paymentMethod,
    required this.paymentStatus,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.completedAt,
  });

  /// Check if order is active (not cancelled or completed)
  bool get isActive =>
      !['cancelled', 'completed', 'rejected'].contains(status);

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      ['pending', 'confirmed'].contains(status);

  /// Check if order requires transport
  bool get requiresTransport => pickupLocation != deliveryLocation;

  /// Check if order is paid
  bool get isPaid => paymentStatus == 'paid';

  /// Get order age in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Check if order is overdue (estimated delivery passed)
  bool get isOverdue {
    if (estimatedDeliveryDate == null) return false;
    return DateTime.now().isAfter(estimatedDeliveryDate!) &&
        !['delivered', 'completed', 'cancelled'].contains(status);
  }

  /// Create a copy with updated fields
  OrderModel copyWith({
    String? produceName,
    double? quantityOrdered,
    String? unit,
    double? pricePerUnit,
    double? totalPrice,
    String? status,
    String? deliveryLocation,
    String? deliveryInstructions,
    String? transportRequestId,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? paymentMethod,
    String? paymentStatus,
    String? cancellationReason,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id,
      produceId: produceId,
      produceName: produceName ?? this.produceName,
      buyerId: buyerId,
      buyerName: buyerName,
      farmerId: farmerId,
      farmerName: farmerName,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      transportRequestId: transportRequestId ?? this.transportRequestId,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produceId': produceId,
      'produceName': produceName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'quantityOrdered': quantityOrdered,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'status': status,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'deliveryInstructions': deliveryInstructions,
      'transportRequestId': transportRequestId,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      produceId: json['produceId'] as String,
      produceName: json['produceName'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      quantityOrdered: (json['quantityOrdered'] as num).toDouble(),
      unit: json['unit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      pickupLocation: json['pickupLocation'] as String,
      deliveryLocation: json['deliveryLocation'] as String,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      transportRequestId: json['transportRequestId'] as String?,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'] as String)
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
