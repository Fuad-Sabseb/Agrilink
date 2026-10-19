import '../models/sell_recommendation_model.dart';
import '../models/crop_plot_model.dart';
import 'mock_data_service.dart';

/// Recommendation Service
/// Implements the "Where Should I Sell?" flagship feature
/// Net Revenue = (Market Price * Quantity) - Transport Cost - Checkpoint Fees
class RecommendationService {
  /// Calculate sell recommendations for given crop and quantity
  /// Returns list sorted by net revenue (highest first)
  static Future<List<SellRecommendation>> calculateRecommendations({
    required CropType cropType,
    required QualityGrade grade,
    required double quantityKg,
    String? fromWoreda,
  }) async {
    // Simulate async operation (future: API call)
    await Future.delayed(const Duration(milliseconds: 500));

    final markets = MockDataService.getAllMarkets();
    final recommendations = <SellRecommendation>[];

    for (final market in markets) {
      // Get price for this market
      final price = MockDataService.getPrice(
        marketId: market.id,
        cropType: cropType,
        grade: grade,
      );

      // Skip if no price data available
      if (price == null) continue;

      // Calculate checkpoint fees
      final checkpointFees = TransportCostEstimates.getCheckpointFees(
        fromWoreda ?? 'Jimma Zone',
        market.name,
      );

      // Create recommendation
      final recommendation = SellRecommendation(
        market: market,
        cropType: cropType,
        grade: grade,
        quantityKg: quantityKg,
        pricePerKg: price.pricePerKg,
        distanceKm: market.distanceFromJimmaKm,
        transportCostPerKm: TransportCostEstimates.baseRatePerKm,
        checkpointFees: checkpointFees,
        calculatedAt: DateTime.now(),
      );

      recommendations.add(recommendation);
    }

    // Sort by rank score (net revenue + factors)
    recommendations.sort((a, b) => b.rankScore.compareTo(a.rankScore));

    return recommendations;
  }

  /// Get best recommendation (highest net revenue)
  static Future<SellRecommendation?> getBestRecommendation({
    required CropType cropType,
    required QualityGrade grade,
    required double quantityKg,
    String? fromWoreda,
  }) async {
    final recommendations = await calculateRecommendations(
      cropType: cropType,
      grade: grade,
      quantityKg: quantityKg,
      fromWoreda: fromWoreda,
    );

    return recommendations.isNotEmpty ? recommendations.first : null;
  }

  /// Calculate break-even distance for a given price difference
  /// How far can you travel before higher price is no longer worth it?
  static double calculateBreakEvenDistance({
    required double priceDifferencePerKg,
    required double quantityKg,
    required double transportCostPerKm,
    double checkpointFeeDifference = 0.0,
  }) {
    final extraRevenue = priceDifferencePerKg * quantityKg;
    final netExtraRevenue = extraRevenue - checkpointFeeDifference;

    if (netExtraRevenue <= 0) return 0.0;

    // Solve: netExtraRevenue = transportCost
    // transportCost = (baseCost + weightFactor) * distance
    final quantityTons = quantityKg / 1000.0;
    final costPerKm =
        transportCostPerKm + (TransportCostEstimates.perTonKmRate * quantityTons);

    return netExtraRevenue / costPerKm;
  }

  /// Compare two markets for a specific crop and quantity
  static Future<Map<String, SellRecommendation>> compareMarkets({
    required String marketId1,
    required String marketId2,
    required CropType cropType,
    required QualityGrade grade,
    required double quantityKg,
  }) async {
    final recommendations = await calculateRecommendations(
      cropType: cropType,
      grade: grade,
      quantityKg: quantityKg,
    );

    final market1Rec = recommendations.firstWhere(
      (r) => r.market.id == marketId1,
      orElse: () => recommendations.first,
    );

    final market2Rec = recommendations.firstWhere(
      (r) => r.market.id == marketId2,
      orElse: () => recommendations.last,
    );

    return {
      'market1': market1Rec,
      'market2': market2Rec,
    };
  }
}
