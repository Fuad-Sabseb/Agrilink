import '../network/api_client.dart';
import '../models/transport_request_model.dart';

/// Transport API Service
/// Handles transport request API operations
class TransportApiService {
  final ApiClient _apiClient;

  TransportApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get transport requests for farmer
  Future<ApiResponse<List<TransportRequest>>> getFarmerTransportRequests(
    String farmerId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport-requests',
        queryParameters: {'farmerId': farmerId},
      );

      if (response.isSuccess && response.data != null) {
        final requestsData = response.data!['requests'] as List<dynamic>?;
        if (requestsData != null) {
          final requests = requestsData
              .map((json) =>
                  TransportRequest.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(requests);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load transport requests',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading transport requests: $e');
    }
  }

  /// Get single transport request
  Future<ApiResponse<TransportRequest>> getTransportRequest(
    String requestId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport-requests/$requestId',
      );

      if (response.isSuccess && response.data != null) {
        final request = TransportRequest.fromJson(response.data!);
        return ApiResponse.success(request);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load transport request',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading transport request: $e');
    }
  }

  /// Create transport request
  Future<ApiResponse<TransportRequest>> createTransportRequest({
    required String farmerId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final data = {
        ...requestData,
        'farmerId': farmerId,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/transport-requests',
        data: data,
      );

      if (response.isSuccess && response.data != null) {
        final request = TransportRequest.fromJson(response.data!);
        return ApiResponse.success(request);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to create transport request',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error creating transport request: $e');
    }
  }

  /// Cancel transport request
  Future<ApiResponse<TransportRequest>> cancelTransportRequest(
    String requestId,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/transport-requests/$requestId/cancel',
      );

      if (response.isSuccess && response.data != null) {
        final request = TransportRequest.fromJson(response.data!);
        return ApiResponse.success(request);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to cancel transport request',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error cancelling transport request: $e');
    }
  }
}
