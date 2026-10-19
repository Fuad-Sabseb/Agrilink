import 'package:hive/hive.dart';

part 'buyer_model.g.dart';

/// Buyer Model
/// Represents a buyer/merchant with verification and reliability tracking
@HiveType(typeId: 5)
class Buyer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String businessName;

  @HiveField(4)
  final BuyerType buyerType;

  @HiveField(5)
  final String location; // Woreda/Town

  @HiveField(6)
  final bool isVerified;

  @HiveField(7)
  final double reliabilityScore; // 0.0 - 5.0 stars

  @HiveField(8)
  final int totalTransactions;

  @HiveField(9)
  final int successfulTransactions;

  @HiveField(10)
  final DateTime registeredAt;

  @HiveField(11)
  final DateTime? lastActiveAt;

  @HiveField(12)
  final String? profileImageUrl;

  Buyer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.businessName,
    required this.buyerType,
    required this.location,
    this.isVerified = false,
    this.reliabilityScore = 0.0,
    this.totalTransactions = 0,
    this.successfulTransactions = 0,
    required this.registeredAt,
    this.lastActiveAt,
    this.profileImageUrl,
  });

  /// Calculate success rate percentage
  double get successRate {
    if (totalTransactions == 0) return 0.0;
    return (successfulTransactions / totalTransactions) * 100;
  }

  /// Check if buyer is currently active (active within last 7 days)
  bool get isActive {
    if (lastActiveAt == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActiveAt!).inDays;
    return daysSinceActive <= 7;
  }

  /// Get reliability rating tier
  ReliabilityTier get reliabilityTier {
    if (reliabilityScore >= 4.5) return ReliabilityTier.excellent;
    if (reliabilityScore >= 4.0) return ReliabilityTier.veryGood;
    if (reliabilityScore >= 3.5) return ReliabilityTier.good;
    if (reliabilityScore >= 3.0) return ReliabilityTier.average;
    if (reliabilityScore >= 2.0) return ReliabilityTier.belowAverage;
    return ReliabilityTier.poor;
  }

  /// Create a copy with updated fields
  Buyer copyWith({
    String? name,
    String? phoneNumber,
    String? businessName,
    BuyerType? buyerType,
    String? location,
    bool? isVerified,
    double? reliabilityScore,
    int? totalTransactions,
    int? successfulTransactions,
    DateTime? lastActiveAt,
    String? profileImageUrl,
  }) {
    return Buyer(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessName: businessName ?? this.businessName,
      buyerType: buyerType ?? this.buyerType,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      successfulTransactions:
          successfulTransactions ?? this.successfulTransactions,
      registeredAt: registeredAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'businessName': businessName,
      'buyerType': buyerType.name,
      'location': location,
      'isVerified': isVerified,
      'reliabilityScore': reliabilityScore,
      'totalTransactions': totalTransactions,
      'successfulTransactions': successfulTransactions,
      'registeredAt': registeredAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Create from JSON
  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      businessName: json['businessName'] as String,
      buyerType: BuyerType.values.firstWhere(
        (e) => e.name == json['buyerType'],
        orElse: () => BuyerType.wholesaler,
      ),
      location: json['location'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      successfulTransactions: json['successfulTransactions'] as int? ?? 0,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

/// Buyer Type Enum
@HiveType(typeId: 12)
enum BuyerType {
  @HiveField(0)
  wholesaler,
  @HiveField(1)
  processor,
  @HiveField(2)
  exporter,
  @HiveField(3)
  retailer,
  @HiveField(4)
  cooperative,
}

/// Reliability Tier
enum ReliabilityTier {
  excellent,
  veryGood,
  good,
  average,
  belowAverage,
  poor,
}

/// Extension for buyer type display names
extension BuyerTypeExtension on BuyerType {
  String get displayName {
    switch (this) {
      case BuyerType.wholesaler:
        return 'Wholesaler';
      case BuyerType.processor:
        return 'Processor';
      case BuyerType.exporter:
        return 'Exporter';
      case BuyerType.retailer:
        return 'Retailer';
      case BuyerType.cooperative:
        return 'Cooperative';
    }
  }

  String get displayNameOm {
    switch (this) {
      case BuyerType.wholesaler:
        return 'Daldalaa Guddaa';
      case BuyerType.processor:
        return 'Qopheessaa';
      case BuyerType.exporter:
      return 'Ergaa Biyyaa Alaatti';
      case BuyerType.retailer:
        return 'Daldalaa Xixiqqaa';
      case BuyerType.cooperative:
        return 'Kooperaatiivii';
    }
  }
}

/// Extension for reliability tier
extension ReliabilityTierExtension on ReliabilityTier {
  String get displayName {
    switch (this) {
      case ReliabilityTier.excellent:
        return 'Excellent';
      case ReliabilityTier.veryGood:
        return 'Very Good';
      case ReliabilityTier.good:
        return 'Good';
      case ReliabilityTier.average:
        return 'Average';
      case ReliabilityTier.belowAverage:
        return 'Below Average';
      case ReliabilityTier.poor:
        return 'Poor';
    }
  }

  String get color {
    switch (this) {
      case ReliabilityTier.excellent:
        return '#28A745'; // Green
      case ReliabilityTier.veryGood:
        return '#5CB85C';
      case ReliabilityTier.good:
        return '#FFC107'; // Amber
      case ReliabilityTier.average:
        return '#FF9800'; // Orange
      case ReliabilityTier.belowAverage:
        return '#FF5722'; // Deep Orange
      case ReliabilityTier.poor:
        return '#DC3545'; // Red
    }
  }
}
