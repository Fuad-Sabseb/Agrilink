import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/produce_model.dart';

/// ProduceService - Manages produce listings with offline support
/// Features:
/// - Full CRUD operations with validation
/// - Search and filter capabilities
/// - Offline-first with Hive caching
/// - Mock data generation for testing
/// - Error handling and logging
class ProduceService {
  static final ProduceService _instance = ProduceService._internal();
  factory ProduceService() => _instance;
  ProduceService._internal();

  Box<ProduceModel>? _produceBox;
  final _uuid = const Uuid();
  bool _mockDataInitialized = false;

  /// Initialize service and load mock data
  Future<void> initialize() async {
    try {
      _produceBox = await Hive.openBox<ProduceModel>('produce');
      
      // Load mock data if box is empty
      if (_produceBox!.isEmpty && !_mockDataInitialized) {
        await _initializeMockData();
        _mockDataInitialized = true;
      }
    } catch (e) {
      throw Exception('Failed to initialize ProduceService: $e');
    }
  }

  Box<ProduceModel> get _box {
    if (_produceBox == null || !_produceBox!.isOpen) {
      throw Exception('ProduceService not initialized. Call initialize() first.');
    }
    return _produceBox!;
  }

  // ============================================================
  // CREATE Operations
  // ============================================================

  /// Add new produce listing with validation
  Future<ProduceModel> addProduce({
    required String farmerId,
    required String farmerName,
    required String cropName,
    required String cropType,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String description,
    required String location,
    String? qualityGrade,
    DateTime? harvestDate,
    String? imageUrl,
    List<String>? imageUrls,
    bool isOrganic = false,
  }) async {
    // Validation
    _validateProduceData(
      cropName: cropName,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      unit: unit,
    );

    final id = _uuid.v4();
    final produce = ProduceModel(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      cropName: cropName,
      cropType: cropType,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      description: description,
      status: 'available',
      qualityGrade: qualityGrade,
      harvestDate: harvestDate,
      location: location,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      isOrganic: isOrganic,
      createdAt: DateTime.now(),
    );

    try {
      await _box.put(id, produce);
      return produce;
    } catch (e) {
      throw Exception('Failed to add produce: $e');
    }
  }

  // ============================================================
  // READ Operations
  // ============================================================

  /// Get produce by ID
  ProduceModel? getProduceById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get produce by ID: $e');
    }
  }

  /// Get all produce
  List<ProduceModel> getAllProduce() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to get all produce: $e');
    }
  }

  /// Get all available produce (status = 'available', quantity > 0)
  List<ProduceModel> getAllAvailableProduce() {
    try {
      return _box.values
          .where((p) => p.status == 'available' && p.quantity > 0)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get available produce: $e');
    }
  }

  /// Get produce by farmer ID
  List<ProduceModel> getProduceByFarmer(String farmerId) {
    try {
      return _box.values
          .where((p) => p.farmerId == farmerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get produce by farmer: $e');
    }
  }

  /// Get produce by status
  List<ProduceModel> getProduceByStatus(String status) {
    try {
      return _box.values
          .where((p) => p.status == status)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get produce by status: $e');
    }
  }

  /// Get produce by crop type
  List<ProduceModel> getProduceByCropType(String cropType) {
    try {
      return _box.values
          .where((p) => p.cropType.toLowerCase() == cropType.toLowerCase())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get produce by crop type: $e');
    }
  }

  /// Get produce by location
  List<ProduceModel> getProduceByLocation(String location) {
    try {
      return _box.values
          .where((p) => p.location.toLowerCase().contains(location.toLowerCase()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get produce by location: $e');
    }
  }

  /// Get organic produce only
  List<ProduceModel> getOrganicProduce() {
    try {
      return _box.values
          .where((p) => p.isOrganic && p.status == 'available')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get organic produce: $e');
    }
  }

  /// Get recently harvested produce (within 30 days)
  List<ProduceModel> getRecentHarvestProduce() {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return _box.values
          .where((p) =>
              p.harvestDate != null &&
              p.harvestDate!.isAfter(thirtyDaysAgo) &&
              p.status == 'available')
          .toList()
        ..sort((a, b) => b.harvestDate!.compareTo(a.harvestDate!));
    } catch (e) {
      throw Exception('Failed to get recent harvest produce: $e');
    }
  }

  // ============================================================
  // SEARCH & FILTER Operations
  // ============================================================

  /// Search produce by crop name or description
  List<ProduceModel> searchProduce(String query) {
    try {
      if (query.isEmpty) return getAllAvailableProduce();

      final lowerQuery = query.toLowerCase();
      return _box.values
          .where((p) =>
              p.cropName.toLowerCase().contains(lowerQuery) ||
              p.description.toLowerCase().contains(lowerQuery) ||
              p.location.toLowerCase().contains(lowerQuery))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to search produce: $e');
    }
  }

  /// Filter produce with multiple criteria
  List<ProduceModel> filterProduce({
    String? cropType,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? qualityGrade,
    bool? isOrganic,
    String? status,
  }) {
    try {
      var results = _box.values.toList();

      if (cropType != null) {
        results = results
            .where((p) => p.cropType.toLowerCase() == cropType.toLowerCase())
            .toList();
      }

      if (location != null) {
        results = results
            .where((p) => p.location.toLowerCase().contains(location.toLowerCase()))
            .toList();
      }

      if (minPrice != null) {
        results = results.where((p) => p.pricePerUnit >= minPrice).toList();
      }

      if (maxPrice != null) {
        results = results.where((p) => p.pricePerUnit <= maxPrice).toList();
      }

      if (qualityGrade != null) {
        results = results.where((p) => p.qualityGrade == qualityGrade).toList();
      }

      if (isOrganic != null) {
        results = results.where((p) => p.isOrganic == isOrganic).toList();
      }

      if (status != null) {
        results = results.where((p) => p.status == status).toList();
      }

      return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to filter produce: $e');
    }
  }

  /// Sort produce by various criteria
  List<ProduceModel> sortProduce(
    List<ProduceModel> produce,
    String sortBy, {
    bool ascending = true,
  }) {
    final sorted = List<ProduceModel>.from(produce);

    switch (sortBy) {
      case 'price':
        sorted.sort((a, b) => ascending
            ? a.pricePerUnit.compareTo(b.pricePerUnit)
            : b.pricePerUnit.compareTo(a.pricePerUnit));
        break;
      case 'quantity':
        sorted.sort((a, b) => ascending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity));
        break;
      case 'date':
        sorted.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
        sorted.sort((a, b) => ascending
            ? a.cropName.compareTo(b.cropName)
            : b.cropName.compareTo(a.cropName));
        break;
      default:
        // Default: newest first
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sorted;
  }

  // ============================================================
  // UPDATE Operations
  // ============================================================

  /// Update produce information
  Future<void> updateProduce({
    required String id,
    String? cropName,
    String? cropType,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    String? description,
    String? qualityGrade,
    DateTime? harvestDate,
    String? location,
    String? imageUrl,
    List<String>? imageUrls,
    bool? isOrganic,
  }) async {
    try {
      final produce = getProduceById(id);
      if (produce == null) {
        throw Exception('Produce not found with ID: $id');
      }

      // Validate updated data
      if (quantity != null || pricePerUnit != null) {
        _validateProduceData(
          cropName: cropName ?? produce.cropName,
          quantity: quantity ?? produce.quantity,
          pricePerUnit: pricePerUnit ?? produce.pricePerUnit,
          unit: unit ?? produce.unit,
        );
      }

      final updated = produce.copyWith(
        cropName: cropName,
        cropType: cropType,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        description: description,
        qualityGrade: qualityGrade,
        harvestDate: harvestDate,
        location: location,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        isOrganic: isOrganic,
        updatedAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update produce: $e');
    }
  }

  /// Update produce status
  Future<void> updateProduceStatus(String id, String status) async {
    try {
      final produce = getProduceById(id);
      if (produce == null) {
        throw Exception('Produce not found with ID: $id');
      }

      if (!['available', 'reserved', 'sold', 'expired'].contains(status)) {
        throw Exception('Invalid status: $status');
      }

      final updated = produce.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update produce status: $e');
    }
  }

  /// Deduct quantity from produce (e.g., after purchase)
  /// Automatically sets status to 'sold' if quantity reaches 0
  Future<void> deductQuantity(String id, double amount) async {
    try {
      final produce = getProduceById(id);
      if (produce == null) {
        throw Exception('Produce not found with ID: $id');
      }

      if (amount <= 0) {
        throw Exception('Deduction amount must be positive');
      }

      if (amount > produce.quantity) {
        throw Exception('Cannot deduct more than available quantity');
      }

      final newQuantity = produce.quantity - amount;
      final newStatus = newQuantity <= 0 ? 'sold' : produce.status;

      final updated = produce.copyWith(
        quantity: newQuantity,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to deduct quantity: $e');
    }
  }

  // ============================================================
  // DELETE Operations
  // ============================================================

  /// Delete produce by ID
  Future<void> deleteProduce(String id) async {
    try {
      final produce = getProduceById(id);
      if (produce == null) {
        throw Exception('Produce not found with ID: $id');
      }

      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete produce: $e');
    }
  }

  /// Delete all produce by farmer ID
  Future<void> deleteProduceByFarmer(String farmerId) async {
    try {
      final farmerProduce = getProduceByFarmer(farmerId);
      for (final produce in farmerProduce) {
        await _box.delete(produce.id);
      }
    } catch (e) {
      throw Exception('Failed to delete farmer produce: $e');
    }
  }

  /// Clear all produce (use with caution!)
  Future<void> clearAllProduce() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear all produce: $e');
    }
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  /// Get statistics for dashboard
  Map<String, dynamic> getProduceStatistics() {
    try {
      final allProduce = _box.values.toList();
      final available = allProduce.where((p) => p.status == 'available').toList();

      return {
        'totalListings': allProduce.length,
        'availableListings': available.length,
        'soldListings': allProduce.where((p) => p.status == 'sold').length,
        'totalValue': available.fold<double>(
            0, (sum, p) => sum + p.totalValue),
        'averagePrice': available.isEmpty
            ? 0.0
            : available.fold<double>(0, (sum, p) => sum + p.pricePerUnit) /
                available.length,
        'organicCount': available.where((p) => p.isOrganic).length,
        'cropTypes': available.map((p) => p.cropType).toSet().length,
      };
    } catch (e) {
      throw Exception('Failed to get produce statistics: $e');
    }
  }

  // ============================================================
  // VALIDATION & HELPERS
  // ============================================================

  void _validateProduceData({
    required String cropName,
    required double quantity,
    required double pricePerUnit,
    required String unit,
  }) {
    if (cropName.trim().isEmpty) {
      throw Exception('Crop name cannot be empty');
    }

    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    if (pricePerUnit <= 0) {
      throw Exception('Price per unit must be greater than 0');
    }

    if (unit.trim().isEmpty) {
      throw Exception('Unit cannot be empty');
    }

    final validUnits = ['kg', 'quintal', 'ton', 'bag', 'liter', 'piece'];
    if (!validUnits.contains(unit.toLowerCase())) {
      throw Exception('Invalid unit. Must be one of: ${validUnits.join(', ')}');
    }
  }

  // ============================================================
  // MOCK DATA GENERATION
  // ============================================================

  /// Initialize mock produce data for testing
  Future<void> _initializeMockData() async {
    final mockProduce = _generateMockProduce();
    for (final produce in mockProduce) {
      await _box.put(produce.id, produce);
    }
  }

  /// Generate 25+ mock produce items with Ethiopian crops
  List<ProduceModel> _generateMockProduce() {
    final now = DateTime.now();
    
    return [
      // Grains
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_001',
        farmerName: 'Abebe Kebede',
        cropName: 'Teff (White)',
        cropType: 'grain',
        quantity: 500,
        unit: 'kg',
        pricePerUnit: 85.0,
        description: 'Premium white teff, Grade A quality, freshly harvested',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 10)),
        location: 'Addis Ababa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_002',
        farmerName: 'Almaz Tesfaye',
        cropName: 'Teff (Red)',
        cropType: 'grain',
        quantity: 300,
        unit: 'kg',
        pricePerUnit: 75.0,
        description: 'Red teff, excellent for injera making',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 15)),
        location: 'Debre Zeit',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_003',
        farmerName: 'Girma Hailu',
        cropName: 'Wheat',
        cropType: 'grain',
        quantity: 1000,
        unit: 'kg',
        pricePerUnit: 45.0,
        description: 'High-quality wheat for bread and pasta production',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 20)),
        location: 'Arsi',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_004',
        farmerName: 'Tigist Bekele',
        cropName: 'Barley',
        cropType: 'grain',
        quantity: 800,
        unit: 'kg',
        pricePerUnit: 40.0,
        description: 'Premium barley for tella and food processing',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 18)),
        location: 'Gonder',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_005',
        farmerName: 'Mulugeta Assefa',
        cropName: 'Maize (Yellow)',
        cropType: 'grain',
        quantity: 1200,
        unit: 'kg',
        pricePerUnit: 30.0,
        description: 'Fresh yellow maize, suitable for both human and animal feed',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 8)),
        location: 'Jimma',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Legumes
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_006',
        farmerName: 'Marta Tadesse',
        cropName: 'Chickpeas (Shimbra)',
        cropType: 'legume',
        quantity: 400,
        unit: 'kg',
        pricePerUnit: 65.0,
        description: 'Premium chickpeas for shiro and traditional dishes',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 25)),
        location: 'Gojjam',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_007',
        farmerName: 'Solomon Girma',
        cropName: 'Fava Beans (Bakela)',
        cropType: 'legume',
        quantity: 600,
        unit: 'kg',
        pricePerUnit: 55.0,
        description: 'Large fava beans, perfect for ful and traditional meals',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 12)),
        location: 'Shewa',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_008',
        farmerName: 'Hanna Mekonnen',
        cropName: 'Lentils (Misir)',
        cropType: 'legume',
        quantity: 350,
        unit: 'kg',
        pricePerUnit: 70.0,
        description: 'Red lentils for misir wot, Grade A quality',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 14)),
        location: 'Wollo',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_009',
        farmerName: 'Dawit Gebre',
        cropName: 'White Pea Beans (Ater)',
        cropType: 'legume',
        quantity: 500,
        unit: 'kg',
        pricePerUnit: 60.0,
        description: 'Clean white pea beans for export and local market',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 22)),
        location: 'Sidama',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 14)),
      ),

      // Vegetables
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_010',
        farmerName: 'Selamawit Yohannes',
        cropName: 'Tomatoes',
        cropType: 'vegetable',
        quantity: 200,
        unit: 'kg',
        pricePerUnit: 25.0,
        description: 'Fresh red tomatoes, perfect for salads and cooking',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 2)),
        location: 'Hawassa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_011',
        farmerName: 'Berhanu Taye',
        cropName: 'Onions (Red)',
        cropType: 'vegetable',
        quantity: 400,
        unit: 'kg',
        pricePerUnit: 20.0,
        description: 'Premium red onions, well-dried and stored',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 30)),
        location: 'Mekelle',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_012',
        farmerName: 'Eyerusalem Alemu',
        cropName: 'Cabbage',
        cropType: 'vegetable',
        quantity: 300,
        unit: 'kg',
        pricePerUnit: 15.0,
        description: 'Fresh green cabbage, organically grown',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 5)),
        location: 'Holeta',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_013',
        farmerName: 'Tesfaye Worku',
        cropName: 'Potatoes',
        cropType: 'vegetable',
        quantity: 900,
        unit: 'kg',
        pricePerUnit: 18.0,
        description: 'High-quality potatoes for cooking and processing',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 20)),
        location: 'Chencha',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_014',
        farmerName: 'Birtukan Desta',
        cropName: 'Carrots',
        cropType: 'vegetable',
        quantity: 250,
        unit: 'kg',
        pricePerUnit: 22.0,
        description: 'Fresh orange carrots, crisp and sweet',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 4)),
        location: 'Addis Ababa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      // Fruits
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_015',
        farmerName: 'Getachew Haile',
        cropName: 'Avocados',
        cropType: 'fruit',
        quantity: 150,
        unit: 'kg',
        pricePerUnit: 80.0,
        description: 'Premium Hass avocados, perfectly ripe',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 3)),
        location: 'Yirgalem',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_016',
        farmerName: 'Rahel Kebede',
        cropName: 'Bananas',
        cropType: 'fruit',
        quantity: 400,
        unit: 'kg',
        pricePerUnit: 30.0,
        description: 'Sweet Ethiopian bananas, fresh from the farm',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 2)),
        location: 'Arba Minch',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_017',
        farmerName: 'Yonas Teferi',
        cropName: 'Mangoes',
        cropType: 'fruit',
        quantity: 200,
        unit: 'kg',
        pricePerUnit: 45.0,
        description: 'Juicy mangoes, perfect for fresh eating or juice',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 5)),
        location: 'Jinka',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_018',
        farmerName: 'Betelhem Yosef',
        cropName: 'Oranges',
        cropType: 'fruit',
        quantity: 300,
        unit: 'kg',
        pricePerUnit: 35.0,
        description: 'Sweet and juicy oranges, high in vitamin C',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 7)),
        location: 'Dire Dawa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),

      // Coffee & Spices
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_019',
        farmerName: 'Tadesse Wolde',
        cropName: 'Coffee (Arabica)',
        cropType: 'spice',
        quantity: 250,
        unit: 'kg',
        pricePerUnit: 180.0,
        description: 'Premium Ethiopian Arabica coffee beans, Grade 1',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 40)),
        location: 'Sidamo',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_020',
        farmerName: 'Meseret Tadesse',
        cropName: 'Korarima (Ethiopian Cardamom)',
        cropType: 'spice',
        quantity: 50,
        unit: 'kg',
        pricePerUnit: 450.0,
        description: 'Rare Ethiopian cardamom, aromatic and flavorful',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 60)),
        location: 'Kaffa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_021',
        farmerName: 'Fikru Belay',
        cropName: 'Ginger',
        cropType: 'spice',
        quantity: 120,
        unit: 'kg',
        pricePerUnit: 95.0,
        description: 'Fresh ginger root, perfect for tea and cooking',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 10)),
        location: 'Wolaita',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_022',
        farmerName: 'Zewditu Assefa',
        cropName: 'Turmeric',
        cropType: 'spice',
        quantity: 80,
        unit: 'kg',
        pricePerUnit: 110.0,
        description: 'Organic turmeric, high curcumin content',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 35)),
        location: 'Gurage',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 28)),
      ),

      // Additional items
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_023',
        farmerName: 'Habtamu Zenebe',
        cropName: 'Sorghum (Red)',
        cropType: 'grain',
        quantity: 700,
        unit: 'kg',
        pricePerUnit: 38.0,
        description: 'Red sorghum for injera and porridge',
        status: 'available',
        qualityGrade: 'B',
        harvestDate: now.subtract(const Duration(days: 28)),
        location: 'Tigray',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_024',
        farmerName: 'Yeshi Mesfin',
        cropName: 'Green Beans',
        cropType: 'vegetable',
        quantity: 180,
        unit: 'kg',
        pricePerUnit: 42.0,
        description: 'Fresh green beans for export and local market',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 3)),
        location: 'Ziway',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_025',
        farmerName: 'Kassahun Getachew',
        cropName: 'Sesame Seeds',
        cropType: 'spice',
        quantity: 300,
        unit: 'kg',
        pricePerUnit: 125.0,
        description: 'Premium sesame seeds for export, well-cleaned',
        status: 'available',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 50)),
        location: 'Humera',
        isOrganic: false,
        createdAt: now.subtract(const Duration(days: 40)),
      ),

      // Some sold/reserved items for variety
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_002',
        farmerName: 'Almaz Tesfaye',
        cropName: 'Teff (White)',
        cropType: 'grain',
        quantity: 0,
        unit: 'kg',
        pricePerUnit: 90.0,
        description: 'Premium white teff - SOLD OUT',
        status: 'sold',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 45)),
        location: 'Debre Zeit',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      ProduceModel(
        id: _uuid.v4(),
        farmerId: 'farmer_010',
        farmerName: 'Selamawit Yohannes',
        cropName: 'Peppers (Green)',
        cropType: 'vegetable',
        quantity: 150,
        unit: 'kg',
        pricePerUnit: 28.0,
        description: 'Fresh green peppers - Reserved for buyer',
        status: 'reserved',
        qualityGrade: 'A',
        harvestDate: now.subtract(const Duration(days: 3)),
        location: 'Hawassa',
        isOrganic: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  /// Reload mock data (for testing/development)
  Future<void> reloadMockData() async {
    await clearAllProduce();
    await _initializeMockData();
  }
}
