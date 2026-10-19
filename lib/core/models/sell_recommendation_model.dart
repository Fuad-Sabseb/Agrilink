import 'market_model.dart';
import 'crop_plot_model.dart';

/// Sell Recommendation Model
/// Net revenue calculation: (Market Price * Quantity) - Transport Cost - Checkpoint Fees
class SellRecommendation {
  final Market market;
  final CropType cropType;
  final QualityGrade grade;
  final double quantityKg;
  final double pricePerKg;
  final double distanceKm;
  final double transportCostPerKm;
  final double checkpointFees;
  final DateTime calculatedAt;

  SellRecommendation({
    required this.market,
    required this.cropType,
    required this.grade,
    required this.quantityKg,
    required this.pricePerKg,
    required this.distanceKm,
    required this.transportCostPerKm,
    required this.checkpointFees,
    required this.calculatedAt,
  });

  /// Gross Revenue = Market Price * Quantity
  double get grossRevenue {
    return pricePerKg * quantityKg;
  }

  /// Transport Cost = Distance * Cost per km * (Quantity factor)
  /// Simplified: Base cost + per-ton-km rate
  double get transportCost {
    final quantityTons = quantityKg / 1000.0;
    // Base transport cost model: ETB 10/km + ETB 5/km per ton
    final baseCost = distanceKm * transportCostPerKm;
    final weightFactor = distanceKm * 5.0 * quantityTons;
    return baseCost + weightFactor;
  }

  /// Total Cost = Transport + Checkpoint Fees
  double get totalCost {
    return transportCost + checkpointFees;
  }

  /// Net Revenue = Gross Revenue - Total Cost
  double get netRevenue {
    return grossRevenue - totalCost;
  }

  /// Net Revenue per kg (for comparison)
  double get netRevenuePerKg {
    return netRevenue / quantityKg;
  }

  /// Profit margin percentage
  double get profitMarginPercent {
    if (grossRevenue == 0) return 0;
    return (netRevenue / grossRevenue) * 100;
  }

  /// Is this recommendation profitable?
  bool get isProfitable {
    return netRevenue > 0;
  }

  /// Rank score (for sorting recommendations)
  /// Higher is better
  double get rankScore {
    // Primary: net revenue
    // Secondary: profit margin
    // Tertiary: distance (shorter is better, minor weight)
    final revenueScore = netRevenue;
    final marginBonus = profitMarginPercent * 10;
    final distancePenalty = distanceKm * 5;
    return revenueScore + marginBonus - distancePenalty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'market': market.toJson(),
      'cropType': cropType.name,
      'grade': grade.name,
      'quantityKg': quantityKg,
      'pricePerKg': pricePerKg,
      'distanceKm': distanceKm,
      'transportCostPerKm': transportCostPerKm,
      'checkpointFees': checkpointFees,
      'calculatedAt': calculatedAt.toIso8601String(),
      'grossRevenue': grossRevenue,
      'transportCost': transportCost,
      'totalCost': totalCost,
      'netRevenue': netRevenue,
      'netRevenuePerKg': netRevenuePerKg,
      'profitMarginPercent': profitMarginPercent,
    };
  }

  /// Create from JSON
  factory SellRecommendation.fromJson(Map<String, dynamic> json) {
    return SellRecommendation(
      market: Market.fromJson(json['market'] as Map<String, dynamic>),
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['cropType'],
        orElse: () => CropType.other,
      ),
      grade: QualityGrade.values.firstWhere(
        (e) => e.name == json['grade'],
        orElse: () => QualityGrade.standard,
      ),
      quantityKg: (json['quantityKg'] as num).toDouble(),
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      transportCostPerKm: (json['transportCostPerKm'] as num).toDouble(),
      checkpointFees: (json['checkpointFees'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}

/// Transport Cost Estimates (ETB per km)
/// Based on field research in Jimma Zone
class TransportCostEstimates {
  /// Base cost per km (for truck/pickup)
  static const double baseRatePerKm = 10.0;

  /// Additional cost per ton-km
  static const double perTonKmRate = 5.0;

  /// Checkpoint/transit fees by route
  static double getCheckpointFees(String fromWoreda, String toMarket) {
    // Simplified model: fees increase with distance from Jimma
    if (toMarket.contains('Jimma')) {
      // Local to Jimma Town: minimal fees
      return 150.0;
    } else if (toMarket.contains('Nekemte')) {
      // Jimma to Nekemte: 150km, multiple checkpoints
      return 450.0;
    } else if (toMarket.contains('Agaro')) {
      // Jimma to Agaro: 55km, moderate fees
      return 250.0;
    } else {
      // Default estimate
      return 200.0;
    }
  }

  /// Calculate estimated transport cost
  static double calculateTransportCost({
    required double distanceKm,
    required double quantityKg,
  }) {
    final quantityTons = quantityKg / 1000.0;
    final baseCost = distanceKm * baseRatePerKm;
    final weightFactor = distanceKm * perTonKmRate * quantityTons;
    return baseCost + weightFactor;
  }
}
