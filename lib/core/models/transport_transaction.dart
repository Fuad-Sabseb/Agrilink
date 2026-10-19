import 'package:hive/hive.dart';

part 'transport_transaction.g.dart';

/// Transport Transaction Model
/// Represents a completed transport job with earnings and payment details
@HiveType(typeId: 24)
class TransportTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String jobId;

  @HiveField(2)
  final String transporterId;

  @HiveField(3)
  final String route; // e.g., "Jimma-Nekemte"

  @HiveField(4)
  final double distanceKm;

  @HiveField(5)
  final double earnings;

  @HiveField(6)
  final TransactionStatus status;

  @HiveField(7)
  final PaymentMethod paymentMethod;

  @HiveField(8)
  final DateTime completedAt;

  @HiveField(9)
  final DateTime? paidAt;

  @HiveField(10)
  final String? notes;

  TransportTransaction({
    required this.id,
    required this.jobId,
    required this.transporterId,
    required this.route,
    required this.distanceKm,
    required this.earnings,
    required this.status,
    required this.paymentMethod,
    required this.completedAt,
    this.paidAt,
    this.notes,
  });

  /// Check if transaction is paid
  bool get isPaid => status == TransactionStatus.paid;

  /// Check if payment is pending
  bool get isPending => status == TransactionStatus.pendingPayment;

  /// Calculate earnings per km
  double get earningsPerKm => distanceKm > 0 ? earnings / distanceKm : 0;

  /// Create copy with updated fields
  TransportTransaction copyWith({
    TransactionStatus? status,
    DateTime? paidAt,
    String? notes,
  }) {
    return TransportTransaction(
      id: id,
      jobId: jobId,
      transporterId: transporterId,
      route: route,
      distanceKm: distanceKm,
      earnings: earnings,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      completedAt: completedAt,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'transporterId': transporterId,
      'route': route,
      'distanceKm': distanceKm,
      'earnings': earnings,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'completedAt': completedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from JSON
  factory TransportTransaction.fromJson(Map<String, dynamic> json) {
    return TransportTransaction(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      transporterId: json['transporterId'] as String,
      route: json['route'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      earnings: (json['earnings'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TransactionStatus.pendingPayment,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      paidAt: json['paidAt'] != null 
          ? DateTime.parse(json['paidAt'] as String) 
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to CSV row
  String toCsvRow() {
    final completedDate = completedAt.toString().split(' ')[0];
    final paidDate = paidAt?.toString().split(' ')[0] ?? '';
    return '$completedDate,$jobId,$route,$distanceKm,$earnings,${status.displayName},${paymentMethod.displayName},$paidDate';
  }
}

/// Transaction Status Enum
@HiveType(typeId: 25)
enum TransactionStatus {
  @HiveField(0)
  completed,
  
  @HiveField(1)
  pendingPayment,
  
  @HiveField(2)
  paid,
  
  @HiveField(3)
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pendingPayment:
        return 'Pending Payment';
      case TransactionStatus.paid:
        return 'Paid';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get color {
    switch (this) {
      case TransactionStatus.completed:
        return '#28A745';
      case TransactionStatus.pendingPayment:
        return '#FFC107';
      case TransactionStatus.paid:
        return '#28A745';
      case TransactionStatus.cancelled:
        return '#DC3545';
    }
  }
}

/// Payment Method Enum
@HiveType(typeId: 26)
enum PaymentMethod {
  @HiveField(0)
  cash,
  
  @HiveField(1)
  mobileMoney,
  
  @HiveField(2)
  bankTransfer,
  
  @HiveField(3)
  onDelivery,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.onDelivery:
        return 'On Delivery';
    }
  }
}

/// Transaction Filter Model
class TransactionFilter {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TransactionStatus? status;
  final double? minEarnings;
  final double? maxEarnings;
  final PaymentMethod? paymentMethod;

  TransactionFilter({
    this.fromDate,
    this.toDate,
    this.status,
    this.minEarnings,
    this.maxEarnings,
    this.paymentMethod,
  });

  bool matches(TransportTransaction transaction) {
    if (fromDate != null && transaction.completedAt.isBefore(fromDate!)) {
      return false;
    }
    if (toDate != null && transaction.completedAt.isAfter(toDate!)) {
      return false;
    }
    if (status != null && transaction.status != status) {
      return false;
    }
    if (minEarnings != null && transaction.earnings < minEarnings!) {
      return false;
    }
    if (maxEarnings != null && transaction.earnings > maxEarnings!) {
      return false;
    }
    if (paymentMethod != null && transaction.paymentMethod != paymentMethod) {
      return false;
    }
    return true;
  }

  bool get hasActiveFilters =>
      fromDate != null ||
      toDate != null ||
      status != null ||
      minEarnings != null ||
      maxEarnings != null ||
      paymentMethod != null;
}
