import 'dart:async';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/inspection_operation_model.dart';
import '../inspection_api_service.dart';

/// Offline Sync Service for Inspection Operations
/// Handles queueing and synchronization of offline operations
/// Requirements: 13.1-13.11, 14.8-14.10
class OfflineSyncService {
  final InspectionApiService _apiService;
  final Connectivity _connectivity;
  Timer? _syncTimer;
  
  static const String _queueBoxName = 'inspection_operations_queue';
  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(seconds: 30);

  OfflineSyncService({
    InspectionApiService? apiService,
    Connectivity? connectivity,
  })  : _apiService = apiService ?? InspectionApiService(),
        _connectivity = connectivity ?? Connectivity() {
    _startPeriodicSync();
  }

  /// Queue an operation for offline sync
  Future<void> queueOperation(InspectionOperation operation) async {
    final box = await _getQueueBox();
    await box.put(operation.id, operation);
  }

  /// Sync all queued operations
  /// Returns number of successfully synced operations
  Future<int> syncQueue() async {
    // Check connectivity
    final connectivityResults = await _connectivity.checkConnectivity();
    if (!connectivityResults.contains(ConnectivityResult.mobile) &&
        !connectivityResults.contains(ConnectivityResult.wifi)) {
      return 0; // No internet connection
    }

    final box = await _getQueueBox();
    final operations = box.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int successCount = 0;
    final List<String> toRemove = [];

    for (final operation in operations) {
      try {
        await _executeOperation(operation);
        successCount++;
        toRemove.add(operation.id);
      } catch (e) {
        // Increment retry count
        final updatedOperation = operation.copyWith(
          retryCount: operation.retryCount + 1,
        );

        if (updatedOperation.retryCount >= _maxRetries) {
          // Max retries reached, remove from queue
          toRemove.add(operation.id);
        } else {
          // Update with incremented retry count
          await box.put(operation.id, updatedOperation);
        }
      }
    }

    // Remove successfully synced operations and failed operations that exceeded max retries
    for (final id in toRemove) {
      await box.delete(id);
    }

    return successCount;
  }

  /// Get pending operations count
  Future<int> getPendingCount() async {
    final box = await _getQueueBox();
    return box.length;
  }

  /// Clear all pending operations (use with caution)
  Future<void> clearQueue() async {
    final box = await _getQueueBox();
    await box.clear();
  }

  /// Get all pending operations
  Future<List<InspectionOperation>> getPendingOperations() async {
    final box = await _getQueueBox();
    return box.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Execute a single operation based on its type
  Future<void> _executeOperation(InspectionOperation operation) async {
    switch (operation.type) {
      case InspectionOperationType.createInspection:
        await _executeCreateInspection(operation.data);
        break;
      case InspectionOperationType.checkIn:
        await _executeCheckIn(operation.data);
        break;
      case InspectionOperationType.addFinding:
        await _executeAddFinding(operation.data);
        break;
      case InspectionOperationType.updateFinding:
        await _executeUpdateFinding(operation.data);
        break;
      case InspectionOperationType.deleteFinding:
        await _executeDeleteFinding(operation.data);
        break;
      case InspectionOperationType.uploadPhoto:
        await _executeUploadPhoto(operation.data);
        break;
      case InspectionOperationType.completeInspection:
        await _executeCompleteInspection(operation.data);
        break;
    }
  }

  /// Execute create inspection operation
  Future<void> _executeCreateInspection(Map<String, dynamic> data) async {
    final farmerId = data['farmerId'] as String;
    final response = await _apiService.createInspectionRequest(
      farmerId: farmerId,
      requestData: data,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to create inspection');
    }
  }

  /// Execute check-in operation
  Future<void> _executeCheckIn(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final latitude = data['latitude'] as double;
    final longitude = data['longitude'] as double;

    final response = await _apiService.checkIn(
      inspectionId,
      latitude,
      longitude,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to check in');
    }
  }

  /// Execute add finding operation
  Future<void> _executeAddFinding(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final findingData =
        data['findingData'] as Map<String, dynamic>;

    final response = await _apiService.createFinding(
      inspectionId,
      findingData,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to add finding');
    }
  }

  /// Execute update finding operation
  Future<void> _executeUpdateFinding(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final findingId = data['findingId'] as String;
    final findingData =
        data['findingData'] as Map<String, dynamic>;

    final response = await _apiService.updateFinding(
      inspectionId,
      findingId,
      findingData,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to update finding');
    }
  }

  /// Execute delete finding operation
  Future<void> _executeDeleteFinding(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final findingId = data['findingId'] as String;

    final response = await _apiService.deleteFinding(
      inspectionId,
      findingId,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to delete finding');
    }
  }

  /// Execute upload photo operation
  Future<void> _executeUploadPhoto(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final photoPath = data['photoPath'] as String;

    final response = await _apiService.uploadPhoto(
      inspectionId,
      photoPath,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to upload photo');
    }
  }

  /// Execute complete inspection operation
  Future<void> _executeCompleteInspection(Map<String, dynamic> data) async {
    final inspectionId = data['inspectionId'] as String;
    final signature = data['signature'] as String;
    final latitude = data['latitude'] as double;
    final longitude = data['longitude'] as double;
    final notes = data['notes'] as String?;

    final response = await _apiService.completeInspection(
      inspectionId,
      signature,
      latitude,
      longitude,
      notes,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Failed to complete inspection');
    }
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      syncQueue();
    });
  }

  /// Get or open the queue box
  Future<Box<InspectionOperation>> _getQueueBox() async {
    if (Hive.isBoxOpen(_queueBoxName)) {
      return Hive.box<InspectionOperation>(_queueBoxName);
    }
    return await Hive.openBox<InspectionOperation>(_queueBoxName);
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}
