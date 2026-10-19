import 'package:hive/hive.dart';
import 'crop_plot_model.dart';

part 'demand_model.g.dart';

/// Demand Model
/// Represents a buyer's crop demand with live buying status
@HiveType(typeId: 6)
class Demand {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String buyerId;

  @HiveField(2)
  final CropType cropType;

  @HiveField(3)
  final QualityGrade preferredGrade;

  @HiveField(4)
  final double minimumQuantityKg;

  @HiveField(5)
  final double maximumQuantityKg;

  @HiveField(6)
  final double priceOfferPerKg;

  @HiveField(7)
  final BuyingStatus status;

  @HiveField(8)
  final String pickupLocation; // Woreda/Town

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime expiresAt;

  @HiveField(11)
  final String? additionalNotes;

  @HiveField(12)
  final bool transportProvided; // Buyer provides transport

  @HiveField(13)
  final List<QualityGrade>? acceptedGrades; // Can accept multiple grades

  @HiveField(14)
  final int viewCount;

  @HiveField(15)
  final int responseCount;

  Demand({
    required this.id,
    required this.buyerId,
    required this.cropType,
    required this.preferredGrade,
    required this.minimumQuantityKg,
    required this.maximumQuantityKg,
    required this.priceOfferPerKg,
    required this.status,
    required this.pickupLocation,
    required this.createdAt,
    required this.expiresAt,
    this.additionalNotes,
    this.transportProvided = false,
    this.acceptedGrades,
    this.viewCount = 0,
    this.responseCount = 0,
  });

  /// Check if demand is currently active
  bool get isActive {
    return status == BuyingStatus.buyingNow && !isExpired;
  }

  /// Check if demand has expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get hours until expiration
  int get hoursUntilExpiry {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inHours;
  }

  /// Get days since posted
  int get daysSincePosted {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if demand is urgent (expires within 24 hours)
  bool get isUrgent {
    return !isExpired && hoursUntilExpiry <= 24;
  }

  /// Calculate total offer value at maximum quantity
  double get totalOfferValueMax {
    return priceOfferPerKg * maximumQuantityKg;
  }

  /// Calculate total offer value at minimum quantity
  double get totalOfferValueMin {
    return priceOfferPerKg * minimumQuantityKg;
  }

  /// Create a copy with updated fields
  Demand copyWith({
    BuyingStatus? status,
    double? priceOfferPerKg,
    DateTime? expiresAt,
    String? additionalNotes,
    int? viewCount,
    int? responseCount,
  }) {
    return Demand(
      id: id,
      buyerId: buyerId,
      cropType: cropType,
      preferredGrade: preferredGrade,
      minimumQuantityKg: minimumQuantityKg,
      maximumQuantityKg: maximumQuantityKg,
      priceOfferPerKg: priceOfferPerKg ?? this.priceOfferPerKg,
      status: status ?? this.status,
      pickupLocation: pickupLocation,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      transportProvided: transportProvided,
      acceptedGrades: acceptedGrades,
      viewCount: viewCount ?? this.viewCount,
      responseCount: responseCount ?? this.responseCount,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'cropType': cropType.name,
      'preferredGrade': preferredGrade.name,
      'minimumQuantityKg': minimumQuantityKg,
      'maximumQuantityKg': maximumQuantityKg,
      'priceOfferPerKg': priceOfferPerKg,
      'status': status.name,
      'pickupLocation': pickupLocation,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'additionalNotes': additionalNotes,
      'transportProvided': transportProvided,
      'acceptedGrades': acceptedGrades?.map((g) => g.name).toList(),
      'viewCount': viewCount,
      'responseCount': responseCount,
    };
  }

  /// Create from JSON
  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      preferredGrade: QualityGrade.values.firstWhere(
        (e) => e.name == json['preferredGrade'],
        orElse: () => QualityGrade.standard,
      ),
      minimumQuantityKg: (json['minimumQuantityKg'] as num).toDouble(),
      maximumQuantityKg: (json['maximumQuantityKg'] as num).toDouble(),
      priceOfferPerKg: (json['priceOfferPerKg'] as num).toDouble(),
      status: BuyingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BuyingStatus.paused,
      ),
      pickupLocation: json['pickupLocation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      additionalNotes: json['additionalNotes'] as String?,
      transportProvided: json['transportProvided'] as bool? ?? false,
      acceptedGrades: (json['acceptedGrades'] as List<dynamic>?)
          ?.map((g) => QualityGrade.values.firstWhere(
                (e) => e.name == g,
                orElse: () => QualityGrade.standard,
              ))
          .toList(),
      viewCount: json['viewCount'] as int? ?? 0,
      responseCount: json['responseCount'] as int? ?? 0,
    );
  }
}

/// Buying Status Enum - Live status indicator
@HiveType(typeId: 13)
enum BuyingStatus {
  @HiveField(0)
  buyingNow, // Active - green pulse indicator

  @HiveField(1)
  paused, // Temporarily paused

  @HiveField(2)
  filled, // Demand fulfilled

  @HiveField(3)
  expired, // Time expired
}

/// Extension for buying status display
extension BuyingStatusExtension on BuyingStatus {
  String get displayName {
    switch (this) {
      case BuyingStatus.buyingNow:
        return 'Buying Now';
      case BuyingStatus.paused:
        return 'Paused';
      case BuyingStatus.filled:
        return 'Filled';
      case BuyingStatus.expired:
        return 'Expired';
    }
  }

  String get displayNameOm {
    switch (this) {
      case BuyingStatus.buyingNow:
        return 'Amma Bitaa Jira';
      case BuyingStatus.paused:
        return 'Dhaabate';
      case BuyingStatus.filled:
        return 'Guutame';
      case BuyingStatus.expired:
        return 'Yeroon Darbeera';
    }
  }

  String get displayNameAm {
    switch (this) {
      case BuyingStatus.buyingNow:
        return 'አሁን እየገዛ ነው';
      case BuyingStatus.paused:
        return 'ቆሟል';
      case BuyingStatus.filled:
        return 'ተሞልቷል';
      case BuyingStatus.expired:
        return 'ጊዜው አልፏል';
    }
  }

  String get color {
    switch (this) {
      case BuyingStatus.buyingNow:
        return '#28A745'; // Success green
      case BuyingStatus.paused:
        return '#FF9800'; // Warning orange
      case BuyingStatus.filled:
        return '#6C757D'; // Gray
      case BuyingStatus.expired:
        return '#DC3545'; // Error red
    }
  }

  bool get showPulse {
    return this == BuyingStatus.buyingNow;
  }
}

/// Commodity Tier Extension for CropType
extension CommodityTierExtension on CropType {
  /// Get commodity tier based on export value and market demand
  CommodityTier get tier {
    switch (this) {
      case CropType.coffee:
        return CommodityTier.premium; // High export value
      case CropType.teff:
        return CommodityTier.high; // Unique to Ethiopia, high demand
      case CropType.wheat:
      case CropType.maize:
        return CommodityTier.medium; // Staple crops
      case CropType.potato:
      case CropType.beans:
        return CommodityTier.standard; // Common vegetables
      case CropType.sorghum:
      case CropType.barley:
        return CommodityTier.medium;
      case CropType.other:
        return CommodityTier.standard;
    }
  }
}

/// Commodity Tier Enum
enum CommodityTier {
  premium, // Coffee, high-value exports
  high, // Teff, specialty crops
  medium, // Wheat, maize, cereals
  standard, // Common vegetables, low processing
}

extension CommodityTierBadgeExtension on CommodityTier {
  String get displayName {
    switch (this) {
      case CommodityTier.premium:
        return 'Premium';
      case CommodityTier.high:
        return 'High Value';
      case CommodityTier.medium:
        return 'Medium';
      case CommodityTier.standard:
        return 'Standard';
    }
  }

  String get color {
    switch (this) {
      case CommodityTier.premium:
        return '#FFD700'; // Gold
      case CommodityTier.high:
        return '#FFC107'; // Amber
      case CommodityTier.medium:
        return '#17A2B8'; // Info blue
      case CommodityTier.standard:
        return '#6C757D'; // Gray
    }
  }
}
