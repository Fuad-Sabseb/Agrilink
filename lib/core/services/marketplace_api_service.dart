import '../network/api_client.dart';
import '../models/farmer_model.dart';
import '../models/farm_model.dart';
import '../models/crop_plot_model.dart';

/// MarketplaceApiService - Handles marketplace search and contact operations
/// 
/// Features:
/// - Authenticated HTTP requests via ApiClient
/// - Search farmers and produce
/// - Contact farmer abstraction layer
/// - Statistics endpoints
/// - Error handling with ApiResponse wrapper
class MarketplaceApiService {
  final ApiClient _apiClient;

  MarketplaceApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // FARMER SEARCH Operations
  // ============================================================

  /// Search farmers in marketplace
  /// 
  /// Endpoint: GET /api/marketplace/farmers?location=X&cropType=Y&woreda=Z
  Future<ApiResponse<List<Farmer>>> searchFarmers({
    String? location,
    CropType? cropType,
    String? woreda,
  }) async {
    try {
      final queryParams = <String, String>{
        if (location != null) 'location': location,
        if (cropType != null) 'cropType': cropType.name,
        if (woreda != null) 'woreda': woreda,
      };

      final response = await _apiClient.get<List<dynamic>>(
        '/marketplace/farmers',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final farmers = response.data!
            .map((json) => Farmer.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(farmers);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to search farmers',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error searching farmers: $e');
    }
  }

  /// Get farmer profile from marketplace
  /// 
  /// Endpoint: GET /api/marketplace/farmers/{id}
  Future<ApiResponse<Farmer>> getFarmerProfile(String farmerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/marketplace/farmers/$farmerId',
      );

      if (response.isSuccess && response.data != null) {
        final farmer = Farmer.fromJson(response.data!);
        return ApiResponse.success(farmer);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load farmer profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading farmer profile: $e');
    }
  }

  /// Get farmer's farms from marketplace
  /// 
  /// Endpoint: GET /api/marketplace/farmers/{id}/farms
  Future<ApiResponse<List<Farm>>> getFarmerFarms(String farmerId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/marketplace/farmers/$farmerId/farms',
      );

      if (response.isSuccess && response.data != null) {
        final farms = response.data!
            .map((json) => Farm.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(farms);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load farmer farms',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading farmer farms: $e');
    }
  }

  // ============================================================
  // PRODUCE SEARCH Operations
  // ============================================================

  /// Search produce in marketplace
  /// 
  /// Endpoint: GET /api/marketplace/produce?cropType=X&location=Y&farmerId=Z&maxPrice=P
  Future<ApiResponse<List<Map<String, dynamic>>>> searchProduce({
    CropType? cropType,
    String? location,
    String? farmerId,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, String>{
        if (cropType != null) 'cropType': cropType.name,
        if (location != null) 'location': location,
        if (farmerId != null) 'farmerId': farmerId,
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      };

      final response = await _apiClient.get<List<dynamic>>(
        '/marketplace/produce',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final produce = response.data!
            .map((json) => json as Map<String, dynamic>)
            .toList();
        return ApiResponse.success(produce);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to search produce',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error searching produce: $e');
    }
  }

  /// Get single produce item
  /// 
  /// Endpoint: GET /api/marketplace/produce/{id}
  Future<ApiResponse<Map<String, dynamic>>> getProduceDetails(String produceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/marketplace/produce/$produceId',
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load produce details',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading produce details: $e');
    }
  }

  // ============================================================
  // CONTACT Operations (with fallback abstraction)
  // ============================================================

  /// Contact farmer - Abstraction layer for missing/incomplete APIs
  /// 
  /// Strategy:
  /// 1. Try real contact API: POST /api/contact/farmer
  /// 2. If 404/not implemented: Use fallback GET /api/marketplace/farmers/{id}/contact
  /// 
  /// Returns:
  /// - ApiResponse<bool>: true if real API worked, false if fallback was used
  /// 
  /// The UI should handle both cases:
  /// - true: Show success message "Contact request sent"
  /// - false: Show phone number for manual contact
  Future<ApiResponse<bool>> contactFarmer({
    required String farmerId,
    required String buyerId,
    required String message,
  }) async {
    try {
      // Try real contact API first
      final contactResponse = await _apiClient.post<Map<String, dynamic>>(
        '/contact/farmer',
        data: {
          'farmerId': farmerId,
          'buyerId': buyerId,
          'message': message,
        },
      );

      // If successful, real API exists and worked
      if (contactResponse.isSuccess) {
        return ApiResponse.success(true);
      }

      // If 404, try fallback endpoint
      if (contactResponse.statusCode == 404) {
        final fallbackResponse = await _apiClient.get<Map<String, dynamic>>(
          '/marketplace/farmers/$farmerId/contact',
        );

        // Fallback worked - return false to indicate UI should show phone
        if (fallbackResponse.isSuccess) {
          return ApiResponse.success(false);
        }

        return ApiResponse.error(
          fallbackResponse.error ?? 'Failed to contact farmer',
          statusCode: fallbackResponse.statusCode,
        );
      }

      // Other error from primary endpoint
      return ApiResponse.error(
        contactResponse.error ?? 'Failed to contact farmer',
        statusCode: contactResponse.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error contacting farmer: $e');
    }
  }

  /// Get farmer contact info (fallback)
  /// 
  /// Endpoint: GET /api/marketplace/farmers/{id}/contact
  /// 
  /// Returns phone number for manual contact
  Future<ApiResponse<Map<String, dynamic>>> getFarmerContact(String farmerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/marketplace/farmers/$farmerId/contact',
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to get farmer contact',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error getting farmer contact: $e');
    }
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  /// Get marketplace statistics
  /// 
  /// Endpoint: GET /api/marketplace/statistics
  /// 
  /// Returns stats like total farmers, total produce, avg prices, etc.
  /// Returns empty map on error (non-critical operation)
  Future<ApiResponse<Map<String, dynamic>>> getMarketplaceStatistics() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/marketplace/statistics',
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      // Return empty stats on error (non-critical)
      return ApiResponse.success({});
    } catch (e) {
      // Return empty stats on error (non-critical)
      return ApiResponse.success({});
    }
  }
}
