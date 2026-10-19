import '../network/api_client.dart';
import '../models/inspection_model.dart';

/// Inspection API Service
/// Handles inspection request API operations
class InspectionApiService {
  final ApiClient _apiClient;

  InspectionApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get inspections for farmer
  Future<ApiResponse<List<Inspection>>> getFarmerInspections(
    String farmerId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/inspections',
        queryParameters: {'farmerId': farmerId},
      );

      if (response.isSuccess && response.data != null) {
        final inspectionsData = response.data!['inspections'] as List<dynamic>?;
        if (inspectionsData != null) {
          final inspections = inspectionsData
              .map(
                  (json) => Inspection.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(inspections);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load inspections',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading inspections: $e');
    }
  }

  /// Get single inspection
  Future<ApiResponse<Inspection>> getInspection(String inspectionId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/inspections/$inspectionId',
      );

      if (response.isSuccess && response.data != null) {
        final inspection = Inspection.fromJson(response.data!);
        return ApiResponse.success(inspection);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load inspection',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading inspection: $e');
    }
  }

  /// Create inspection request
  Future<ApiResponse<Inspection>> createInspectionRequest({
    required String farmerId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final data = {
        ...requestData,
        'farmerId': farmerId,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/inspections',
        data: data,
      );

      if (response.isSuccess && response.data != null) {
        final inspection = Inspection.fromJson(response.data!);
        return ApiResponse.success(inspection);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to create inspection request',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error creating inspection request: $e');
    }
  }

  // ============================================================
  // Bureau-Specific Operations (Task 2.1)
  // ============================================================

  /// Get inspections for a bureau officer
  /// Requirements: 1.1, 1.2, 2.1
  Future<ApiResponse<List<Inspection>>> getOfficerInspections(
    String officerId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/bureau/inspections',
        queryParameters: {'officerId': officerId},
      );

      if (response.isSuccess && response.data != null) {
        final inspectionsData = response.data!['inspections'] as List<dynamic>?;
        if (inspectionsData != null) {
          final inspections = inspectionsData
              .map(
                  (json) => Inspection.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(inspections);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load officer inspections',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading officer inspections: $e');
    }
  }

  /// Get inspection statistics for a bureau officer
  /// Requirements: 1.1, 1.2
  Future<ApiResponse<Map<String, dynamic>>> getInspectionStatistics(
    String officerId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/bureau/inspections/statistics',
        queryParameters: {'officerId': officerId},
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load statistics',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading statistics: $e');
    }
  }

  /// Check in to start an inspection (capture GPS coordinates)
  /// Requirements: 5.2, 6.1
  Future<ApiResponse<Inspection>> checkIn(
    String inspectionId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bureau/inspections/$inspectionId/check-in',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final inspection = Inspection.fromJson(response.data!);
        return ApiResponse.success(inspection);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to check in',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error checking in: $e');
    }
  }

  /// Complete an inspection with signature and final notes
  /// Requirements: 6.1, 6.2, 6.5, 6.6
  Future<ApiResponse<Inspection>> completeInspection(
    String inspectionId,
    String signature,
    double latitude,
    double longitude,
    String? notes,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bureau/inspections/$inspectionId/complete',
        data: {
          'signature': signature,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final inspection = Inspection.fromJson(response.data!);
        return ApiResponse.success(inspection);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to complete inspection',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error completing inspection: $e');
    }
  }

  /// Create a finding during inspection
  /// Requirements: 5.2, 5.3, 7.7
  Future<ApiResponse<InspectionFinding>> createFinding(
    String inspectionId,
    Map<String, dynamic> findingData,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/bureau/inspections/$inspectionId/findings',
        data: findingData,
      );

      if (response.isSuccess && response.data != null) {
        final finding = InspectionFinding.fromJson(response.data!);
        return ApiResponse.success(finding);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to create finding',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error creating finding: $e');
    }
  }

  /// Update an existing finding
  /// Requirements: 7.7
  Future<ApiResponse<InspectionFinding>> updateFinding(
    String inspectionId,
    String findingId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/bureau/inspections/$inspectionId/findings/$findingId',
        data: data,
      );

      if (response.isSuccess && response.data != null) {
        final finding = InspectionFinding.fromJson(response.data!);
        return ApiResponse.success(finding);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update finding',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating finding: $e');
    }
  }

  /// Delete a finding
  /// Requirements: 7.7
  Future<ApiResponse<void>> deleteFinding(
    String inspectionId,
    String findingId,
  ) async {
    try {
      final response = await _apiClient.delete<void>(
        '/bureau/inspections/$inspectionId/findings/$findingId',
      );

      if (response.isSuccess) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to delete finding',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error deleting finding: $e');
    }
  }

  /// Upload inspection photo
  /// Requirements: 5.10, 5.11
  Future<ApiResponse<String>> uploadPhoto(
    String inspectionId,
    String photoPath,
  ) async {
    try {
      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        '/bureau/inspections/$inspectionId/photos',
        photoPath,
        fieldName: 'photo',
      );

      if (response.isSuccess && response.data != null) {
        final photoUrl = response.data!['photoUrl'] as String;
        return ApiResponse.success(photoUrl);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to upload photo',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error uploading photo: $e');
    }
  }
}
