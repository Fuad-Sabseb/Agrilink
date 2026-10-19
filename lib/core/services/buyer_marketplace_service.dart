import '../models/buyer_model.dart';
import '../models/demand_model.dart';
import '../models/crop_plot_model.dart';

/// Buyer Marketplace Service
/// Provides mock buyers and demands with filtering logic
/// Module 3: Live 'Buying Now' status, reliability scores, commodity tiers
class BuyerMarketplaceService {
  BuyerMarketplaceService._();

  // ============================================================================
  // MOCK BUYERS - 10+ verified and unverified buyers with reliability scores
  // ============================================================================

  static final List<Buyer> _mockBuyers = [
    // High-reliability exporters
    Buyer(
      id: 'buyer-001',
      name: 'Ahmed Hassan',
      phoneNumber: '+251911234567',
      businessName: 'Hassan Coffee Export',
      buyerType: BuyerType.exporter,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.8,
      totalTransactions: 87,
      successfulTransactions: 85,
      registeredAt: DateTime(2023, 3, 15),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Buyer(
      id: 'buyer-002',
      name: 'Fatima Mohammed',
      phoneNumber: '+251922345678',
      businessName: 'Oromia Grain Traders',
      buyerType: BuyerType.wholesaler,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.6,
      totalTransactions: 124,
      successfulTransactions: 118,
      registeredAt: DateTime(2023, 1, 10),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    
    // Processors
    Buyer(
      id: 'buyer-003',
      name: 'Bekele Tadesse',
      phoneNumber: '+251933456789',
      businessName: 'Jimma Flour Mills',
      buyerType: BuyerType.processor,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.5,
      totalTransactions: 65,
      successfulTransactions: 62,
      registeredAt: DateTime(2023, 5, 20),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Buyer(
      id: 'buyer-004',
      name: 'Sara Kumbi',
      phoneNumber: '+251944567890',
      businessName: 'Ethiopian Coffee Processing PLC',
      buyerType: BuyerType.processor,
      location: 'Nekemte',
      isVerified: true,
      reliabilityScore: 4.7,
      totalTransactions: 93,
      successfulTransactions: 91,
      registeredAt: DateTime(2023, 2, 1),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    
    // Cooperatives
    Buyer(
      id: 'buyer-005',
      name: 'Oromia Farmers Cooperative Union',
      phoneNumber: '+251955678901',
      businessName: 'OFCU - Jimma Branch',
      buyerType: BuyerType.cooperative,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.4,
      totalTransactions: 156,
      successfulTransactions: 148,
      registeredAt: DateTime(2022, 11, 5),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    
    // Mid-tier buyers
    Buyer(
      id: 'buyer-006',
      name: 'Mulugeta Alemu',
      phoneNumber: '+251966789012',
      businessName: 'Agaro Commodity Trading',
      buyerType: BuyerType.wholesaler,
      location: 'Agaro',
      isVerified: true,
      reliabilityScore: 3.9,
      totalTransactions: 42,
      successfulTransactions: 38,
      registeredAt: DateTime(2024, 1, 15),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Buyer(
      id: 'buyer-007',
      name: 'Hawa Ibrahim',
      phoneNumber: '+251977890123',
      businessName: 'Nekemte Grain Merchants',
      buyerType: BuyerType.retailer,
      location: 'Nekemte',
      isVerified: false,
      reliabilityScore: 3.5,
      totalTransactions: 28,
      successfulTransactions: 24,
      registeredAt: DateTime(2024, 3, 10),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    
    // New/emerging buyers
    Buyer(
      id: 'buyer-008',
      name: 'Dawit Tesfaye',
      phoneNumber: '+251988901234',
      businessName: 'Ethiopia Teff Export',
      buyerType: BuyerType.exporter,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.2,
      totalTransactions: 19,
      successfulTransactions: 18,
      registeredAt: DateTime(2024, 6, 1),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    Buyer(
      id: 'buyer-009',
      name: 'Tigist Haile',
      phoneNumber: '+251999012345',
      businessName: 'Highland Potato Traders',
      buyerType: BuyerType.wholesaler,
      location: 'Agaro',
      isVerified: false,
      reliabilityScore: 3.2,
      totalTransactions: 15,
      successfulTransactions: 13,
      registeredAt: DateTime(2024, 8, 5),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Buyer(
      id: 'buyer-010',
      name: 'Yohannes Kebede',
      phoneNumber: '+251900123456',
      businessName: 'Jimma Agricultural Supplies',
      buyerType: BuyerType.retailer,
      location: 'Jimma Town',
      isVerified: true,
      reliabilityScore: 4.0,
      totalTransactions: 52,
      successfulTransactions: 48,
      registeredAt: DateTime(2023, 9, 20),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ============================================================================
  // MOCK DEMANDS - 15+ active demands with 'Buying Now' status
  // ============================================================================

  static final List<Demand> _mockDemands = [
    // ACTIVE 'BUYING NOW' demands - Premium coffee
    Demand(
      id: 'demand-001',
      buyerId: 'buyer-001',
      cropType: CropType.coffee,
      preferredGrade: QualityGrade.premium,
      minimumQuantityKg: 500,
      maximumQuantityKg: 2000,
      priceOfferPerKg: 95.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      additionalNotes: 'Washed coffee only. Must be fresh harvest.',
      transportProvided: true,
      acceptedGrades: [QualityGrade.premium, QualityGrade.grade1],
      viewCount: 45,
      responseCount: 8,
    ),
    
    // BUYING NOW - Teff (high demand)
    Demand(
      id: 'demand-002',
      buyerId: 'buyer-008',
      cropType: CropType.teff,
      preferredGrade: QualityGrade.grade1,
      minimumQuantityKg: 1000,
      maximumQuantityKg: 5000,
      priceOfferPerKg: 70.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      additionalNotes: 'White teff preferred. Payment within 24 hours.',
      transportProvided: false,
      acceptedGrades: [QualityGrade.grade1, QualityGrade.grade2],
      viewCount: 62,
      responseCount: 12,
    ),
    
    // BUYING NOW - Maize for processing
    Demand(
      id: 'demand-003',
      buyerId: 'buyer-003',
      cropType: CropType.maize,
      preferredGrade: QualityGrade.standard,
      minimumQuantityKg: 3000,
      maximumQuantityKg: 10000,
      priceOfferPerKg: 44.50,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      additionalNotes: 'Bulk purchase for flour production. Dry grain only.',
      transportProvided: true,
      acceptedGrades: [
        QualityGrade.standard,
        QualityGrade.grade2,
        QualityGrade.grade3
      ],
      viewCount: 89,
      responseCount: 15,
    ),
    
    // BUYING NOW - Coffee from cooperative
    Demand(
      id: 'demand-004',
      buyerId: 'buyer-004',
      cropType: CropType.coffee,
      preferredGrade: QualityGrade.grade1,
      minimumQuantityKg: 800,
      maximumQuantityKg: 3000,
      priceOfferPerKg: 92.50,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Nekemte',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      expiresAt: DateTime.now().add(const Duration(hours: 36)),
      additionalNotes: 'Grade 1 arabica. Contract available for regular supply.',
      transportProvided: true,
      acceptedGrades: [QualityGrade.grade1],
      viewCount: 53,
      responseCount: 9,
    ),
    
    // BUYING NOW - Wheat bulk
    Demand(
      id: 'demand-005',
      buyerId: 'buyer-002',
      cropType: CropType.wheat,
      preferredGrade: QualityGrade.grade2,
      minimumQuantityKg: 2000,
      maximumQuantityKg: 8000,
      priceOfferPerKg: 58.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      additionalNotes: 'Clean, dry wheat. Moisture max 12%.',
      transportProvided: false,
      acceptedGrades: [QualityGrade.grade2, QualityGrade.grade3],
      viewCount: 34,
      responseCount: 6,
    ),
    
    // BUYING NOW - Potato urgent
    Demand(
      id: 'demand-006',
      buyerId: 'buyer-009',
      cropType: CropType.potato,
      preferredGrade: QualityGrade.grade1,
      minimumQuantityKg: 500,
      maximumQuantityKg: 2000,
      priceOfferPerKg: 27.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Agaro',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
      additionalNotes: 'URGENT: Need delivery within 2 days. Good size potatoes.',
      transportProvided: false,
      acceptedGrades: [QualityGrade.grade1, QualityGrade.grade2],
      viewCount: 28,
      responseCount: 5,
    ),
    
    // BUYING NOW - Coffee premium from cooperative
    Demand(
      id: 'demand-007',
      buyerId: 'buyer-005',
      cropType: CropType.coffee,
      preferredGrade: QualityGrade.premium,
      minimumQuantityKg: 300,
      maximumQuantityKg: 1500,
      priceOfferPerKg: 98.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      additionalNotes: 'Cooperative members priority. Premium washed arabica.',
      transportProvided: true,
      acceptedGrades: [QualityGrade.premium],
      viewCount: 41,
      responseCount: 7,
    ),
    
    // PAUSED demands
    Demand(
      id: 'demand-008',
      buyerId: 'buyer-006',
      cropType: CropType.maize,
      preferredGrade: QualityGrade.grade1,
      minimumQuantityKg: 1000,
      maximumQuantityKg: 4000,
      priceOfferPerKg: 42.00,
      status: BuyingStatus.paused,
      pickupLocation: 'Agaro',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      additionalNotes: 'Temporarily paused - will resume next week.',
      transportProvided: false,
      viewCount: 22,
      responseCount: 3,
    ),
    
    // More BUYING NOW demands
    Demand(
      id: 'demand-009',
      buyerId: 'buyer-010',
      cropType: CropType.teff,
      preferredGrade: QualityGrade.grade2,
      minimumQuantityKg: 500,
      maximumQuantityKg: 2000,
      priceOfferPerKg: 67.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      transportProvided: false,
      viewCount: 31,
      responseCount: 4,
    ),
    Demand(
      id: 'demand-010',
      buyerId: 'buyer-003',
      cropType: CropType.wheat,
      preferredGrade: QualityGrade.standard,
      minimumQuantityKg: 5000,
      maximumQuantityKg: 15000,
      priceOfferPerKg: 56.50,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      additionalNotes: 'Large quantity needed for milling. Long-term contract possible.',
      transportProvided: true,
      acceptedGrades: [QualityGrade.standard, QualityGrade.grade3],
      viewCount: 67,
      responseCount: 11,
    ),
    
    // FILLED demands (for history)
    Demand(
      id: 'demand-011',
      buyerId: 'buyer-001',
      cropType: CropType.coffee,
      preferredGrade: QualityGrade.grade1,
      minimumQuantityKg: 1000,
      maximumQuantityKg: 3000,
      priceOfferPerKg: 93.00,
      status: BuyingStatus.filled,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      viewCount: 78,
      responseCount: 14,
    ),
    
    // More active demands
    Demand(
      id: 'demand-012',
      buyerId: 'buyer-007',
      cropType: CropType.beans,
      preferredGrade: QualityGrade.standard,
      minimumQuantityKg: 300,
      maximumQuantityKg: 1000,
      priceOfferPerKg: 35.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Nekemte',
      createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      additionalNotes: 'Red kidney beans preferred.',
      transportProvided: false,
      viewCount: 19,
      responseCount: 2,
    ),
    Demand(
      id: 'demand-013',
      buyerId: 'buyer-002',
      cropType: CropType.sorghum,
      preferredGrade: QualityGrade.grade2,
      minimumQuantityKg: 1500,
      maximumQuantityKg: 5000,
      priceOfferPerKg: 40.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      transportProvided: true,
      viewCount: 36,
      responseCount: 5,
    ),
    Demand(
      id: 'demand-014',
      buyerId: 'buyer-004',
      cropType: CropType.coffee,
      preferredGrade: QualityGrade.grade2,
      minimumQuantityKg: 600,
      maximumQuantityKg: 2500,
      priceOfferPerKg: 88.00,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Nekemte',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      additionalNotes: 'Grade 2 arabica acceptable for blending.',
      transportProvided: true,
      acceptedGrades: [QualityGrade.grade2],
      viewCount: 27,
      responseCount: 4,
    ),
    Demand(
      id: 'demand-015',
      buyerId: 'buyer-010',
      cropType: CropType.potato,
      preferredGrade: QualityGrade.standard,
      minimumQuantityKg: 1000,
      maximumQuantityKg: 3000,
      priceOfferPerKg: 24.50,
      status: BuyingStatus.buyingNow,
      pickupLocation: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      transportProvided: false,
      viewCount: 24,
      responseCount: 3,
    ),
  ];

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Get all buyers
  static List<Buyer> getAllBuyers() {
    return List.from(_mockBuyers);
  }

  /// Get all active demands (buying now)
  static List<Demand> getActiveDemands() {
    return _mockDemands
        .where((d) => d.status == BuyingStatus.buyingNow && !d.isExpired)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all demands (including paused, filled, expired)
  static List<Demand> getAllDemands() {
    return List.from(_mockDemands)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get buyer by ID
  static Buyer? getBuyerById(String buyerId) {
    try {
      return _mockBuyers.firstWhere((b) => b.id == buyerId);
    } catch (e) {
      return null;
    }
  }

  /// Get demands by buyer ID
  static List<Demand> getDemandsByBuyer(String buyerId) {
    return _mockDemands.where((d) => d.buyerId == buyerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ============================================================================
  // FILTERING LOGIC
  // ============================================================================

  /// Filter buyers by type
  static List<Buyer> filterBuyersByType(BuyerType type) {
    return _mockBuyers.where((b) => b.buyerType == type).toList();
  }

  /// Filter buyers by location
  static List<Buyer> filterBuyersByLocation(String location) {
    return _mockBuyers
        .where((b) => b.location.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  /// Filter buyers by verification status
  static List<Buyer> filterVerifiedBuyers() {
    return _mockBuyers.where((b) => b.isVerified).toList();
  }

  /// Filter buyers by minimum reliability score
  static List<Buyer> filterBuyersByReliability(double minScore) {
    return _mockBuyers.where((b) => b.reliabilityScore >= minScore).toList();
  }

  /// Filter active buyers (active within last 7 days)
  static List<Buyer> filterActiveBuyers() {
    return _mockBuyers.where((b) => b.isActive).toList();
  }

  /// Filter demands by crop type
  static List<Demand> filterDemandsByCrop(CropType cropType) {
    return _mockDemands.where((d) => d.cropType == cropType).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter demands by location
  static List<Demand> filterDemandsByLocation(String location) {
    return _mockDemands
        .where((d) =>
            d.pickupLocation.toLowerCase().contains(location.toLowerCase()))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter demands by minimum quantity range
  static List<Demand> filterDemandsByQuantity(double minKg, double maxKg) {
    return _mockDemands
        .where((d) =>
            d.minimumQuantityKg <= maxKg && d.maximumQuantityKg >= minKg)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter demands with transport provided
  static List<Demand> filterDemandsWithTransport() {
    return _mockDemands.where((d) => d.transportProvided).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Filter urgent demands (expires within 24 hours)
  static List<Demand> filterUrgentDemands() {
    return _mockDemands
        .where((d) => d.status == BuyingStatus.buyingNow && d.isUrgent)
        .toList()
      ..sort((a, b) => a.hoursUntilExpiry.compareTo(b.hoursUntilExpiry));
  }

  /// Complex filter: Active demands by crop, location, and grade
  static List<Demand> filterDemandsAdvanced({
    CropType? cropType,
    String? location,
    QualityGrade? grade,
    bool? transportProvided,
    double? minPrice,
    double? maxPrice,
  }) {
    var filtered = getActiveDemands();

    if (cropType != null) {
      filtered = filtered.where((d) => d.cropType == cropType).toList();
    }

    if (location != null && location.isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.pickupLocation.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    if (grade != null) {
      filtered = filtered
          .where((d) =>
              d.preferredGrade == grade ||
              (d.acceptedGrades?.contains(grade) ?? false))
          .toList();
    }

    if (transportProvided != null) {
      filtered =
          filtered.where((d) => d.transportProvided == transportProvided).toList();
    }

    if (minPrice != null) {
      filtered =
          filtered.where((d) => d.priceOfferPerKg >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered =
          filtered.where((d) => d.priceOfferPerKg <= maxPrice).toList();
    }

    return filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get marketplace statistics
  static Map<String, dynamic> getMarketplaceStats() {
    final allDemands = _mockDemands;
    final activeDemands = getActiveDemands();
    final verifiedBuyers = filterVerifiedBuyers();

    return {
      'totalBuyers': _mockBuyers.length,
      'verifiedBuyers': verifiedBuyers.length,
      'activeBuyers': filterActiveBuyers().length,
      'totalDemands': allDemands.length,
      'activeDemands': activeDemands.length,
      'urgentDemands': filterUrgentDemands().length,
      'averageBuyerReliability':
          _mockBuyers.fold(0.0, (sum, b) => sum + b.reliabilityScore) /
              _mockBuyers.length,
      'totalViews': allDemands.fold(0, (sum, d) => sum + d.viewCount),
      'totalResponses': allDemands.fold(0, (sum, d) => sum + d.responseCount),
    };
  }
}
