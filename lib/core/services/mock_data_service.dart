import '../models/market_model.dart';
import '../models/price_model.dart';
import '../models/crop_plot_model.dart';

/// Mock Data Service
/// Provides realistic data for Jimma Zone markets and prices
/// Based on research from AgriLink Project Proposal
class MockDataService {
  // ============================================================================
  // MARKETS
  // ============================================================================

  /// Get all markets (Jimma Town + secondary markets)
  static List<Market> getAllMarkets() {
    return [
      // Primary Market: Jimma Town
      Market(
        id: 'market_jimma_town',
        name: 'Jimma Town Market',
        woreda: 'Jimma Town',
        latitude: 7.6731,
        longitude: 36.8355,
        isPrimary: true,
        distanceFromJimmaKm: 0.0,
      ),

      // Secondary Market: Nekemte
      Market(
        id: 'market_nekemte',
        name: 'Nekemte Market',
        woreda: 'Nekemte',
        latitude: 9.0833,
        longitude: 36.5500,
        isPrimary: false,
        distanceFromJimmaKm: 150.0,
      ),

      // Secondary Market: Agaro
      Market(
        id: 'market_agaro',
        name: 'Agaro Market',
        woreda: 'Agaro',
        latitude: 7.8500,
        longitude: 36.6000,
        isPrimary: false,
        distanceFromJimmaKm: 55.0,
      ),
    ];
  }

  /// Get market by ID
  static Market? getMarketById(String marketId) {
    try {
      return getAllMarkets().firstWhere((m) => m.id == marketId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // PRICES (Based on Project Proposal Section 8 example)
  // ============================================================================

  /// Get current prices for all markets and crops
  /// Example from proposal: Potato @ Jimma 25 ETB/kg, Nekemte 28 ETB/kg, Addis 32 ETB/kg
  static List<CropPrice> getCurrentPrices() {
    final now = DateTime.now();
    final prices = <CropPrice>[];

    // -------------------------------------------------------------------------
    // COFFEE PRICES (Buna) - Jimma Zone's primary cash crop
    // -------------------------------------------------------------------------
    prices.addAll([
      // Jimma Town - Coffee
      CropPrice(
        id: 'price_coffee_jimma_premium',
        marketId: 'market_jimma_town',
        cropType: CropType.coffee,
        grade: QualityGrade.premium,
        pricePerKg: 92.50,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: 2.8,
      ),
      CropPrice(
        id: 'price_coffee_jimma_grade1',
        marketId: 'market_jimma_town',
        cropType: CropType.coffee,
        grade: QualityGrade.grade1,
        pricePerKg: 87.50,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: 2.5,
      ),
      CropPrice(
        id: 'price_coffee_jimma_grade2',
        marketId: 'market_jimma_town',
        cropType: CropType.coffee,
        grade: QualityGrade.grade2,
        pricePerKg: 78.00,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: 1.2,
      ),

      // Nekemte - Coffee (higher prices, export route)
      CropPrice(
        id: 'price_coffee_nekemte_premium',
        marketId: 'market_nekemte',
        cropType: CropType.coffee,
        grade: QualityGrade.premium,
        pricePerKg: 98.00,
        recordedAt: now.subtract(const Duration(hours: 5)),
        source: 'field_collection',
        priceChangePercent: 3.2,
      ),
      CropPrice(
        id: 'price_coffee_nekemte_grade1',
        marketId: 'market_nekemte',
        cropType: CropType.coffee,
        grade: QualityGrade.grade1,
        pricePerKg: 93.00,
        recordedAt: now.subtract(const Duration(hours: 5)),
        source: 'field_collection',
        priceChangePercent: 2.9,
      ),

      // Agaro - Coffee (moderate prices)
      CropPrice(
        id: 'price_coffee_agaro_grade1',
        marketId: 'market_agaro',
        cropType: CropType.coffee,
        grade: QualityGrade.grade1,
        pricePerKg: 89.50,
        recordedAt: now.subtract(const Duration(hours: 4)),
        source: 'field_collection',
        priceChangePercent: 2.2,
      ),
    ]);

    // -------------------------------------------------------------------------
    // MAIZE PRICES (Boqqoo)
    // -------------------------------------------------------------------------
    prices.addAll([
      // Jimma Town
      CropPrice(
        id: 'price_maize_jimma_grade1',
        marketId: 'market_jimma_town',
        cropType: CropType.maize,
        grade: QualityGrade.grade1,
        pricePerKg: 42.30,
        recordedAt: now.subtract(const Duration(hours: 3)),
        source: 'field_collection',
        priceChangePercent: -1.2,
      ),
      CropPrice(
        id: 'price_maize_jimma_standard',
        marketId: 'market_jimma_town',
        cropType: CropType.maize,
        grade: QualityGrade.standard,
        pricePerKg: 38.50,
        recordedAt: now.subtract(const Duration(hours: 3)),
        source: 'field_collection',
        priceChangePercent: -0.8,
      ),

      // Nekemte
      CropPrice(
        id: 'price_maize_nekemte_grade1',
        marketId: 'market_nekemte',
        cropType: CropType.maize,
        grade: QualityGrade.grade1,
        pricePerKg: 45.80,
        recordedAt: now.subtract(const Duration(hours: 6)),
        source: 'field_collection',
        priceChangePercent: 0.5,
      ),

      // Agaro
      CropPrice(
        id: 'price_maize_agaro_grade1',
        marketId: 'market_agaro',
        cropType: CropType.maize,
        grade: QualityGrade.grade1,
        pricePerKg: 43.50,
        recordedAt: now.subtract(const Duration(hours: 4)),
        source: 'field_collection',
        priceChangePercent: -0.5,
      ),
    ]);

    // -------------------------------------------------------------------------
    // TEFF PRICES (Xaafii)
    // -------------------------------------------------------------------------
    prices.addAll([
      // Jimma Town
      CropPrice(
        id: 'price_teff_jimma_premium',
        marketId: 'market_jimma_town',
        cropType: CropType.teff,
        grade: QualityGrade.premium,
        pricePerKg: 68.00,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: 0.8,
      ),
      CropPrice(
        id: 'price_teff_jimma_grade1',
        marketId: 'market_jimma_town',
        cropType: CropType.teff,
        grade: QualityGrade.grade1,
        pricePerKg: 65.00,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: 0.8,
      ),

      // Nekemte
      CropPrice(
        id: 'price_teff_nekemte_premium',
        marketId: 'market_nekemte',
        cropType: CropType.teff,
        grade: QualityGrade.premium,
        pricePerKg: 72.50,
        recordedAt: now.subtract(const Duration(hours: 5)),
        source: 'field_collection',
        priceChangePercent: 1.5,
      ),

      // Agaro
      CropPrice(
        id: 'price_teff_agaro_grade1',
        marketId: 'market_agaro',
        cropType: CropType.teff,
        grade: QualityGrade.grade1,
        pricePerKg: 66.80,
        recordedAt: now.subtract(const Duration(hours: 4)),
        source: 'field_collection',
        priceChangePercent: 1.0,
      ),
    ]);

    // -------------------------------------------------------------------------
    // WHEAT PRICES (Qamadii)
    // -------------------------------------------------------------------------
    prices.addAll([
      // Jimma Town
      CropPrice(
        id: 'price_wheat_jimma_grade1',
        marketId: 'market_jimma_town',
        cropType: CropType.wheat,
        grade: QualityGrade.grade1,
        pricePerKg: 55.80,
        recordedAt: now.subtract(const Duration(hours: 3)),
        source: 'field_collection',
        priceChangePercent: 1.5,
      ),

      // Nekemte
      CropPrice(
        id: 'price_wheat_nekemte_grade1',
        marketId: 'market_nekemte',
        cropType: CropType.wheat,
        grade: QualityGrade.grade1,
        pricePerKg: 58.50,
        recordedAt: now.subtract(const Duration(hours: 6)),
        source: 'field_collection',
        priceChangePercent: 2.0,
      ),

      // Agaro
      CropPrice(
        id: 'price_wheat_agaro_grade1',
        marketId: 'market_agaro',
        cropType: CropType.wheat,
        grade: QualityGrade.grade1,
        pricePerKg: 57.00,
        recordedAt: now.subtract(const Duration(hours: 4)),
        source: 'field_collection',
        priceChangePercent: 1.8,
      ),
    ]);

    // -------------------------------------------------------------------------
    // POTATO PRICES (Dinnichii) - Using proposal example
    // -------------------------------------------------------------------------
    prices.addAll([
      // Jimma Town (25 ETB/kg from proposal example)
      CropPrice(
        id: 'price_potato_jimma_grade1',
        marketId: 'market_jimma_town',
        cropType: CropType.potato,
        grade: QualityGrade.grade1,
        pricePerKg: 25.00,
        recordedAt: now.subtract(const Duration(hours: 2)),
        source: 'field_collection',
        priceChangePercent: -0.5,
      ),

      // Nekemte (28 ETB/kg from proposal example)
      CropPrice(
        id: 'price_potato_nekemte_grade1',
        marketId: 'market_nekemte',
        cropType: CropType.potato,
        grade: QualityGrade.grade1,
        pricePerKg: 28.00,
        recordedAt: now.subtract(const Duration(hours: 5)),
        source: 'field_collection',
        priceChangePercent: 0.2,
      ),

      // Agaro
      CropPrice(
        id: 'price_potato_agaro_grade1',
        marketId: 'market_agaro',
        cropType: CropType.potato,
        grade: QualityGrade.grade1,
        pricePerKg: 26.50,
        recordedAt: now.subtract(const Duration(hours: 4)),
        source: 'field_collection',
        priceChangePercent: 0.0,
      ),
    ]);

    return prices;
  }

  /// Get prices for specific crop and grade
  static List<CropPrice> getPricesForCrop({
    required CropType cropType,
    QualityGrade? grade,
  }) {
    final allPrices = getCurrentPrices();
    return allPrices.where((price) {
      final cropMatch = price.cropType == cropType;
      final gradeMatch = grade == null || price.grade == grade;
      return cropMatch && gradeMatch;
    }).toList();
  }

  /// Get price for specific market, crop, and grade
  static CropPrice? getPrice({
    required String marketId,
    required CropType cropType,
    required QualityGrade grade,
  }) {
    try {
      return getCurrentPrices().firstWhere(
        (price) =>
            price.marketId == marketId &&
            price.cropType == cropType &&
            price.grade == grade,
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // WOREDAS
  // ============================================================================

  /// Get list of woredas in Jimma Zone
  static List<String> getJimmaZoneWoredas() {
    return [
      'Jimma Town',
      'Agaro',
      'Seka Chekorsa',
      'Kersa',
      'Mana',
      'Gomma',
      'Limmu Kosa',
      'Sokoru',
      'Tiro Afeta',
      'Omo Nada',
      'Shabe Sombo',
      'Sigmo',
      'Setema',
      'Dedo',
      'Gera',
      'Guma',
      'Limmu Seka',
    ];
  }
}
