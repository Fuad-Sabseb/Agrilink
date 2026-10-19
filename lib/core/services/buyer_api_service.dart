import '../network/api_client.dart';
import '../models/buyer_model.dart';

/// BuyerApiService - Handles buyer profile API operations
/// 
/// Features:
/// - Authenticated HTTP requests via ApiClient
/// - Buyer profile CRUD operations
/// - Error handling with ApiResponse wrapper
/// - RESTful API conventions
class BuyerApiService {
  final ApiClient _apiClient;

  BuyerApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // BUYER PROFILE Operations
  // ============================================================

  /// Get buyer profile by ID
  /// 
  /// Endpoint: GET /api/buyers/{id}
  Future<ApiResponse<Buyer>> getBuyerProfile(String buyerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/buyers/$buyerId',
      );

      if (response.isSuccess && response.data != null) {
        final buyer = Buyer.fromJson(response.data!);
        return ApiResponse.success(buyer);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load buyer profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading buyer profile: $e');
    }
  }

  /// Update buyer profile
  /// 
  /// Endpoint: PUT /api/buyers/{id}
  Future<ApiResponse<Buyer>> updateBuyerProfile({
    required String buyerId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/buyers/$buyerId',
        data: updates,
      );

      if (response.isSuccess && response.data != null) {
        final buyer = Buyer.fromJson(response.data!);
        return ApiResponse.success(buyer);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update buyer profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating buyer profile: $e');
    }
  }

  /// Get buyer statistics
  /// 
  /// Endpoint: GET /api/buyers/{id}/statistics
  /// 
  /// Returns statistics like total orders, avg rating, etc.
  /// Returns empty map on error (non-critical operation)
  Future<ApiResponse<Map<String, dynamic>>> getBuyerStatistics(String buyerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/buyers/$buyerId/statistics',
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

  /// Verify buyer profile
  /// 
  /// Endpoint: POST /api/buyers/{id}/verify
  /// 
  /// Returns success if verification request was submitted
  Future<ApiResponse<void>> verifyBuyer(String buyerId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/buyers/$buyerId/verify',
        data: {},
      );

      if (response.isSuccess) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to verify buyer profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error verifying buyer profile: $e');
    }
  }
}
