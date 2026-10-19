import 'dart:io';
import '../services/transport_api_service_enhanced.dart';
import '../services/photo_service.dart';
import '../services/signature_service.dart';
import '../models/trip_model.dart';
import '../models/transport_transaction.dart';
import '../models/proof_of_delivery.dart';
import '../exceptions/transport_exceptions.dart';

/// Transport Repository
/// Mediates between API and business logic
/// Handles race conditions, optimistic updates, and offline queueing
class TransportRepository {
  final TransportApiServiceEnhanced _apiService;
  final PhotoService _photoService;
  final SignatureService _signatureService;

  TransportRepository({
    TransportApiServiceEnhanced? apiService,
    PhotoService? photoService,
    SignatureService? signatureService,
  })  : _apiService = apiService ?? TransportApiServiceEnhanced(),
        _photoService = photoService ?? PhotoService(),
        _signatureService = signatureService ?? SignatureService();

  // ============================================================
  // JOB MANAGEMENT
  // ============================================================

  /// Get available jobs
  Future<List<Trip>> getAvailableJobs({
    String? location,
    String? cropType,
    double? radius,
  }) async {
    final response = await _apiService.getAvailableJobs(
      location: location,
      cropType: cropType,
      radius: radius,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.error ?? 'Failed to load jobs');
  }

  /// Accept job with race condition handling
  Future<AcceptJobResult> acceptJob({
    required String jobId,
    required String transporterId,
    required String vehicleId,
    required DateTime estimatedPickupTime,
  }) async {
    try {
      final response = await _apiService.acceptJob(
        jobId: jobId,
        transporterId: transporterId,
        vehicleId: vehicleId,
        estimatedPickupTime: estimatedPickupTime,
      );

      if (response.isSuccess && response.data != null) {
        return AcceptJobResult(
          success: true,
          job: response.data!,
        );
      }

      return AcceptJobResult(
        success: false,
        error: response.error ?? 'Failed to accept job',
      );
    } on JobAlreadyAcceptedException catch (e) {
      return AcceptJobResult(
        success: false,
        error: e.message,
        isRaceCondition: true,
        acceptedBy: e.acceptedBy,
        acceptedAt: e.acceptedAt,
      );
    } on JobNotFoundException catch (e) {
      return AcceptJobResult(
        success: false,
        error: e.message,
        isNotFound: true,
      );
    } catch (e) {
      return AcceptJobResult(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Update job status
  Future<Trip?> updateJobStatus({
    required String jobId,
    required String status,
    String? location,
  }) async {
    final response = await _apiService.updateJobStatus(
      jobId: jobId,
      status: status,
      location: location,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.error ?? 'Failed to update status');
  }

  /// Get job details
  Future<Trip?> getJobDetails(String jobId) async {
    final response = await _apiService.getJobDetails(jobId);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    return null;
  }

  /// Get active jobs
  Future<List<Trip>> getActiveJobs(String transporterId) async {
    final response = await _apiService.getActiveJobs(transporterId);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.error ?? 'Failed to load active jobs');
  }

  // ============================================================
  // PROOF OF DELIVERY
  // ============================================================

  /// Capture and upload proof of delivery
  Future<ProofOfDelivery?> captureProofOfDelivery({
    required String jobId,
    required String recipientName,
    String? notes,
    double? latitude,
    double? longitude,
    required SignatureData signatureData,
    File? photoFile,
  }) async {
    try {
      // Validate signature
      if (!_signatureService.validateSignature(signatureData)) {
        throw SignatureException('Invalid or empty signature');
      }

      // Use provided photo or capture and compress
      final file = photoFile ?? await _photoService.captureAndCompressPhoto();
      if (file == null) {
        throw PhotoCaptureException('Photo capture cancelled');
      }

      // Validate photo
      if (!await _photoService.validatePhoto(file)) {
        throw PhotoCaptureException('Invalid photo file');
      }

      // Save signature to file
      final signatureFile = await _signatureService.saveSignatureToFile(signatureData);

      // Upload to backend
      final response = await _apiService.uploadProofOfDelivery(
        jobId: jobId,
        photoFile: file,
        signatureFile: signatureFile,
        recipientName: recipientName,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
      );

      // Cleanup temp files
      await _photoService.deletePhoto(file);
      await _signatureService.deleteSignatureFile(signatureFile);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }

      throw Exception(response.error ?? 'Failed to upload proof');
    } catch (e) {
      rethrow;
    }
  }

  /// Capture photo only (for preview)
  Future<File?> capturePhoto() async {
    return await _photoService.captureAndCompressPhoto();
  }

  // ============================================================
  // CONTACT
  // ============================================================

  /// Get contact information
  Future<JobContactInfo?> getJobContact(String jobId) async {
    final response = await _apiService.getJobContact(jobId);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    return null;
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  /// Get transactions with filtering
  Future<List<TransportTransaction>> getTransactions({
    required String transporterId,
    TransactionFilter? filter,
  }) async {
    final response = await _apiService.getTransactions(
      transporterId: transporterId,
      fromDate: filter?.fromDate,
      toDate: filter?.toDate,
      status: filter?.status,
    );

    if (response.isSuccess && response.data != null) {
      var transactions = response.data!;

      // Apply additional filters if needed
      if (filter != null) {
        transactions = transactions.where((t) => filter.matches(t)).toList();
      }

      return transactions;
    }

    throw Exception(response.error ?? 'Failed to load transactions');
  }

  /// Export transactions to CSV
  Future<String?> exportTransactionsCSV({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _apiService.exportTransactions(
      transporterId: transporterId,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    return null;
  }

  /// Get earnings summary
  Future<Map<String, dynamic>?> getEarningsSummary({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _apiService.getEarningsSummary(
      transporterId: transporterId,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    return null;
  }

  // ============================================================
  // PERMISSION HANDLING
  // ============================================================

  /// Check camera permission
  Future<bool> hasCameraPermission() async {
    return await _photoService.hasCameraPermission();
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    return await _photoService.requestCameraPermission();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _photoService.openSettings();
  }
}

/// Accept Job Result
class AcceptJobResult {
  final bool success;
  final Trip? job;
  final String? error;
  final bool isRaceCondition;
  final bool isNotFound;
  final String? acceptedBy;
  final DateTime? acceptedAt;

  AcceptJobResult({
    required this.success,
    this.job,
    this.error,
    this.isRaceCondition = false,
    this.isNotFound = false,
    this.acceptedBy,
    this.acceptedAt,
  });

  bool get isAlreadyAccepted => isRaceCondition;
}
