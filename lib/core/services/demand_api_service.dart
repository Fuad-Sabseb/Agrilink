import '../network/api_client.dart';
import '../models/demand_model.dart';
import '../models/crop_plot_model.dart';

/// DemandApiService - Handles demand/buying request API operations
/// 
/// Features:
/// - Authenticated HTTP requests via ApiClient
/// - Full CRUD operations for demands
/// - Status management (pause, resume, fill)
/// - View and response tracking
/// - Error handling with ApiResponse wrapper
class DemandApiService {
  final ApiClient _apiClient;

  DemandApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // DEMAND CRUD Operations
  // ============================================================

  /// Create new demand
  /// 
  /// Endpoint: POST /api/demands
  Future<ApiResponse<Demand>> createDemand(String buyerId, {
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
    try {
      final data = {
        'buyerId': buyerId,
        'cropType': cropType.name,
        'preferredGrade': preferredGrade.name,
        'minimumQuantityKg': minimumQuantityKg,
        'maximumQuantityKg': maximumQuantityKg,
        'priceOfferPerKg': priceOfferPerKg,
        'pickupLocation': pickupLocation,
        'expiresAt': expiresAt.toIso8601String(),
        if (additionalNotes != null) 'additionalNotes': additionalNotes,
        'transportProvided': transportProvided,
        if (acceptedGrades != null)
          'acceptedGrades': acceptedGrades.map((g) => g.name).toList(),
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/demands',
        data: data,
      );

      if (response.isSuccess && response.data != null) {
        final demand = Demand.fromJson(response.data!);
        return ApiResponse.success(demand);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to create demand',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error creating demand: $e');
    }
  }

  /// Get single demand by ID
  /// 
  /// Endpoint: GET /api/demands/{id}
  Future<ApiResponse<Demand>> getDemand(String demandId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/demands/$demandId',
      );

      if (response.isSuccess && response.data != null) {
        final demand = Demand.fromJson(response.data!);
        return ApiResponse.success(demand);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load demand',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading demand: $e');
    }
  }

  /// Get buyer's demands with optional filters
  /// 
  /// Endpoint: GET /api/demands?buyerId={id}&status={status}&cropType={type}
  Future<ApiResponse<List<Demand>>> getBuyerDemands(String buyerId, {
    BuyingStatus? status,
    CropType? cropType,
  }) async {
    try {
      final queryParams = <String, String>{
        'buyerId': buyerId,
        if (status != null) 'status': status.name,
        if (cropType != null) 'cropType': cropType.name,
      };

      final response = await _apiClient.get<List<dynamic>>(
        '/demands',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final demands = response.data!
            .map((json) => Demand.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(demands);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load demands',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading demands: $e');
    }
  }

  /// Get all active demands (for marketplace view)
  /// 
  /// Endpoint: GET /api/demands/active
  Future<ApiResponse<List<Demand>>> getActiveDemands({
    CropType? cropType,
  }) async {
    try {
      final queryParams = <String, String>{
        if (cropType != null) 'cropType': cropType.name,
      };

      final response = await _apiClient.get<List<dynamic>>(
        '/demands/active',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final demands = response.data!
            .map((json) => Demand.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(demands);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load active demands',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading active demands: $e');
    }
  }

  /// Update existing demand
  /// 
  /// Endpoint: PUT /api/demands/{id}
  Future<ApiResponse<Demand>> updateDemand(String demandId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/demands/$demandId',
        data: updates,
      );

      if (response.isSuccess && response.data != null) {
        final demand = Demand.fromJson(response.data!);
        return ApiResponse.success(demand);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update demand',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating demand: $e');
    }
  }

  /// Update demand status (pause, resume, fill)
  /// 
  /// Endpoint: PUT /api/demands/{id}/status
  Future<ApiResponse<Demand>> updateDemandStatus(String demandId, BuyingStatus status) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/demands/$demandId/status',
        data: {'status': status.name},
      );

      if (response.isSuccess && response.data != null) {
        final demand = Demand.fromJson(response.data!);
        return ApiResponse.success(demand);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update demand status',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating demand status: $e');
    }
  }

  /// Delete demand
  /// 
  /// Endpoint: DELETE /api/demands/{id}
  Future<ApiResponse<void>> deleteDemand(String demandId) async {
    try {
      final response = await _apiClient.delete<void>(
        '/demands/$demandId',
      );

      if (response.isSuccess) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to delete demand',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error deleting demand: $e');
    }
  }

  // ============================================================
  // ANALYTICS Operations
  // ============================================================

  /// Increment demand view count (non-critical operation)
  /// 
  /// Endpoint: POST /api/demands/{id}/view
  /// 
  /// Fails silently - don't block UI
  Future<void> incrementDemandView(String demandId) async {
    try {
      await _apiClient.post<void>(
        '/demands/$demandId/view',
        data: {},
      );
    } catch (e) {
      // Fail silently - non-critical operation
    }
  }

  /// Increment demand response count (non-critical operation)
  /// 
  /// Endpoint: POST /api/demands/{id}/response
  /// 
  /// Fails silently - don't block UI
  Future<void> incrementDemandResponse(String demandId) async {
    try {
      await _apiClient.post<void>(
        '/demands/$demandId/response',
        data: {},
      );
    } catch (e) {
      // Fail silently - non-critical operation
    }
  }
}
