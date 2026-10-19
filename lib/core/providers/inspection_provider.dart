import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../models/inspection_model.dart';
import '../models/inspection_operation_model.dart';
import '../services/inspection_api_service.dart';
import '../services/inspection/photo_upload_service.dart';
import '../services/inspection/offline_sync_service.dart';
import 'auth_provider.dart';

/// Inspection Provider
/// Manages inspection state and operations
/// Requirements: 1.1, 1.10, 2.1, 4.1-4.14, 5.1-5.16, 6.1-6.12, 7.1-7.12, 12.6, 18.5, 19.1-19.10
class InspectionProvider with ChangeNotifier {
  final InspectionApiService _apiService;
  final PhotoUploadService _photoService;
  final OfflineSyncService _offlineSyncService;
  final AuthProvider _authProvider;

  // State variables
  List<Inspection> _inspections = [];
  Inspection? _selectedInspection;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;
  List<InspectionOperation> _offlineQueue = [];

  // Getters
  List<Inspection> get inspections => _inspections;
  Inspection? get selectedInspection => _selectedInspection;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<InspectionOperation> get offlineQueue => _offlineQueue;

  // Computed properties
  int get totalInspections => _inspections.length;
  int get inProgressCount =>
      _inspections.where((i) => i.status == InspectionStatus.inProgress).length;
  int get completedCount =>
      _inspections.where((i) => i.status == InspectionStatus.completed).length;
  int get scheduledCount =>
      _inspections.where((i) => i.status == InspectionStatus.scheduled).length;
  int get pendingOperationsCount => _offlineQueue.length;

  InspectionProvider({
    InspectionApiService? apiService,
    PhotoUploadService? photoService,
    OfflineSyncService? offlineSyncService,
    required AuthProvider authProvider,
  })  : _apiService = apiService ?? InspectionApiService(),
        _photoService = photoService ?? PhotoUploadService(),
        _offlineSyncService = offlineSyncService ?? OfflineSyncService(),
        _authProvider = authProvider {
    // Listen to auth changes
    _authProvider.addListener(_onAuthChanged);
    
    // Initial load if authenticated
    if (_authProvider.isAuthenticated) {
      fetchInspections();
      _loadOfflineQueue();
    }
  }

  /// Handle auth state changes
  void _onAuthChanged() {
    if (_authProvider.isAuthenticated) {
      fetchInspections();
      _loadOfflineQueue();
    } else {
      _clearState();
    }
  }

  /// Fetch inspections for the authenticated officer
  /// Filters by assigned woredas
  /// Requirements: 2.1, 12.6, 18.5
  Future<void> fetchInspections() async {
    if (!_authProvider.isBureauOfficer) {
      _error = 'Unauthorized: Only bureau officers can access inspections';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      final officerId = _authProvider.user?.id;
      if (officerId == null) {
        throw Exception('Officer ID not found');
      }

      final response = await _apiService.getOfficerInspections(officerId);

      if (response.isSuccess && response.data != null) {
        // Filter by assigned woredas
        final assignedWoredas = _getAssignedWoredas();
        _inspections = response.data!
            .where((inspection) =>
                assignedWoredas.contains(inspection.woredaId))
            .toList();

        // Fetch statistics
        await _fetchStatistics(officerId);
      } else {
        _error = response.error ?? 'Failed to fetch inspections';
      }
    } catch (e) {
      _error = 'Error fetching inspections: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch statistics for the authenticated officer
  /// Requirements: 1.1, 1.2
  Future<void> _fetchStatistics(String officerId) async {
    try {
      final response = await _apiService.getInspectionStatistics(officerId);

      if (response.isSuccess && response.data != null) {
        _statistics = response.data;
      }
    } catch (e) {
      // Statistics fetch failure is not critical, log silently
      debugPrint('Failed to fetch statistics: $e');
    }
  }

  /// Create a new inspection
  /// Requirements: 4.1-4.14
  Future<Inspection?> createInspection(Map<String, dynamic> data) async {
    if (!_authProvider.isBureauOfficer) {
      _error = 'Unauthorized: Only bureau officers can create inspections';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _error = null;

    try {
      // Validate woreda authorization
      final woredaId = data['woredaId'] as String?;
      if (woredaId != null) {
        final assignedWoredas = _getAssignedWoredas();
        if (!assignedWoredas.contains(woredaId)) {
          throw Exception(
            'Unauthorized: You are not assigned to this woreda',
          );
        }
      }

      // Capture GPS location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        data['latitude'] = position.latitude;
        data['longitude'] = position.longitude;
      } catch (e) {
        debugPrint('Warning: Failed to get location: $e');
      }

      // Add officer information
      data['officerId'] = _authProvider.user?.id;
      data['officerName'] = _authProvider.user?.fullName;

      final farmerId = data['farmerId'] as String? ?? '';
      final response = await _apiService.createInspectionRequest(
        farmerId: farmerId,
        requestData: data,
      );

      if (response.isSuccess && response.data != null) {
        final inspection = response.data!;
        _inspections.insert(0, inspection);
        _selectedInspection = inspection;
        notifyListeners();
        return inspection;
      } else {
        _error = response.error ?? 'Failed to create inspection';
      }
    } catch (e) {
      _error = 'Error creating inspection: $e';
      
      // Queue for offline sync if network error
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        await _queueOperation(InspectionOperation(
          id: const Uuid().v4(),
          type: InspectionOperationType.createInspection,
          data: data,
          timestamp: DateTime.now(),
        ));
      }
    } finally {
      _setLoading(false);
    }

    return null;
  }

  /// Start an inspection (check-in)
  /// Requirements: 5.2, 6.1
  Future<void> startInspection(String inspectionId) async {
    _setLoading(true);
    _error = null;

    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await _apiService.checkIn(
        inspectionId,
        position.latitude,
        position.longitude,
      );

      if (response.isSuccess && response.data != null) {
        final updatedInspection = response.data!;
        _updateInspectionInList(updatedInspection);
        _selectedInspection = updatedInspection;
      } else {
        _error = response.error ?? 'Failed to start inspection';
      }
    } catch (e) {
      _error = 'Error starting inspection: $e';

      // Queue for offline sync
      await _queueOperation(InspectionOperation(
        id: const Uuid().v4(),
        type: InspectionOperationType.checkIn,
        data: {
          'inspectionId': inspectionId,
          'latitude': 0.0, // Will be updated when online
          'longitude': 0.0,
        },
        timestamp: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  /// Add a finding to an inspection
  /// Requirements: 5.2, 5.3, 5.8, 5.9, 7.7-7.9
  Future<void> addFinding(
    String inspectionId,
    InspectionFinding finding,
  ) async {
    // Optimistic update
    final inspection = _inspections.firstWhere((i) => i.id == inspectionId);
    final updatedFindings = [...inspection.findings, finding];
    final updatedInspection = inspection.copyWith(findings: updatedFindings);
    _updateInspectionInList(updatedInspection);

    try {
      final response = await _apiService.createFinding(
        inspectionId,
        finding.toJson(),
      );

      if (!response.isSuccess) {
        // Revert optimistic update
        _updateInspectionInList(inspection);
        _error = response.error ?? 'Failed to add finding';
        notifyListeners();
      }
    } catch (e) {
      // Revert optimistic update
      _updateInspectionInList(inspection);
      _error = 'Error adding finding: $e';
      notifyListeners();

      // Queue for offline sync
      await _queueOperation(InspectionOperation(
        id: const Uuid().v4(),
        type: InspectionOperationType.addFinding,
        data: {
          'inspectionId': inspectionId,
          'findingData': finding.toJson(),
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Add a photo to an inspection
  /// Requirements: 5.10-5.12, 15.1-15.13
  Future<void> addPhoto(
    String inspectionId,
    String photoPath, {
    Function(double)? onProgress,
  }) async {
    _error = null;

    try {
      final photoUrl = await _photoService.uploadPhoto(
        inspectionId,
        photoPath,
        onProgress: onProgress,
      );

      // Update inspection with new photo URL
      final inspection = _inspections.firstWhere((i) => i.id == inspectionId);
      final updatedPhotoUrls = [...inspection.photoUrls, photoUrl];
      final updatedInspection = inspection.copyWith(photoUrls: updatedPhotoUrls);
      _updateInspectionInList(updatedInspection);
    } catch (e) {
      _error = 'Error uploading photo: $e';
      notifyListeners();

      // Queue for offline sync
      await _queueOperation(InspectionOperation(
        id: const Uuid().v4(),
        type: InspectionOperationType.uploadPhoto,
        data: {
          'inspectionId': inspectionId,
          'photoPath': photoPath,
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Complete an inspection with signature
  /// Requirements: 6.1-6.12, 16.7-16.12
  Future<void> completeInspection(
    String inspectionId,
    String signature,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      // Validate findings exist
      final inspection = _inspections.firstWhere((i) => i.id == inspectionId);
      if (inspection.findings.isEmpty) {
        throw Exception(
          'At least one finding is required to complete inspection',
        );
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await _apiService.completeInspection(
        inspectionId,
        signature,
        position.latitude,
        position.longitude,
        inspection.notes,
      );

      if (response.isSuccess && response.data != null) {
        final updatedInspection = response.data!;
        _updateInspectionInList(updatedInspection);
        _selectedInspection = updatedInspection;
      } else {
        _error = response.error ?? 'Failed to complete inspection';
      }
    } catch (e) {
      _error = 'Error completing inspection: $e';

      // Queue for offline sync
      await _queueOperation(InspectionOperation(
        id: const Uuid().v4(),
        type: InspectionOperationType.completeInspection,
        data: {
          'inspectionId': inspectionId,
          'signature': signature,
          'latitude': 0.0,
          'longitude': 0.0,
        },
        timestamp: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  /// Get filtered inspections
  /// Requirements: 2.3-2.7, 19.1-19.10
  List<Inspection> filteredInspections({
    InspectionStatus? status,
    InspectionType? type,
    String? woredaId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _inspections.where((inspection) {
      if (status != null && inspection.status != status) return false;
      if (type != null && inspection.type != type) return false;
      if (woredaId != null && inspection.woredaId != woredaId) return false;
      if (startDate != null &&
          inspection.checkInTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && inspection.checkInTime.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Search inspections by query
  /// Requirements: 2.3
  List<Inspection> searchInspections(String query) {
    final lowerQuery = query.toLowerCase();
    return _inspections.where((inspection) {
      return inspection.cooperativeName?.toLowerCase().contains(lowerQuery) ==
              true ||
          inspection.farmName?.toLowerCase().contains(lowerQuery) == true ||
          inspection.woredaName.toLowerCase().contains(lowerQuery) ||
          inspection.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Sort inspections
  /// Requirements: 2.4
  List<Inspection> sortInspections(
    List<Inspection> inspections,
    SortOption option,
  ) {
    final sorted = List<Inspection>.from(inspections);

    switch (option) {
      case SortOption.dateNewest:
        sorted.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        break;
      case SortOption.dateOldest:
        sorted.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
        break;
      case SortOption.priorityHigh:
        sorted.sort((a, b) => b.issueCount.compareTo(a.issueCount));
        break;
      case SortOption.priorityLow:
        sorted.sort((a, b) => a.issueCount.compareTo(b.issueCount));
        break;
    }

    return sorted;
  }

  /// Select an inspection
  void selectInspection(String inspectionId) {
    _selectedInspection =
        _inspections.firstWhere((i) => i.id == inspectionId);
    notifyListeners();
  }

  /// Clear selected inspection
  void clearSelectedInspection() {
    _selectedInspection = null;
    notifyListeners();
  }

  /// Sync offline operations
  Future<int> syncOfflineOperations() async {
    try {
      final count = await _offlineSyncService.syncQueue();
      await _loadOfflineQueue();
      
      if (count > 0) {
        // Refresh inspections after sync
        await fetchInspections();
      }
      
      return count;
    } catch (e) {
      debugPrint('Error syncing offline operations: $e');
      return 0;
    }
  }

  /// Queue an operation for offline sync
  Future<void> _queueOperation(InspectionOperation operation) async {
    await _offlineSyncService.queueOperation(operation);
    await _loadOfflineQueue();
  }

  /// Load offline queue
  Future<void> _loadOfflineQueue() async {
    _offlineQueue = await _offlineSyncService.getPendingOperations();
    notifyListeners();
  }

  /// Update inspection in list
  void _updateInspectionInList(Inspection updatedInspection) {
    final index =
        _inspections.indexWhere((i) => i.id == updatedInspection.id);
    if (index != -1) {
      _inspections[index] = updatedInspection;
      notifyListeners();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear state
  /// Helper: Get assigned woredas from user roleData
  List<String> _getAssignedWoredas() {
    final roleData = _authProvider.user?.roleData;
    if (roleData == null) return [];
    
    final assignedWoredas = roleData["assignedWoredas"];
    if (assignedWoredas is List) {
      return List<String>.from(assignedWoredas);
    }
    
    return [];
  }


  void _clearState() {
    _inspections = [];
    _selectedInspection = null;
    _statistics = null;
    _error = null;
    _offlineQueue = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}

/// Sort option enum
enum SortOption {
  dateNewest,
  dateOldest,
  priorityHigh,
  priorityLow,
}
