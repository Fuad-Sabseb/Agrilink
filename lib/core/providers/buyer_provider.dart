import 'package:flutter/foundation.dart';
import '../models/buyer_model.dart';
import '../models/demand_model.dart';
import '../models/farmer_model.dart';
import '../models/crop_plot_model.dart';
import '../services/buyer_api_service.dart';
import '../services/demand_api_service.dart';
import '../services/marketplace_api_service.dart';

/// Buyer Provider
/// Manages buyer profile, demands, and marketplace operations state
class BuyerProvider with ChangeNotifier {
  final BuyerApiService _buyerApi;
  final DemandApiService _demandApi;
  final MarketplaceApiService _marketplaceApi;

  BuyerProvider({
    BuyerApiService? buyerApi,
    DemandApiService? demandApi,
    MarketplaceApiService? marketplaceApi,
  })  : _buyerApi = buyerApi ?? BuyerApiService(),
        _demandApi = demandApi ?? DemandApiService(),
        _marketplaceApi = marketplaceApi ?? MarketplaceApiService();

  // === PROFILE STATE ===
  Buyer? _buyer;
  bool _isLoadingProfile = false;
  String? _profileError;
  DateTime? _profileLastFetched;

  // === DEMANDS STATE ===
  List<Demand> _demands = [];
  bool _isLoadingDemands = false;
  String? _demandsError;
  DateTime? _demandsLastFetched;

  // === MARKETPLACE STATE ===
  List<Farmer> _searchedFarmers = [];
  bool _isLoadingMarketplace = false;
  String? _marketplaceError;

  // Cache duration
  static const _cacheDuration = Duration(minutes: 5);

  // === PROFILE GETTERS ===
  Buyer? get buyer => _buyer;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;
  DateTime? get profileLastFetched => _profileLastFetched;

  bool get isProfileCacheValid {
    if (_profileLastFetched == null) return false;
    return DateTime.now().difference(_profileLastFetched!) < _cacheDuration;
  }

  // === DEMANDS GETTERS ===
  List<Demand> get demands => _demands;
  bool get isLoadingDemands => _isLoadingDemands;
  String? get demandsError => _demandsError;
  DateTime? get demandsLastFetched => _demandsLastFetched;

  bool get isDemandsCacheValid {
    if (_demandsLastFetched == null) return false;
    return DateTime.now().difference(_demandsLastFetched!) < _cacheDuration;
  }

  /// Get active demands only
  List<Demand> get activeDemands {
    return _demands.where((d) => d.isActive).toList();
  }

  /// Get demands by status
  List<Demand> demandsByStatus(BuyingStatus status) {
    return _demands.where((d) => d.status == status).toList();
  }

  // === MARKETPLACE GETTERS ===
  List<Farmer> get searchedFarmers => _searchedFarmers;
  bool get isLoadingMarketplace => _isLoadingMarketplace;
  String? get marketplaceError => _marketplaceError;

  // === PROFILE METHODS ===

  /// Load buyer profile
  Future<bool> loadBuyerProfile(
    String buyerId, {
    bool forceRefresh = false,
  }) async {
    // Use cache if valid and not forcing refresh
    if (isProfileCacheValid && !forceRefresh && _buyer != null) {
      return true;
    }

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final response = await _buyerApi.getBuyerProfile(buyerId);

      if (response.isSuccess && response.data != null) {
        _buyer = response.data;
        _profileLastFetched = DateTime.now();
        _profileError = null;
        _isLoadingProfile = false;
        notifyListeners();
        return true;
      } else {
        _profileError = response.error ?? 'Failed to load buyer profile';
        _isLoadingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _profileError = 'Error loading buyer profile: $e';
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  /// Update buyer profile
  Future<bool> updateBuyerProfile({
    required String buyerId,
    required Map<String, dynamic> updates,
  }) async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final response = await _buyerApi.updateBuyerProfile(
        buyerId: buyerId,
        updates: updates,
      );

      if (response.isSuccess && response.data != null) {
        _buyer = response.data;
        _profileLastFetched = DateTime.now();
        _profileError = null;
        _isLoadingProfile = false;
        notifyListeners();
        return true;
      } else {
        _profileError = response.error ?? 'Failed to update buyer profile';
        _isLoadingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _profileError = 'Error updating buyer profile: $e';
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  /// Get buyer statistics
  Future<Map<String, dynamic>?> getBuyerStatistics(String buyerId) async {
    try {
      final response = await _buyerApi.getBuyerStatistics(buyerId);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching buyer statistics: $e');
      return null;
    }
  }

  /// Verify buyer profile
  Future<bool> verifyBuyerProfile(String buyerId) async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final response = await _buyerApi.verifyBuyer(buyerId);

      if (response.isSuccess) {
        // Reload profile to get updated verification status
        await loadBuyerProfile(buyerId, forceRefresh: true);
        return true;
      } else {
        _profileError = response.error ?? 'Failed to verify buyer profile';
        _isLoadingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _profileError = 'Error verifying buyer profile: $e';
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // === DEMAND METHODS ===

  /// Load buyer's demands
  Future<bool> loadBuyerDemands(
    String buyerId, {
    BuyingStatus? status,
    bool forceRefresh = false,
  }) async {
    // Use cache if valid and not forcing refresh
    if (isDemandsCacheValid && !forceRefresh && _demands.isNotEmpty) {
      return true;
    }

    _isLoadingDemands = true;
    _demandsError = null;
    notifyListeners();

    try {
      final response = await _demandApi.getBuyerDemands(
        buyerId,
        status: status,
      );

      if (response.isSuccess && response.data != null) {
        _demands = response.data!;
        _demandsLastFetched = DateTime.now();
        _demandsError = null;
        _isLoadingDemands = false;
        notifyListeners();
        return true;
      } else {
        _demandsError = response.error ?? 'Failed to load demands';
        _isLoadingDemands = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _demandsError = 'Error loading demands: $e';
      _isLoadingDemands = false;
      notifyListeners();
      return false;
    }
  }

  /// Create new demand
  Future<Demand?> createDemand({
    required String buyerId,
    required CropType cropType,
    required QualityGrade preferredGrade,
    required double minimumQuantityKg,
    required double maximumQuantityKg,
    required double priceOfferPerKg,
    required String pickupLocation,
    required DateTime expiresAt,
    String? additionalNotes,
    bool transportProvided = false,
    List<QualityGrade>? acceptedGrades,
  }) async {
    _isLoadingDemands = true;
    _demandsError = null;
    notifyListeners();

    try {
      final response = await _demandApi.createDemand(
        buyerId,
        cropType: cropType,
        preferredGrade: preferredGrade,
        minimumQuantityKg: minimumQuantityKg,
        maximumQuantityKg: maximumQuantityKg,
        priceOfferPerKg: priceOfferPerKg,
        pickupLocation: pickupLocation,
        expiresAt: expiresAt,
        additionalNotes: additionalNotes,
        transportProvided: transportProvided,
        acceptedGrades: acceptedGrades,
      );

      if (response.isSuccess && response.data != null) {
        _demands.insert(0, response.data!); // Add to beginning
        _demandsLastFetched = DateTime.now();
        _demandsError = null;
        _isLoadingDemands = false;
        notifyListeners();
        return response.data;
      } else {
        _demandsError = response.error ?? 'Failed to create demand';
        _isLoadingDemands = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _demandsError = 'Error creating demand: $e';
      _isLoadingDemands = false;
      notifyListeners();
      return null;
    }
  }

  /// Get single demand by ID
  Future<Demand?> getDemand(String demandId) async {
    try {
      final response = await _demandApi.getDemand(demandId);
      if (response.isSuccess && response.data != null) {
        // Update local cache if demand exists
        final index = _demands.indexWhere((d) => d.id == demandId);
        if (index != -1) {
          _demands[index] = response.data!;
          notifyListeners();
        }
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching demand: $e');
      return null;
    }
  }

  /// Update existing demand
  Future<bool> updateDemand({
    required String demandId,
    required Map<String, dynamic> updates,
  }) async {
    _isLoadingDemands = true;
    _demandsError = null;
    notifyListeners();

    try {
      final response = await _demandApi.updateDemand(demandId, updates);

      if (response.isSuccess && response.data != null) {
        // Update local cache
        final index = _demands.indexWhere((d) => d.id == demandId);
        if (index != -1) {
          _demands[index] = response.data!;
        }
        _demandsLastFetched = DateTime.now();
        _demandsError = null;
        _isLoadingDemands = false;
        notifyListeners();
        return true;
      } else {
        _demandsError = response.error ?? 'Failed to update demand';
        _isLoadingDemands = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _demandsError = 'Error updating demand: $e';
      _isLoadingDemands = false;
      notifyListeners();
      return false;
    }
  }

  /// Pause demand (set status to paused)
  Future<bool> pauseDemand(String demandId) async {
    try {
      final response = await _demandApi.updateDemandStatus(
        demandId,
        BuyingStatus.paused,
      );

      if (response.isSuccess && response.data != null) {
        // Update local cache
        final index = _demands.indexWhere((d) => d.id == demandId);
        if (index != -1) {
          _demands[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error pausing demand: $e');
      return false;
    }
  }

  /// Resume demand (set status to buyingNow)
  Future<bool> resumeDemand(String demandId) async {
    try {
      final response = await _demandApi.updateDemandStatus(
        demandId,
        BuyingStatus.buyingNow,
      );

      if (response.isSuccess && response.data != null) {
        // Update local cache
        final index = _demands.indexWhere((d) => d.id == demandId);
        if (index != -1) {
          _demands[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error resuming demand: $e');
      return false;
    }
  }

  /// Mark demand as filled
  Future<bool> fillDemand(String demandId) async {
    try {
      final response = await _demandApi.updateDemandStatus(
        demandId,
        BuyingStatus.filled,
      );

      if (response.isSuccess && response.data != null) {
        // Update local cache
        final index = _demands.indexWhere((d) => d.id == demandId);
        if (index != -1) {
          _demands[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error filling demand: $e');
      return false;
    }
  }

  /// Delete demand
  Future<bool> deleteDemand(String demandId) async {
    _isLoadingDemands = true;
    _demandsError = null;
    notifyListeners();

    try {
      final response = await _demandApi.deleteDemand(demandId);

      if (response.isSuccess) {
        // Remove from local cache
        _demands.removeWhere((d) => d.id == demandId);
        _demandsLastFetched = DateTime.now();
        _demandsError = null;
        _isLoadingDemands = false;
        notifyListeners();
        return true;
      } else {
        _demandsError = response.error ?? 'Failed to delete demand';
        _isLoadingDemands = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _demandsError = 'Error deleting demand: $e';
      _isLoadingDemands = false;
      notifyListeners();
      return false;
    }
  }

  /// Increment demand view count (non-critical operation)
  Future<void> incrementDemandView(String demandId) async {
    try {
      await _demandApi.incrementDemandView(demandId);
      // Silently update local cache if successful
      // Backend handles the counter - no need to update UI
    } catch (e) {
      debugPrint('Failed to increment demand view count: $e');
      // Non-critical - fail silently
    }
  }

  /// Increment demand response count (non-critical operation)
  Future<void> incrementDemandResponse(String demandId) async {
    try {
      await _demandApi.incrementDemandResponse(demandId);
      // Silently update local cache if successful
      // Backend handles the counter - no need to update UI
    } catch (e) {
      debugPrint('Failed to increment demand response count: $e');
      // Non-critical - fail silently
    }
  }

  // === MARKETPLACE METHODS ===

  /// Search farmers in marketplace
  Future<bool> searchFarmers({
    String? location,
    CropType? cropType,
    String? woreda,
  }) async {
    _isLoadingMarketplace = true;
    _marketplaceError = null;
    notifyListeners();

    try {
      final response = await _marketplaceApi.searchFarmers(
        location: location,
        cropType: cropType,
        woreda: woreda,
      );

      if (response.isSuccess && response.data != null) {
        _searchedFarmers = response.data!;
        _marketplaceError = null;
        _isLoadingMarketplace = false;
        notifyListeners();
        return true;
      } else {
        _marketplaceError = response.error ?? 'Failed to search farmers';
        _isLoadingMarketplace = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _marketplaceError = 'Error searching farmers: $e';
      _isLoadingMarketplace = false;
      notifyListeners();
      return false;
    }
  }

  /// Get farmer profile from marketplace
  Future<Farmer?> getFarmerProfile(String farmerId) async {
    try {
      final response = await _marketplaceApi.getFarmerProfile(farmerId);
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching farmer profile: $e');
      return null;
    }
  }

  /// Contact farmer (abstraction layer - may use real API or fallback)
  /// 
  /// Returns:
  /// - true: Real contact API worked (show success message)
  /// - false: Fallback used (show phone number for manual contact)
  Future<bool> contactFarmer({
    required String farmerId,
    required String buyerId,
    required String message,
  }) async {
    try {
      final response = await _marketplaceApi.contactFarmer(
        farmerId: farmerId,
        buyerId: buyerId,
        message: message,
      );

      // Response.data is bool: true = real API worked, false = fallback used
      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return false;
    } catch (e) {
      debugPrint('Error contacting farmer: $e');
      return false;
    }
  }

  /// Get marketplace statistics
  Future<Map<String, dynamic>?> getMarketplaceStatistics() async {
    try {
      final response = await _marketplaceApi.getMarketplaceStatistics();
      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching marketplace statistics: $e');
      return null;
    }
  }

  /// Clear all marketplace search results
  void clearMarketplaceSearch() {
    _searchedFarmers = [];
    _marketplaceError = null;
    notifyListeners();
  }

  /// Clear state (for logout)
  void clear() {
    _buyer = null;
    _isLoadingProfile = false;
    _profileError = null;
    _profileLastFetched = null;

    _demands = [];
    _isLoadingDemands = false;
    _demandsError = null;
    _demandsLastFetched = null;

    _searchedFarmers = [];
    _isLoadingMarketplace = false;
    _marketplaceError = null;

    notifyListeners();
  }
}
