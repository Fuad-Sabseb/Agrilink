import 'package:hive/hive.dart';

part 'transporter_model.g.dart';

/// Transporter Model
/// Represents a logistics provider with vehicles and route expertise
@HiveType(typeId: 7)
class Transporter {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String businessName;

  @HiveField(4)
  final String baseLocation; // Primary operating woreda

  @HiveField(5)
  final bool isVerified;

  @HiveField(6)
  final double rating; // 0.0 - 5.0 stars

  @HiveField(7)
  final int totalTrips;

  @HiveField(8)
  final int completedTrips;

  @HiveField(9)
  final List<String> standardRoutes; // ["Jimma-Nekemte", "Jimma-Agaro"]

  @HiveField(10)
  final DateTime registeredAt;

  @HiveField(11)
  final DateTime? lastActiveAt;

  @HiveField(12)
  final bool isAvailable; // Currently accepting bookings

  @HiveField(13)
  final String? licenseNumber;

  @HiveField(14)
  final String? profileImageUrl;

  Transporter({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.businessName,
    required this.baseLocation,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.standardRoutes = const [],
    required this.registeredAt,
    this.lastActiveAt,
    this.isAvailable = true,
    this.licenseNumber,
    this.profileImageUrl,
  });

  /// Calculate completion rate percentage
  double get completionRate {
    if (totalTrips == 0) return 0.0;
    return (completedTrips / totalTrips) * 100;
  }

  /// Check if transporter is active (active within last 7 days)
  bool get isActive {
    if (lastActiveAt == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActiveAt!).inDays;
    return daysSinceActive <= 7;
  }

  /// Get reliability tier based on rating
  TransporterReliabilityTier get reliabilityTier {
    if (rating >= 4.5) return TransporterReliabilityTier.excellent;
    if (rating >= 4.0) return TransporterReliabilityTier.veryGood;
    if (rating >= 3.5) return TransporterReliabilityTier.good;
    if (rating >= 3.0) return TransporterReliabilityTier.average;
    return TransporterReliabilityTier.belowAverage;
  }

  /// Check if transporter operates on a specific route
  bool operatesOnRoute(String route) {
    return standardRoutes.any((r) => 
      r.toLowerCase().contains(route.toLowerCase()) ||
      route.toLowerCase().contains(r.toLowerCase())
    );
  }

  /// Create a copy with updated fields
  Transporter copyWith({
    String? name,
    String? phoneNumber,
    String? businessName,
    String? baseLocation,
    bool? isVerified,
    double? rating,
    int? totalTrips,
    int? completedTrips,
    List<String>? standardRoutes,
    DateTime? lastActiveAt,
    bool? isAvailable,
    String? licenseNumber,
    String? profileImageUrl,
  }) {
    return Transporter(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessName: businessName ?? this.businessName,
      baseLocation: baseLocation ?? this.baseLocation,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      standardRoutes: standardRoutes ?? this.standardRoutes,
      registeredAt: registeredAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isAvailable: isAvailable ?? this.isAvailable,
      licenseNumber: licenseNumber ?? this.licenseNumber,
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
      'baseLocation': baseLocation,
      'isVerified': isVerified,
      'rating': rating,
      'totalTrips': totalTrips,
      'completedTrips': completedTrips,
      'standardRoutes': standardRoutes,
      'registeredAt': registeredAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isAvailable': isAvailable,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Create from JSON
  factory Transporter.fromJson(Map<String, dynamic> json) {
    return Transporter(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      businessName: json['businessName'] as String,
      baseLocation: json['baseLocation'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      standardRoutes: (json['standardRoutes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      licenseNumber: json['licenseNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

/// Transporter Reliability Tier
enum TransporterReliabilityTier {
  excellent,
  veryGood,
  good,
  average,
  belowAverage,
}

extension TransporterReliabilityTierExtension on TransporterReliabilityTier {
  String get displayName {
    switch (this) {
      case TransporterReliabilityTier.excellent:
        return 'Excellent';
      case TransporterReliabilityTier.veryGood:
        return 'Very Good';
      case TransporterReliabilityTier.good:
        return 'Good';
      case TransporterReliabilityTier.average:
        return 'Average';
      case TransporterReliabilityTier.belowAverage:
        return 'Below Average';
    }
  }

  String get color {
    switch (this) {
      case TransporterReliabilityTier.excellent:
        return '#28A745';
      case TransporterReliabilityTier.veryGood:
        return '#5CB85C';
      case TransporterReliabilityTier.good:
        return '#FFC107';
      case TransporterReliabilityTier.average:
        return '#FF9800';
      case TransporterReliabilityTier.belowAverage:
        return '#FF5722';
    }
  }
}
