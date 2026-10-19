import 'package:flutter/foundation.dart';
import '../../models/produce_model.dart';
import '../services/produce_service.dart';

/// ProduceProvider - State management for produce data
/// 
/// Provides reactive access to ProduceService with:
/// - Loading states
/// - Error handling
/// - Automatic UI updates via ChangeNotifier
/// - Filtering and search capabilities
class ProduceProvider with ChangeNotifier {
  final ProduceService _produceService = ProduceService();

  List<ProduceModel> _allProduce = [];
  List<ProduceModel> _filteredProduce = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;

  // Getters
  List<ProduceModel> get allProduce => _allProduce;
  List<ProduceModel> get filteredProduce => _filteredProduce;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Map<String, dynamic>? get activeFilters => _activeFilters;
  bool get hasError => _error != null;
  bool get isEmpty => _filteredProduce.isEmpty && !_isLoading;

  /// Initialize provider and load data
  Future<void> initialize() async {
    await _setLoading(true);
    try {
      await _produceService.initialize();
      await loadAllProduce();
    } catch (e) {
      _setError('Failed to initialize produce data: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load all produce
  Future<void> loadAllProduce() async {
    await _setLoading(true);
    try {
      _allProduce = _produceService.getAllProduce();
      _applyFiltersAndSearch();
      _clearError();
    } catch (e) {
      _setError('Failed to load produce: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load available produce only
  Future<void> loadAvailableProduce() async {
    await _setLoading(true);
    try {
      _allProduce = _produceService.getAllAvailableProduce();
      _applyFiltersAndSearch();
      _clearError();
    } catch (e) {
      _setError('Failed to load available produce: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load produce by farmer
  Future<void> loadProduceByFarmer(String farmerId) async {
    await _setLoading(true);
    try {
      _allProduce = _produceService.getProduceByFarmer(farmerId);
      _applyFiltersAndSearch();
      _clearError();
    } catch (e) {
      _setError('Failed to load farmer produce: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Add new produce
  Future<ProduceModel?> addProduce({
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
    await _setLoading(true);
    try {
      final produce = await _produceService.addProduce(
        farmerId: farmerId,
        farmerName: farmerName,
        cropName: cropName,
        cropType: cropType,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        description: description,
        location: location,
        qualityGrade: qualityGrade,
        harvestDate: harvestDate,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        isOrganic: isOrganic,
      );
      await loadAllProduce();
      _clearError();
      return produce;
    } catch (e) {
      _setError('Failed to add produce: $e');
      return null;
    } finally {
      await _setLoading(false);
    }
  }

  /// Update produce
  Future<bool> updateProduce({
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
      await _produceService.updateProduce(
        id: id,
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
      );
      await loadAllProduce();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update produce: $e');
      return false;
    }
  }

  /// Update produce status
  Future<bool> updateProduceStatus(String id, String status) async {
    try {
      await _produceService.updateProduceStatus(id, status);
      await loadAllProduce();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update produce status: $e');
      return false;
    }
  }

  /// Delete produce
  Future<bool> deleteProduce(String id) async {
    try {
      await _produceService.deleteProduce(id);
      await loadAllProduce();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete produce: $e');
      return false;
    }
  }

  /// Search produce
  void searchProduce(String query) {
    _searchQuery = query;
    _applyFiltersAndSearch();
    notifyListeners();
  }

  /// Filter produce
  void filterProduce({
    String? cropType,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? qualityGrade,
    bool? isOrganic,
    String? status,
  }) {
    _activeFilters = {
      if (cropType != null) 'cropType': cropType,
      if (location != null) 'location': location,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (qualityGrade != null) 'qualityGrade': qualityGrade,
      if (isOrganic != null) 'isOrganic': isOrganic,
      if (status != null) 'status': status,
    };
    _applyFiltersAndSearch();
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _activeFilters = null;
    _searchQuery = '';
    _applyFiltersAndSearch();
    notifyListeners();
  }

  /// Sort produce
  void sortProduce(String sortBy, {bool ascending = true}) {
    _filteredProduce = _produceService.sortProduce(
      _filteredProduce,
      sortBy,
      ascending: ascending,
    );
    notifyListeners();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return _produceService.getProduceStatistics();
  }

  // Private helpers
  void _applyFiltersAndSearch() {
    var results = _allProduce;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      results = _produceService.searchProduce(_searchQuery);
    }

    // Apply filters
    if (_activeFilters != null && _activeFilters!.isNotEmpty) {
      results = _produceService.filterProduce(
        cropType: _activeFilters!['cropType'],
        location: _activeFilters!['location'],
        minPrice: _activeFilters!['minPrice'],
        maxPrice: _activeFilters!['maxPrice'],
        qualityGrade: _activeFilters!['qualityGrade'],
        isOrganic: _activeFilters!['isOrganic'],
        status: _activeFilters!['status'],
      );
    }

    _filteredProduce = results;
  }

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Reload mock data (for testing)
  Future<void> reloadMockData() async {
    await _setLoading(true);
    try {
      await _produceService.reloadMockData();
      await loadAllProduce();
    } finally {
      await _setLoading(false);
    }
  }

  /// Load produce for a specific farmer
  Future<void> loadFarmerProduce(String farmerId) async {
    await _setLoading(true);
    try {
      _allProduce = _produceService.getProduceByFarmer(farmerId);
      _applyFiltersAndSearch();
      _clearError();
    } catch (e) {
      _setError('Failed to load farmer produce: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Apply filter by status
  void applyFilter({String? status}) {
    if (status != null && status != 'all') {
      _activeFilters = {'status': status};
    } else {
      _activeFilters = null;
    }
    _applyFiltersAndSearch();
  }

  /// Get produce statistics
  Map<String, dynamic> get statistics {
    return _produceService.getProduceStatistics();
  }
}
