import 'dart:io';
import '../network/api_client.dart';
import '../models/trip_model.dart';
import '../models/transport_transaction.dart';
import '../models/proof_of_delivery.dart';
import '../exceptions/transport_exceptions.dart';

/// Enhanced Transport API Service
/// Complete backend integration for transporter workflow
class TransportApiServiceEnhanced {
  final ApiClient _apiClient;

  TransportApiServiceEnhanced({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // JOB MANAGEMENT
  // ============================================================

  /// Get available transport jobs
  Future<ApiResponse<List<Trip>>> getAvailableJobs({
    String? location,
    String? cropType,
    double? radius,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (location != null) queryParams['location'] = location;
      if (cropType != null) queryParams['cropType'] = cropType;
      if (radius != null) queryParams['radius'] = radius.toString();

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/jobs/available',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final jobsData = response.data!['jobs'] as List<dynamic>?;
        if (jobsData != null) {
          final jobs = jobsData
              .map((json) => Trip.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(jobs);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load available jobs',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading jobs: $e');
    }
  }

  /// Accept a transport job (CRITICAL - with race condition handling)
  Future<ApiResponse<Trip>> acceptJob({
    required String jobId,
    required String transporterId,
    required String vehicleId,
    required DateTime estimatedPickupTime,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/transport/jobs/$jobId/accept',
        data: {
          'transporterId': transporterId,
          'vehicleId': vehicleId,
          'estimatedPickupTime': estimatedPickupTime.toIso8601String(),
        },
      );

      // Success case
      if (response.isSuccess && response.data != null) {
        final job = Trip.fromJson(response.data!['job'] as Map<String, dynamic>);
        return ApiResponse.success(job);
      }

      // Race condition - 409 Conflict
      if (response.statusCode == 409) {
        final errorData = response.data;
        throw JobAlreadyAcceptedException(
          jobId: jobId,
          acceptedBy: errorData?['acceptedBy'] as String? ?? 'another transporter',
          acceptedAt: errorData?['acceptedAt'] != null
              ? DateTime.parse(errorData!['acceptedAt'] as String)
              : DateTime.now(),
        );
      }

      // Job not found - 404
      if (response.statusCode == 404) {
        throw JobNotFoundException(jobId: jobId);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to accept job',
        statusCode: response.statusCode,
      );
    } on JobAlreadyAcceptedException {
      rethrow;
    } on JobNotFoundException {
      rethrow;
    } catch (e) {
      return ApiResponse.error('Error accepting job: $e');
    }
  }

  /// Update job status
  Future<ApiResponse<Trip>> updateJobStatus({
    required String jobId,
    required String status,
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/transport/jobs/$jobId/status',
        data: {
          'status': status,
          if (location != null) 'location': location,
          if (metadata != null) ...metadata,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final job = Trip.fromJson(response.data!);
        return ApiResponse.success(job);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to update job status',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error updating status: $e');
    }
  }

  /// Get job details
  Future<ApiResponse<Trip>> getJobDetails(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/jobs/$jobId',
      );

      if (response.isSuccess && response.data != null) {
        final job = Trip.fromJson(response.data!);
        return ApiResponse.success(job);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load job details',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading job: $e');
    }
  }

  /// Get active jobs for transporter
  Future<ApiResponse<List<Trip>>> getActiveJobs(String transporterId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/jobs/active',
        queryParameters: {'transporterId': transporterId},
      );

      if (response.isSuccess && response.data != null) {
        final jobsData = response.data!['jobs'] as List<dynamic>?;
        if (jobsData != null) {
          final jobs = jobsData
              .map((json) => Trip.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(jobs);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load active jobs',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading active jobs: $e');
    }
  }

  // ============================================================
  // PROOF OF DELIVERY
  // ============================================================

  /// Upload proof of delivery (photo + signature)
  Future<ApiResponse<ProofOfDelivery>> uploadProofOfDelivery({
    required String jobId,
    required File photoFile,
    required File signatureFile,
    required String recipientName,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final formData = {
        'photo': await _apiClient.createMultipartFile(photoFile.path, 'photo'),
        'signature': await _apiClient.createMultipartFile(signatureFile.path, 'signature'),
        'recipientName': recipientName,
        if (notes != null) 'notes': notes,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        'capturedAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.postMultipart<Map<String, dynamic>>(
        '/transport/jobs/$jobId/proof-of-delivery',
        data: formData,
      );

      if (response.isSuccess && response.data != null) {
        final proof = ProofOfDelivery.fromJson(response.data!);
        return ApiResponse.success(proof);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to upload proof of delivery',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error uploading proof: $e');
    }
  }

  // ============================================================
  // CONTACT INFORMATION
  // ============================================================

  /// Get contact information for job
  Future<ApiResponse<JobContactInfo>> getJobContact(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/jobs/$jobId/contact',
      );

      if (response.isSuccess && response.data != null) {
        final contact = JobContactInfo.fromJson(response.data!);
        return ApiResponse.success(contact);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load contact information',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading contact: $e');
    }
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  /// Get transaction history
  Future<ApiResponse<List<TransportTransaction>>> getTransactions({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'transporterId': transporterId,
      };
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/transactions',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final transactionsData = response.data!['transactions'] as List<dynamic>?;
        if (transactionsData != null) {
          final transactions = transactionsData
              .map((json) =>
                  TransportTransaction.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(transactions);
        }
        return ApiResponse.success([]);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load transactions',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading transactions: $e');
    }
  }

  /// Export transactions as CSV
  Future<ApiResponse<String>> exportTransactions({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'transporterId': transporterId,
        'format': 'csv',
      };
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _apiClient.get<String>(
        '/transport/transactions/export',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to export transactions',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error exporting transactions: $e');
    }
  }

  /// Get earnings summary
  Future<ApiResponse<Map<String, dynamic>>> getEarningsSummary({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'transporterId': transporterId,
      };
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transport/earnings/summary',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!);
      }

      return ApiResponse.error(
        response.error ?? 'Failed to load earnings summary',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error loading earnings: $e');
    }
  }
}
