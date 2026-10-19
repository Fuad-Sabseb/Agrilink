import '../network/api_client.dart';
import '../models/farmer_model.dart';
import '../models/farm_model.dart';

/// Farmer API Service
/// Handles all farmer-related API operations
class FarmerApiService {
  final ApiClient _apiClient;

  FarmerApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get farmer profile by ID
  Future<ApiResponse<Farmer>> getFarmerProfile(String farmerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/farmers/$farmerId',
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

  /// Update farmer profile
  Future<ApiResponse<Farmer>> updateFarmerProfile({
    required String farmerId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/farmers/$farmerId',
        data: updates,
      );

      if (response.isSuccess && response.data != null) {
        final farmer = Farmer.fromJson(response.data!);
        return ApiResponse.success(farmer);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update farmer profile',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating farmer profile: $e');
    }
  }

  /// Get farmer's farms
  Future<ApiResponse<List<Farm>>> getFarmerFarms(String farmerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/farmers/$farmerId/farms',
      );

      if (response.isSuccess && response.data != null) {
        final farmsData = response.data!['farms'] as List<dynamic>?;
        if (farmsData != null) {
          final farms = farmsData
              .map((json) => Farm.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(farms);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load farms',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading farms: $e');
    }
  }

  /// Create new farm
  Future<ApiResponse<Farm>> createFarm({
    required String farmerId,
    required Map<String, dynamic> farmData,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/farmers/$farmerId/farms',
        data: farmData,
      );

      if (response.isSuccess && response.data != null) {
        final farm = Farm.fromJson(response.data!);
        return ApiResponse.success(farm);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to create farm',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error creating farm: $e');
    }
  }

  /// Update farm
  Future<ApiResponse<Farm>> updateFarm({
    required String farmId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/farms/$farmId',
        data: updates,
      );

      if (response.isSuccess && response.data != null) {
        final farm = Farm.fromJson(response.data!);
        return ApiResponse.success(farm);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update farm',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating farm: $e');
    }
  }
}
