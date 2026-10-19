import 'package:flutter/foundation.dart';
import '../models/transport_request_model.dart';
import '../models/trip_model.dart';
import '../models/crop_plot_model.dart';
import '../services/transport_service.dart';
import '../repositories/transport_repository.dart';
import '../models/transport_transaction.dart';
import '../models/proof_of_delivery.dart';

/// TransportProvider - State management for transport requests and trips
/// 
/// Provides reactive access to TransportService with:
/// - Loading states
/// - Error handling
/// - Automatic UI updates via ChangeNotifier
/// - Separate management for requests and trips
///
/// Phase 6 Extensions:
/// - Job acceptance with race condition handling (via repository)
/// - Transaction management and CSV export
/// - Contact information retrieval
class TransportProvider with ChangeNotifier {
  final TransportService _transportService = TransportService();
  final TransportRepository _repository = TransportRepository();

  List<TransportRequest> _transportRequests = [];
  List<TransportRequest> _filteredRequests = [];
  List<Trip> _trips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TransportRequest> get transportRequests => _transportRequests;
  List<TransportRequest> get filteredRequests => _filteredRequests;
  List<Trip> get trips => _trips;
  List<Trip> get filteredTrips => _filteredTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _filteredRequests.isEmpty && _filteredTrips.isEmpty && !_isLoading;
  List<TransportRequest> get farmerRequests => _filteredRequests;

  /// Initialize provider and load data
  Future<void> initialize() async {
    await _setLoading(true);
    try {
      await _transportService.initialize();
      await loadAllTransportRequests();
      await loadAllTrips();
    } catch (e) {
      _setError('Failed to initialize transport data: $e');
    } finally {
      await _setLoading(false);
    }
  }

  // ============================================================
  // TRANSPORT REQUEST Operations
  // ============================================================

  Future<void> loadAllTransportRequests() async {
    await _setLoading(true);
    try {
      _transportRequests = _transportService.getAllTransportRequests();
      _filteredRequests = _transportRequests;
      _clearError();
    } catch (e) {
      _setError('Failed to load transport requests: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadTransportRequestsByFarmer(String farmerId) async {
    await _setLoading(true);
    try {
      _transportRequests = _transportService.getTransportRequestsByFarmer(farmerId);
      _filteredRequests = _transportRequests;
      _clearError();
    } catch (e) {
      _setError('Failed to load farmer transport requests: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadPendingTransportRequests() async {
    await _setLoading(true);
    try {
      _transportRequests = _transportService.getPendingTransportRequests();
      _filteredRequests = _transportRequests;
      _clearError();
    } catch (e) {
      _setError('Failed to load pending requests: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<TransportRequest?> createTransportRequest({
    required String farmerId,
    required CropType cropType,
    required double quantityKg,
    required String pickupLocation,
    required String deliveryLocation,
    required DateTime requestedPickupDate,
    bool requiresRefrigeration = false,
    String? specialInstructions,
  }) async {
    await _setLoading(true);
    try {
      final request = await _transportService.createTransportRequest(
        farmerId: farmerId,
        cropType: cropType,
        quantityKg: quantityKg,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        requestedPickupDate: requestedPickupDate,
        requiresRefrigeration: requiresRefrigeration,
        specialInstructions: specialInstructions,
      );
      await loadAllTransportRequests();
      _clearError();
      return request;
    } catch (e) {
      _setError('Failed to create transport request: $e');
      return null;
    } finally {
      await _setLoading(false);
    }
  }

  Future<bool> addTransporterResponse(String requestId, String transporterId) async {
    try {
      await _transportService.addTransporterResponse(requestId, transporterId);
      await loadAllTransportRequests();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add transporter response: $e');
      return false;
    }
  }

  Future<bool> matchTransportRequest({
    required String requestId,
    required String transporterId,
    required String vehicleId,
    required double agreedPrice,
  }) async {
    try {
      await _transportService.matchTransportRequest(
        requestId: requestId,
        transporterId: transporterId,
        vehicleId: vehicleId,
        agreedPrice: agreedPrice,
      );
      await loadAllTransportRequests();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to match transport request: $e');
      return false;
    }
  }

  Future<bool> cancelTransportRequest(String requestId) async {
    try {
      await _transportService.cancelTransportRequest(requestId);
      await loadAllTransportRequests();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to cancel transport request: $e');
      return false;
    }
  }

  void searchTransportRequests(String query) {
    if (query.isEmpty) {
      _filteredRequests = _transportRequests;
    } else {
      _filteredRequests = _transportService.searchTransportRequests(query);
    }
    notifyListeners();
  }

  void filterTransportRequests({
    String? farmerId,
    RequestStatus? status,
    CropType? cropType,
    DateTime? startDate,
    DateTime? endDate,
    bool? requiresRefrigeration,
  }) {
    _filteredRequests = _transportService.filterTransportRequests(
      farmerId: farmerId,
      status: status,
      cropType: cropType,
      startDate: startDate,
      endDate: endDate,
      requiresRefrigeration: requiresRefrigeration,
    );
    notifyListeners();
  }

  // ============================================================
  // TRIP Operations
  // ============================================================

  Future<void> loadAllTrips() async {
    await _setLoading(true);
    try {
      _trips = _transportService.getAllTrips();
      _filteredTrips = _trips;
      _clearError();
    } catch (e) {
      _setError('Failed to load trips: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadTripsByFarmer(String farmerId) async {
    await _setLoading(true);
    try {
      _trips = _transportService.getTripsByFarmer(farmerId);
      _filteredTrips = _trips;
      _clearError();
    } catch (e) {
      _setError('Failed to load farmer trips: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadTripsByTransporter(String transporterId) async {
    await _setLoading(true);
    try {
      _trips = _transportService.getTripsByTransporter(transporterId);
      _filteredTrips = _trips;
      _clearError();
    } catch (e) {
      _setError('Failed to load transporter trips: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadActiveTrips() async {
    await _setLoading(true);
    try {
      _trips = _transportService.getActiveTrips();
      _filteredTrips = _trips;
      _clearError();
    } catch (e) {
      _setError('Failed to load active trips: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadInTransitTrips() async {
    await _setLoading(true);
    try {
      _trips = _transportService.getInTransitTrips();
      _filteredTrips = _trips;
      _clearError();
    } catch (e) {
      _setError('Failed to load in-transit trips: $e');
    } finally {
      await _setLoading(false);
    }
  }

  Future<Trip?> createTripFromRequest({
    required String transportRequestId,
    required String transporterId,
    required String vehicleId,
    required String routeId,
    required double totalCost,
    DateTime? scheduledPickupTime,
  }) async {
    await _setLoading(true);
    try {
      final trip = await _transportService.createTripFromRequest(
        transportRequestId: transportRequestId,
        transporterId: transporterId,
        vehicleId: vehicleId,
        routeId: routeId,
        totalCost: totalCost,
        scheduledPickupTime: scheduledPickupTime,
      );
      await loadAllTrips();
      _clearError();
      return trip;
    } catch (e) {
      _setError('Failed to create trip: $e');
      return null;
    } finally {
      await _setLoading(false);
    }
  }

  Future<bool> markTripPickedUp(String tripId, {String? note}) async {
    try {
      await _transportService.markTripPickedUp(tripId, note: note);
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to mark trip picked up: $e');
      return false;
    }
  }

  Future<bool> markTripInTransit(String tripId, {String? note}) async {
    try {
      await _transportService.markTripInTransit(tripId, note: note);
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to mark trip in transit: $e');
      return false;
    }
  }

  Future<bool> markTripDelivered(String tripId, {String? note}) async {
    try {
      await _transportService.markTripDelivered(tripId, note: note);
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to mark trip delivered: $e');
      return false;
    }
  }

  Future<bool> cancelTrip(String tripId, String reason) async {
    try {
      await _transportService.cancelTrip(tripId, reason);
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to cancel trip: $e');
      return false;
    }
  }

  Future<bool> updateTripLocation({
    required String tripId,
    required String currentLocation,
    double? currentDistanceKm,
  }) async {
    try {
      await _transportService.updateTripLocation(
        id: tripId,
        currentLocation: currentLocation,
        currentDistanceKm: currentDistanceKm,
      );
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update trip location: $e');
      return false;
    }
  }

  Future<bool> rateTripByFarmer({
    required String tripId,
    required double rating,
    String? notes,
  }) async {
    try {
      await _transportService.rateTripByFarmer(
        id: tripId,
        rating: rating,
        notes: notes,
      );
      await loadAllTrips();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to rate trip: $e');
      return false;
    }
  }

  void searchTrips(String query) {
    if (query.isEmpty) {
      _filteredTrips = _trips;
    } else {
      _filteredTrips = _transportService.searchTrips(query);
    }
    notifyListeners();
  }

  void filterTrips({
    String? farmerId,
    String? transporterId,
    TripStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _filteredTrips = _transportService.filterTrips(
      farmerId: farmerId,
      transporterId: transporterId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
    notifyListeners();
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  Map<String, dynamic> getTransportRequestStatistics() {
    return _transportService.getTransportRequestStatistics();
  }

  Map<String, dynamic> getTripStatistics() {
    return _transportService.getTripStatistics();
  }

  Map<String, dynamic> getFarmerTransportStatistics(String farmerId) {
    return _transportService.getFarmerTransportStatistics(farmerId);
  }

  Map<String, dynamic> getTransporterStatistics(String transporterId) {
    return _transportService.getTransporterStatistics(transporterId);
  }

  TransportRequest? getTransportRequestById(String requestId) {
    return _transportService.getTransportRequestById(requestId);
  }

  Trip? getTripById(String tripId) {
    return _transportService.getTripById(tripId);
  }

  // ============================================================
  // PHASE 6: Enhanced Transport Operations (via Repository)
  /// Accept a job with race condition handling
  Future<AcceptJobResult> acceptJobWithRaceCheck({
    required String jobId,
    required String transporterId,
    required String vehicleId,
    required DateTime estimatedPickupTime,
  }) async {
    return await _repository.acceptJob(
      jobId: jobId,
      transporterId: transporterId,
      vehicleId: vehicleId,
      estimatedPickupTime: estimatedPickupTime,
    );
  }

  /// Get contact information for a job
  Future<JobContactInfo?> getJobContact(String jobId) async {
    return await _repository.getJobContact(jobId);
  }

  /// Get transactions for transporter
  Future<List<TransportTransaction>> getTransactions({
    required String transporterId,
    TransactionFilter? filter,
  }) async {
    return await _repository.getTransactions(
      transporterId: transporterId,
      filter: filter,
    );
  }

  /// Export transactions as CSV
  Future<String?> exportTransactionsCSV({
    required String transporterId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.exportTransactionsCSV(
      transporterId: transporterId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearFilters() {
    _filteredRequests = _transportRequests;
    _filteredTrips = _trips;
    notifyListeners();
  }

  Future<void> reloadMockData() async {
    await _setLoading(true);
    try {
      await _transportService.reloadMockData();
      await loadAllTransportRequests();
      await loadAllTrips();
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> loadFarmerTransportRequests(String farmerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _transportRequests = _transportService.getTransportRequestsByFarmer(farmerId);
      _filteredRequests = _transportRequests;
      _error = null;
    } catch (e) {
      _error = 'Failed to load transport requests: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
