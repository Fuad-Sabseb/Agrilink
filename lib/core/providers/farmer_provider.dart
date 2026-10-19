import 'package:flutter/foundation.dart';
import '../models/farmer_model.dart';
import '../models/farm_model.dart';
import '../services/farmer_api_service.dart';

/// Farmer Provider
/// Manages farmer profile and farms state
class FarmerProvider with ChangeNotifier {
  final FarmerApiService _apiService;

  FarmerProvider({FarmerApiService? apiService})
      : _apiService = apiService ?? FarmerApiService();

  // State
  Farmer? _farmer;
  List<Farm> _farms = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;

  // Cache duration
  static const _cacheDuration = Duration(minutes: 5);

  // Getters
  Farmer? get farmer => _farmer;
  List<Farm> get farms => _farms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetched => _lastFetched;

  bool get isCacheValid {
    if (_lastFetched == null) return false;
    return DateTime.now().difference(_lastFetched!) < _cacheDuration;
  }

  /// Load farmer profile
  Future<bool> loadFarmerProfile(
    String farmerId, {
    bool forceRefresh = false,
  }) async {
    // Use cache if valid and not forcing refresh
    if (isCacheValid && !forceRefresh && _farmer != null) {
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFarmerProfile(farmerId);

      if (response.isSuccess && response.data != null) {
        _farmer = response.data;
        _lastFetched = DateTime.now();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to load farmer profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading farmer profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load farmer's farms
  Future<bool> loadFarmerFarms(
    String farmerId, {
    bool forceRefresh = false,
  }) async {
    // Use cache if valid and not forcing refresh
    if (isCacheValid && !forceRefresh && _farms.isNotEmpty) {
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFarmerFarms(farmerId);

      if (response.isSuccess && response.data != null) {
        _farms = response.data!;
        _lastFetched = DateTime.now();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to load farms';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading farms: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update farmer profile
  Future<bool> updateFarmerProfile({
    required String farmerId,
    required Map<String, dynamic> updates,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateFarmerProfile(
        farmerId: farmerId,
        updates: updates,
      );

      if (response.isSuccess && response.data != null) {
        _farmer = response.data;
        _lastFetched = DateTime.now();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update farmer profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating farmer profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create new farm
  Future<Farm?> createFarm({
    required String farmerId,
    required Map<String, dynamic> farmData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createFarm(
        farmerId: farmerId,
        farmData: farmData,
      );

      if (response.isSuccess && response.data != null) {
        _farms.add(response.data!);
        _lastFetched = DateTime.now();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return response.data;
      } else {
        _error = response.error ?? 'Failed to create farm';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error creating farm: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear state (for logout)
  void clear() {
    _farmer = null;
    _farms = [];
    _isLoading = false;
    _error = null;
    _lastFetched = null;
    notifyListeners();
  }
}
