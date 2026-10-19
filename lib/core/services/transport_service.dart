import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transport_request_model.dart';
import '../models/trip_model.dart';
import '../models/crop_plot_model.dart';

/// TransportService - Manages transport requests and trip lifecycle
/// 
/// Features:
/// - Transport request creation and management
/// - Trip lifecycle management (matched → picked_up → in_transit → delivered)
/// - Transporter matching and job assignment
/// - Real-time tracking updates
/// - Search, filter, and statistics
/// - Offline-first with Hive caching
/// - Mock data generation for testing
/// - Error handling and validation
class TransportService {
  static final TransportService _instance = TransportService._internal();
  factory TransportService() => _instance;
  TransportService._internal();

  Box<TransportRequest>? _transportRequestBox;
  Box<Trip>? _tripBox;
  final _uuid = const Uuid();
  bool _mockDataInitialized = false;

  // Valid trip status transitions
  static const Map<TripStatus, List<TripStatus>> _validTripTransitions = {
    TripStatus.matched: [TripStatus.pickedUp, TripStatus.cancelled],
    TripStatus.pickedUp: [TripStatus.inTransit, TripStatus.cancelled],
    TripStatus.inTransit: [TripStatus.delivered, TripStatus.cancelled],
    TripStatus.delivered: [],
    TripStatus.cancelled: [],
  };

  /// Initialize service and load mock data
  Future<void> initialize() async {
    try {
      _transportRequestBox = await Hive.openBox<TransportRequest>('transport_requests');
      _tripBox = await Hive.openBox<Trip>('trips');
      
      // Load mock data if boxes are empty
      if (_transportRequestBox!.isEmpty && _tripBox!.isEmpty && !_mockDataInitialized) {
        await _initializeMockData();
        _mockDataInitialized = true;
      }
    } catch (e) {
      throw Exception('Failed to initialize TransportService: $e');
    }
  }

  Box<TransportRequest> get _requestBox {
    if (_transportRequestBox == null || !_transportRequestBox!.isOpen) {
      throw Exception('TransportService not initialized. Call initialize() first.');
    }
    return _transportRequestBox!;
  }

  Box<Trip> get _tripsBox {
    if (_tripBox == null || !_tripBox!.isOpen) {
      throw Exception('TransportService not initialized. Call initialize() first.');
    }
    return _tripBox!;
  }

  // ============================================================
  // TRANSPORT REQUEST Operations
  // ============================================================

  /// Create a new transport request
  Future<TransportRequest> createTransportRequest({
    required String farmerId,
    required CropType cropType,
    required double quantityKg,
    required String pickupLocation,
    required String deliveryLocation,
    required DateTime requestedPickupDate,
    bool requiresRefrigeration = false,
    String? specialInstructions,
  }) async {
    // Validation
    _validateTransportRequest(
      quantityKg: quantityKg,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      requestedPickupDate: requestedPickupDate,
    );

    final id = _uuid.v4();
    final request = TransportRequest(
      id: id,
      farmerId: farmerId,
      cropType: cropType,
      quantityKg: quantityKg,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      requestedPickupDate: requestedPickupDate,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      requiresRefrigeration: requiresRefrigeration,
      specialInstructions: specialInstructions,
      responseTransporterIds: [],
    );

    try {
      await _requestBox.put(id, request);
      return request;
    } catch (e) {
      throw Exception('Failed to create transport request: $e');
    }
  }

  /// Get transport request by ID
  TransportRequest? getTransportRequestById(String id) {
    try {
      return _requestBox.get(id);
    } catch (e) {
      throw Exception('Failed to get transport request: $e');
    }
  }

  /// Get all transport requests
  List<TransportRequest> getAllTransportRequests() {
    try {
      return _requestBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get all transport requests: $e');
    }
  }

  /// Get transport requests by farmer
  List<TransportRequest> getTransportRequestsByFarmer(String farmerId) {
    try {
      return _requestBox.values
          .where((r) => r.farmerId == farmerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get farmer transport requests: $e');
    }
  }

  /// Get transport requests by status
  List<TransportRequest> getTransportRequestsByStatus(RequestStatus status) {
    try {
      return _requestBox.values
          .where((r) => r.status == status)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get transport requests by status: $e');
    }
  }

  /// Get pending transport requests (available for transporters)
  List<TransportRequest> getPendingTransportRequests() {
    return getTransportRequestsByStatus(RequestStatus.pending);
  }

  /// Get active transport requests
  List<TransportRequest> getActiveTransportRequests() {
    try {
      return _requestBox.values
          .where((r) => r.isActive)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get active transport requests: $e');
    }
  }

  /// Update transport request status
  Future<void> updateTransportRequestStatus(
    String id,
    RequestStatus newStatus, {
    String? matchedTransporterId,
    String? matchedVehicleId,
    double? agreedPrice,
  }) async {
    try {
      final request = getTransportRequestById(id);
      if (request == null) {
        throw Exception('Transport request not found with ID: $id');
      }

      final updated = request.copyWith(
        status: newStatus,
        matchedAt: newStatus == RequestStatus.matched ? DateTime.now() : null,
        matchedTransporterId: matchedTransporterId,
        matchedVehicleId: matchedVehicleId,
        agreedPrice: agreedPrice,
      );

      await _requestBox.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update transport request status: $e');
    }
  }

  /// Add transporter response to request
  Future<void> addTransporterResponse(String requestId, String transporterId) async {
    try {
      final request = getTransportRequestById(requestId);
      if (request == null) {
        throw Exception('Transport request not found');
      }

      if (request.status != RequestStatus.pending) {
        throw Exception('Can only respond to pending requests');
      }

      final responses = List<String>.from(request.responseTransporterIds ?? []);
      if (!responses.contains(transporterId)) {
        responses.add(transporterId);
        
        final updated = request.copyWith(
          responseTransporterIds: responses,
        );

        await _requestBox.put(requestId, updated);
      }
    } catch (e) {
      throw Exception('Failed to add transporter response: $e');
    }
  }

  /// Match transport request with transporter
  Future<void> matchTransportRequest({
    required String requestId,
    required String transporterId,
    required String vehicleId,
    required double agreedPrice,
  }) async {
    await updateTransportRequestStatus(
      requestId,
      RequestStatus.matched,
      matchedTransporterId: transporterId,
      matchedVehicleId: vehicleId,
      agreedPrice: agreedPrice,
    );
  }

  /// Cancel transport request
  Future<void> cancelTransportRequest(String id) async {
    final request = getTransportRequestById(id);
    if (request == null) {
      throw Exception('Transport request not found');
    }

    if (!request.isActive) {
      throw Exception('Can only cancel active requests');
    }

    await updateTransportRequestStatus(id, RequestStatus.cancelled);
  }

  /// Delete transport request
  Future<void> deleteTransportRequest(String id) async {
    try {
      await _requestBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete transport request: $e');
    }
  }

  // ============================================================
  // TRIP Operations
  // ============================================================

  /// Create a trip from matched transport request
  Future<Trip> createTripFromRequest({
    required String transportRequestId,
    required String transporterId,
    required String vehicleId,
    required String routeId,
    required double totalCost,
    DateTime? scheduledPickupTime,
  }) async {
    try {
      final request = getTransportRequestById(transportRequestId);
      if (request == null) {
        throw Exception('Transport request not found');
      }

      if (request.status != RequestStatus.matched) {
        throw Exception('Can only create trip from matched request');
      }

      final id = _uuid.v4();
      final trip = Trip(
        id: id,
        transportRequestId: transportRequestId,
        farmerId: request.farmerId,
        transporterId: transporterId,
        vehicleId: vehicleId,
        routeId: routeId,
        cropType: request.cropType,
        quantityKg: request.quantityKg,
        pickupLocation: request.pickupLocation,
        deliveryLocation: request.deliveryLocation,
        totalCost: totalCost,
        status: TripStatus.matched,
        createdAt: DateTime.now(),
        scheduledPickupTime: scheduledPickupTime ?? request.requestedPickupDate,
        estimatedArrivalTime: scheduledPickupTime?.add(const Duration(hours: 4)),
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: DateTime.now(),
            note: 'Trip created and matched with transporter',
            location: request.pickupLocation,
          ),
        ],
      );

      await _tripsBox.put(id, trip);

      // Update transport request status
      await updateTransportRequestStatus(
        transportRequestId,
        RequestStatus.accepted,
      );

      return trip;
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  /// Get trip by ID
  Trip? getTripById(String id) {
    try {
      return _tripsBox.get(id);
    } catch (e) {
      throw Exception('Failed to get trip: $e');
    }
  }

  /// Get all trips
  List<Trip> getAllTrips() {
    try {
      return _tripsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get all trips: $e');
    }
  }

  /// Get trips by farmer
  List<Trip> getTripsByFarmer(String farmerId) {
    try {
      return _tripsBox.values
          .where((t) => t.farmerId == farmerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get farmer trips: $e');
    }
  }

  /// Get trips by transporter
  List<Trip> getTripsByTransporter(String transporterId) {
    try {
      return _tripsBox.values
          .where((t) => t.transporterId == transporterId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get transporter trips: $e');
    }
  }

  /// Get trips by status
  List<Trip> getTripsByStatus(TripStatus status) {
    try {
      return _tripsBox.values
          .where((t) => t.status == status)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get trips by status: $e');
    }
  }

  /// Get active trips
  List<Trip> getActiveTrips() {
    try {
      return _tripsBox.values
          .where((t) => t.isActive)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get active trips: $e');
    }
  }

  /// Get in-transit trips
  List<Trip> getInTransitTrips() {
    return getTripsByStatus(TripStatus.inTransit);
  }

  /// Get completed trips
  List<Trip> getCompletedTrips() {
    return getTripsByStatus(TripStatus.delivered);
  }

  /// Update trip status with validation
  Future<void> updateTripStatus(
    String id,
    TripStatus newStatus, {
    String? note,
    String? location,
  }) async {
    try {
      final trip = getTripById(id);
      if (trip == null) {
        throw Exception('Trip not found with ID: $id');
      }

      // Validate status transition
      if (!_canTripTransitionTo(trip.status, newStatus)) {
        throw Exception(
            'Invalid trip status transition from ${trip.status} to $newStatus');
      }

      final now = DateTime.now();
      DateTime? actualPickupTime = trip.actualPickupTime;
      DateTime? actualDeliveryTime = trip.actualDeliveryTime;

      // Update timestamps based on status
      if (newStatus == TripStatus.pickedUp && actualPickupTime == null) {
        actualPickupTime = now;
      }
      if (newStatus == TripStatus.delivered && actualDeliveryTime == null) {
        actualDeliveryTime = now;
      }

      // Add status update to timeline
      final updates = List<TripStatusUpdate>.from(trip.statusUpdates ?? []);
      updates.add(TripStatusUpdate(
        status: newStatus,
        timestamp: now,
        note: note ?? newStatus.description,
        location: location ?? trip.currentLocation,
      ));

      final updated = trip.copyWith(
        status: newStatus,
        actualPickupTime: actualPickupTime,
        actualDeliveryTime: actualDeliveryTime,
        statusUpdates: updates,
      );

      await _tripsBox.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  /// Mark trip as picked up
  Future<void> markTripPickedUp(String id, {String? note}) async {
    await updateTripStatus(id, TripStatus.pickedUp, note: note);
  }

  /// Mark trip as in transit
  Future<void> markTripInTransit(String id, {String? note}) async {
    await updateTripStatus(id, TripStatus.inTransit, note: note);
  }

  /// Mark trip as delivered
  Future<void> markTripDelivered(String id, {String? note}) async {
    await updateTripStatus(id, TripStatus.delivered, note: note);
  }

  /// Cancel trip
  Future<void> cancelTrip(String id, String reason) async {
    final trip = getTripById(id);
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (!trip.canBeCancelled) {
      throw Exception('Trip cannot be cancelled at this stage');
    }

    await updateTripStatus(id, TripStatus.cancelled, note: reason);
  }

  /// Update trip location (for tracking)
  Future<void> updateTripLocation({
    required String id,
    required String currentLocation,
    double? currentDistanceKm,
  }) async {
    try {
      final trip = getTripById(id);
      if (trip == null) {
        throw Exception('Trip not found');
      }

      if (!trip.isInTransit) {
        throw Exception('Can only update location for trips in transit');
      }

      final updated = trip.copyWith(
        currentLocation: currentLocation,
        currentDistanceKm: currentDistanceKm,
      );

      await _tripsBox.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update trip location: $e');
    }
  }

  /// Rate trip (by farmer)
  Future<void> rateTripByFarmer({
    required String id,
    required double rating,
    String? notes,
  }) async {
    try {
      final trip = getTripById(id);
      if (trip == null) {
        throw Exception('Trip not found');
      }

      if (!trip.canBeRated) {
        throw Exception('Trip cannot be rated at this stage');
      }

      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final updated = trip.copyWith(
        farmerRating: rating,
        farmerNotes: notes,
      );

      await _tripsBox.put(id, updated);
    } catch (e) {
      throw Exception('Failed to rate trip: $e');
    }
  }

  /// Rate trip (by transporter)
  Future<void> rateTripByTransporter({
    required String id,
    required double rating,
    String? notes,
  }) async {
    try {
      final trip = getTripById(id);
      if (trip == null) {
        throw Exception('Trip not found');
      }

      if (trip.status != TripStatus.delivered) {
        throw Exception('Can only rate delivered trips');
      }

      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final updated = trip.copyWith(
        transporterRating: rating,
        transporterNotes: notes,
      );

      await _tripsBox.put(id, updated);
    } catch (e) {
      throw Exception('Failed to rate trip: $e');
    }
  }

  /// Delete trip
  Future<void> deleteTrip(String id) async {
    try {
      await _tripsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  // ============================================================
  // SEARCH & FILTER Operations
  // ============================================================

  /// Search transport requests
  List<TransportRequest> searchTransportRequests(String query) {
    try {
      if (query.isEmpty) return getAllTransportRequests();

      final lowerQuery = query.toLowerCase();
      return _requestBox.values
          .where((r) =>
              r.pickupLocation.toLowerCase().contains(lowerQuery) ||
              r.deliveryLocation.toLowerCase().contains(lowerQuery) ||
              r.cropType.displayName.toLowerCase().contains(lowerQuery))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to search transport requests: $e');
    }
  }

  /// Filter transport requests
  List<TransportRequest> filterTransportRequests({
    String? farmerId,
    RequestStatus? status,
    CropType? cropType,
    DateTime? startDate,
    DateTime? endDate,
    bool? requiresRefrigeration,
  }) {
    try {
      var results = _requestBox.values.toList();

      if (farmerId != null) {
        results = results.where((r) => r.farmerId == farmerId).toList();
      }

      if (status != null) {
        results = results.where((r) => r.status == status).toList();
      }

      if (cropType != null) {
        results = results.where((r) => r.cropType == cropType).toList();
      }

      if (startDate != null) {
        results = results
            .where((r) => r.createdAt.isAfter(startDate) ||
                r.createdAt.isAtSameMomentAs(startDate))
            .toList();
      }

      if (endDate != null) {
        results = results
            .where((r) => r.createdAt.isBefore(endDate) ||
                r.createdAt.isAtSameMomentAs(endDate))
            .toList();
      }

      if (requiresRefrigeration != null) {
        results = results
            .where((r) => r.requiresRefrigeration == requiresRefrigeration)
            .toList();
      }

      return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to filter transport requests: $e');
    }
  }

  /// Search trips
  List<Trip> searchTrips(String query) {
    try {
      if (query.isEmpty) return getAllTrips();

      final lowerQuery = query.toLowerCase();
      return _tripsBox.values
          .where((t) =>
              t.pickupLocation.toLowerCase().contains(lowerQuery) ||
              t.deliveryLocation.toLowerCase().contains(lowerQuery) ||
              t.cropType.displayName.toLowerCase().contains(lowerQuery))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to search trips: $e');
    }
  }

  /// Filter trips
  List<Trip> filterTrips({
    String? farmerId,
    String? transporterId,
    TripStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var results = _tripsBox.values.toList();

      if (farmerId != null) {
        results = results.where((t) => t.farmerId == farmerId).toList();
      }

      if (transporterId != null) {
        results = results.where((t) => t.transporterId == transporterId).toList();
      }

      if (status != null) {
        results = results.where((t) => t.status == status).toList();
      }

      if (startDate != null) {
        results = results
            .where((t) => t.createdAt.isAfter(startDate) ||
                t.createdAt.isAtSameMomentAs(startDate))
            .toList();
      }

      if (endDate != null) {
        results = results
            .where((t) => t.createdAt.isBefore(endDate) ||
                t.createdAt.isAtSameMomentAs(endDate))
            .toList();
      }

      return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to filter trips: $e');
    }
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  /// Get transport request statistics
  Map<String, dynamic> getTransportRequestStatistics() {
    try {
      final allRequests = _requestBox.values.toList();

      return {
        'totalRequests': allRequests.length,
        'pendingRequests': allRequests.where((r) => r.isPending).length,
        'matchedRequests': allRequests.where((r) => r.isMatched).length,
        'activeRequests': allRequests.where((r) => r.isActive).length,
        'cancelledRequests':
            allRequests.where((r) => r.status == RequestStatus.cancelled).length,
        'totalQuantityKg': allRequests.fold<double>(0, (sum, r) => sum + r.quantityKg),
        'averageQuantityKg': allRequests.isEmpty
            ? 0.0
            : allRequests.fold<double>(0, (sum, r) => sum + r.quantityKg) /
                allRequests.length,
        'refrigeratedRequests':
            allRequests.where((r) => r.requiresRefrigeration).length,
      };
    } catch (e) {
      throw Exception('Failed to get transport request statistics: $e');
    }
  }

  /// Get trip statistics
  Map<String, dynamic> getTripStatistics() {
    try {
      final allTrips = _tripsBox.values.toList();
      final completedTrips = allTrips.where((t) => t.isCompleted).toList();

      return {
        'totalTrips': allTrips.length,
        'activeTrips': allTrips.where((t) => t.isActive).length,
        'matchedTrips': allTrips.where((t) => t.status == TripStatus.matched).length,
        'inTransitTrips': allTrips.where((t) => t.isInTransit).length,
        'deliveredTrips': completedTrips.length,
        'cancelledTrips':
            allTrips.where((t) => t.status == TripStatus.cancelled).length,
        'totalRevenue': completedTrips.fold<double>(0, (sum, t) => sum + t.totalCost),
        'averageTripCost': allTrips.isEmpty
            ? 0.0
            : allTrips.fold<double>(0, (sum, t) => sum + t.totalCost) /
                allTrips.length,
        'totalQuantityTransported':
            completedTrips.fold<double>(0, (sum, t) => sum + t.quantityKg),
        'averageRating': completedTrips.where((t) => t.farmerRating != null).isEmpty
            ? 0.0
            : completedTrips
                    .where((t) => t.farmerRating != null)
                    .fold<double>(0, (sum, t) => sum + t.farmerRating!) /
                completedTrips.where((t) => t.farmerRating != null).length,
      };
    } catch (e) {
      throw Exception('Failed to get trip statistics: $e');
    }
  }

  /// Get farmer statistics
  Map<String, dynamic> getFarmerTransportStatistics(String farmerId) {
    try {
      final farmerRequests = getTransportRequestsByFarmer(farmerId);
      final farmerTrips = getTripsByFarmer(farmerId);
      final completedTrips = farmerTrips.where((t) => t.isCompleted).toList();

      return {
        'totalRequests': farmerRequests.length,
        'activeRequests': farmerRequests.where((r) => r.isActive).length,
        'totalTrips': farmerTrips.length,
        'activeTrips': farmerTrips.where((t) => t.isActive).length,
        'completedTrips': completedTrips.length,
        'totalSpent': completedTrips.fold<double>(0, (sum, t) => sum + t.totalCost),
        'averageTransportCost': completedTrips.isEmpty
            ? 0.0
            : completedTrips.fold<double>(0, (sum, t) => sum + t.totalCost) /
                completedTrips.length,
      };
    } catch (e) {
      throw Exception('Failed to get farmer transport statistics: $e');
    }
  }

  /// Get transporter statistics
  Map<String, dynamic> getTransporterStatistics(String transporterId) {
    try {
      final transporterTrips = getTripsByTransporter(transporterId);
      final completedTrips = transporterTrips.where((t) => t.isCompleted).toList();

      return {
        'totalTrips': transporterTrips.length,
        'activeTrips': transporterTrips.where((t) => t.isActive).length,
        'completedTrips': completedTrips.length,
        'totalEarnings':
            completedTrips.fold<double>(0, (sum, t) => sum + t.totalCost),
        'totalQuantityTransported':
            completedTrips.fold<double>(0, (sum, t) => sum + t.quantityKg),
        'averageRating':
            completedTrips.where((t) => t.farmerRating != null).isEmpty
                ? 0.0
                : completedTrips
                        .where((t) => t.farmerRating != null)
                        .fold<double>(0, (sum, t) => sum + t.farmerRating!) /
                    completedTrips.where((t) => t.farmerRating != null).length,
      };
    } catch (e) {
      throw Exception('Failed to get transporter statistics: $e');
    }
  }

  // ============================================================
  // VALIDATION & HELPERS
  // ============================================================

  void _validateTransportRequest({
    required double quantityKg,
    required String pickupLocation,
    required String deliveryLocation,
    required DateTime requestedPickupDate,
  }) {
    if (quantityKg <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    if (pickupLocation.trim().isEmpty) {
      throw Exception('Pickup location cannot be empty');
    }

    if (deliveryLocation.trim().isEmpty) {
      throw Exception('Delivery location cannot be empty');
    }

    if (requestedPickupDate.isBefore(DateTime.now())) {
      throw Exception('Pickup date cannot be in the past');
    }
  }

  bool _canTripTransitionTo(TripStatus currentStatus, TripStatus newStatus) {
    final allowedTransitions = _validTripTransitions[currentStatus];
    return allowedTransitions?.contains(newStatus) ?? false;
  }

  // ============================================================
  // MOCK DATA GENERATION
  // ============================================================

  /// Initialize mock transport requests and trips
  Future<void> _initializeMockData() async {
    final mockRequests = _generateMockTransportRequests();
    for (final request in mockRequests) {
      await _requestBox.put(request.id, request);
    }

    final mockTrips = _generateMockTrips();
    for (final trip in mockTrips) {
      await _tripsBox.put(trip.id, trip);
    }
  }

  /// Generate 10+ mock transport requests
  List<TransportRequest> _generateMockTransportRequests() {
    final now = DateTime.now();

    return [
      // Pending requests
      TransportRequest(
        id: _uuid.v4(),
        farmerId: 'farmer_001',
        cropType: CropType.teff,
        quantityKg: 500,
        pickupLocation: 'Addis Ababa',
        deliveryLocation: 'Dire Dawa',
        requestedPickupDate: now.add(const Duration(days: 2)),
        status: RequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
        requiresRefrigeration: false,
        specialInstructions: 'Handle with care, premium quality teff',
        responseTransporterIds: ['transporter_001', 'transporter_002'],
      ),
      TransportRequest(
        id: _uuid.v4(),
        farmerId: 'farmer_010',
        cropType: CropType.potato,
        quantityKg: 200,
        pickupLocation: 'Hawassa',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.add(const Duration(days: 1)),
        status: RequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 6)),
        requiresRefrigeration: true,
        specialInstructions: 'Fresh produce - requires refrigerated transport',
        responseTransporterIds: ['transporter_003'],
      ),
      TransportRequest(
        id: _uuid.v4(),
        farmerId: 'farmer_019',
        cropType: CropType.coffee,
        quantityKg: 150,
        pickupLocation: 'Sidamo',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.add(const Duration(days: 3)),
        status: RequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 12)),
        requiresRefrigeration: false,
        specialInstructions: 'Premium coffee beans for export',
        responseTransporterIds: [],
      ),

      // Matched requests
      TransportRequest(
        id: 'trans_req_001',
        farmerId: 'farmer_003',
        cropType: CropType.wheat,
        quantityKg: 800,
        pickupLocation: 'Arsi',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.add(const Duration(days: 2)),
        status: RequestStatus.matched,
        createdAt: now.subtract(const Duration(days: 1)),
        matchedAt: now.subtract(const Duration(hours: 18)),
        matchedTransporterId: 'transporter_001',
        matchedVehicleId: 'vehicle_001',
        agreedPrice: 4500.0,
        requiresRefrigeration: false,
        responseTransporterIds: ['transporter_001', 'transporter_002', 'transporter_004'],
      ),
      TransportRequest(
        id: 'trans_req_002',
        farmerId: 'farmer_015',
        cropType: CropType.other,
        quantityKg: 120,
        pickupLocation: 'Yirgalem',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.add(const Duration(hours: 18)),
        status: RequestStatus.matched,
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
        matchedAt: now.subtract(const Duration(hours: 12)),
        matchedTransporterId: 'transporter_002',
        matchedVehicleId: 'vehicle_002',
        agreedPrice: 2800.0,
        requiresRefrigeration: true,
        specialInstructions: 'Fresh avocados - handle gently',
        responseTransporterIds: ['transporter_002', 'transporter_003'],
      ),

      // Accepted/Completed requests (linked to trips)
      TransportRequest(
        id: 'trans_req_003',
        farmerId: 'farmer_011',
        cropType: CropType.potato,
        quantityKg: 300,
        pickupLocation: 'Mekelle',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.subtract(const Duration(days: 2)),
        status: RequestStatus.accepted,
        createdAt: now.subtract(const Duration(days: 4)),
        matchedAt: now.subtract(const Duration(days: 3)),
        matchedTransporterId: 'transporter_001',
        matchedVehicleId: 'vehicle_001',
        agreedPrice: 5200.0,
        requiresRefrigeration: false,
        responseTransporterIds: ['transporter_001'],
      ),

      // Cancelled request
      TransportRequest(
        id: _uuid.v4(),
        farmerId: 'farmer_016',
        cropType: CropType.other,
        quantityKg: 250,
        pickupLocation: 'Arba Minch',
        deliveryLocation: 'Addis Ababa',
        requestedPickupDate: now.add(const Duration(days: 4)),
        status: RequestStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 5)),
        requiresRefrigeration: false,
        specialInstructions: 'Cancelled due to buyer requirements change',
        responseTransporterIds: [],
      ),
    ];
  }

  /// Generate 8+ mock trips
  List<Trip> _generateMockTrips() {
    final now = DateTime.now();

    return [
      // Matched trip (just created)
      Trip(
        id: _uuid.v4(),
        transportRequestId: 'trans_req_001',
        farmerId: 'farmer_003',
        transporterId: 'transporter_001',
        vehicleId: 'vehicle_001',
        routeId: 'route_001',
        cropType: CropType.wheat,
        quantityKg: 800,
        pickupLocation: 'Arsi',
        deliveryLocation: 'Addis Ababa',
        totalCost: 4500.0,
        status: TripStatus.matched,
        createdAt: now.subtract(const Duration(hours: 18)),
        scheduledPickupTime: now.add(const Duration(days: 2)),
        estimatedArrivalTime: now.add(const Duration(days: 2, hours: 5)),
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(hours: 18)),
            note: 'Trip created and matched with transporter',
            location: 'Arsi',
          ),
        ],
      ),

      // Picked up trip
      Trip(
        id: _uuid.v4(),
        transportRequestId: 'trans_req_002',
        farmerId: 'farmer_015',
        transporterId: 'transporter_002',
        vehicleId: 'vehicle_002',
        routeId: 'route_002',
        cropType: CropType.other,
        quantityKg: 120,
        pickupLocation: 'Yirgalem',
        deliveryLocation: 'Addis Ababa',
        totalCost: 2800.0,
        status: TripStatus.pickedUp,
        createdAt: now.subtract(const Duration(hours: 12)),
        scheduledPickupTime: now.subtract(const Duration(hours: 2)),
        actualPickupTime: now.subtract(const Duration(hours: 1)),
        estimatedArrivalTime: now.add(const Duration(hours: 3)),
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(hours: 12)),
            note: 'Trip matched',
            location: 'Yirgalem',
          ),
          TripStatusUpdate(
            status: TripStatus.pickedUp,
            timestamp: now.subtract(const Duration(hours: 1)),
            note: 'Cargo picked up successfully',
            location: 'Yirgalem',
          ),
        ],
      ),

      // In transit trips
      Trip(
        id: 'trip_001',
        transportRequestId: 'trans_req_003',
        farmerId: 'farmer_011',
        transporterId: 'transporter_001',
        vehicleId: 'vehicle_001',
        routeId: 'route_003',
        cropType: CropType.potato,
        quantityKg: 300,
        pickupLocation: 'Mekelle',
        deliveryLocation: 'Addis Ababa',
        totalCost: 5200.0,
        status: TripStatus.inTransit,
        createdAt: now.subtract(const Duration(days: 3)),
        scheduledPickupTime: now.subtract(const Duration(days: 2)),
        actualPickupTime: now.subtract(const Duration(days: 1, hours: 20)),
        estimatedArrivalTime: now.add(const Duration(hours: 4)),
        currentLocation: 'Dessie',
        currentDistanceKm: 220,
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(days: 3)),
            note: 'Trip matched',
            location: 'Mekelle',
          ),
          TripStatusUpdate(
            status: TripStatus.pickedUp,
            timestamp: now.subtract(const Duration(days: 1, hours: 20)),
            note: 'Cargo loaded and departing',
            location: 'Mekelle',
          ),
          TripStatusUpdate(
            status: TripStatus.inTransit,
            timestamp: now.subtract(const Duration(days: 1, hours: 18)),
            note: 'On route to destination',
            location: 'Woldiya',
          ),
        ],
      ),
      Trip(
        id: _uuid.v4(),
        transportRequestId: _uuid.v4(),
        farmerId: 'farmer_013',
        transporterId: 'transporter_003',
        vehicleId: 'vehicle_003',
        routeId: 'route_004',
        cropType: CropType.potato,
        quantityKg: 450,
        pickupLocation: 'Chencha',
        deliveryLocation: 'Hawassa',
        totalCost: 2200.0,
        status: TripStatus.inTransit,
        createdAt: now.subtract(const Duration(hours: 36)),
        scheduledPickupTime: now.subtract(const Duration(hours: 24)),
        actualPickupTime: now.subtract(const Duration(hours: 22)),
        estimatedArrivalTime: now.add(const Duration(hours: 2)),
        currentLocation: 'Arba Minch',
        currentDistanceKm: 45,
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(hours: 36)),
            note: 'Trip matched',
            location: 'Chencha',
          ),
          TripStatusUpdate(
            status: TripStatus.pickedUp,
            timestamp: now.subtract(const Duration(hours: 22)),
            note: 'Potatoes loaded',
            location: 'Chencha',
          ),
          TripStatusUpdate(
            status: TripStatus.inTransit,
            timestamp: now.subtract(const Duration(hours: 21)),
            note: 'Heading to Hawassa',
            location: 'Near Arba Minch',
          ),
        ],
      ),

      // Delivered trips
      Trip(
        id: _uuid.v4(),
        transportRequestId: _uuid.v4(),
        farmerId: 'farmer_006',
        transporterId: 'transporter_002',
        vehicleId: 'vehicle_002',
        routeId: 'route_005',
        cropType: CropType.beans,
        quantityKg: 350,
        pickupLocation: 'Gojjam',
        deliveryLocation: 'Addis Ababa',
        totalCost: 4800.0,
        status: TripStatus.delivered,
        createdAt: now.subtract(const Duration(days: 8)),
        scheduledPickupTime: now.subtract(const Duration(days: 7)),
        actualPickupTime: now.subtract(const Duration(days: 6, hours: 22)),
        estimatedArrivalTime: now.subtract(const Duration(days: 6, hours: 16)),
        actualDeliveryTime: now.subtract(const Duration(days: 6, hours: 14)),
        farmerRating: 4.5,
        farmerNotes: 'Excellent service, timely delivery',
        transporterRating: 5.0,
        transporterNotes: 'Professional farmer, good packaging',
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(days: 8)),
            note: 'Trip matched',
            location: 'Gojjam',
          ),
          TripStatusUpdate(
            status: TripStatus.pickedUp,
            timestamp: now.subtract(const Duration(days: 6, hours: 22)),
            note: 'Beans loaded',
            location: 'Gojjam',
          ),
          TripStatusUpdate(
            status: TripStatus.inTransit,
            timestamp: now.subtract(const Duration(days: 6, hours: 20)),
            note: 'En route to Addis Ababa',
            location: 'Debre Markos',
          ),
          TripStatusUpdate(
            status: TripStatus.delivered,
            timestamp: now.subtract(const Duration(days: 6, hours: 14)),
            note: 'Successfully delivered to buyer',
            location: 'Addis Ababa',
          ),
        ],
      ),
      Trip(
        id: _uuid.v4(),
        transportRequestId: _uuid.v4(),
        farmerId: 'farmer_004',
        transporterId: 'transporter_001',
        vehicleId: 'vehicle_001',
        routeId: 'route_006',
        cropType: CropType.barley,
        quantityKg: 600,
        pickupLocation: 'Gonder',
        deliveryLocation: 'Bahir Dar',
        totalCost: 3200.0,
        status: TripStatus.delivered,
        createdAt: now.subtract(const Duration(days: 12)),
        scheduledPickupTime: now.subtract(const Duration(days: 11)),
        actualPickupTime: now.subtract(const Duration(days: 10, hours: 20)),
        estimatedArrivalTime: now.subtract(const Duration(days: 10, hours: 14)),
        actualDeliveryTime: now.subtract(const Duration(days: 10, hours: 12)),
        farmerRating: 5.0,
        farmerNotes: 'Perfect trip, very professional',
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(days: 12)),
            note: 'Trip matched',
            location: 'Gonder',
          ),
          TripStatusUpdate(
            status: TripStatus.pickedUp,
            timestamp: now.subtract(const Duration(days: 10, hours: 20)),
            note: 'Barley loaded',
            location: 'Gonder',
          ),
          TripStatusUpdate(
            status: TripStatus.inTransit,
            timestamp: now.subtract(const Duration(days: 10, hours: 18)),
            note: 'En route',
            location: 'Awra Amba',
          ),
          TripStatusUpdate(
            status: TripStatus.delivered,
            timestamp: now.subtract(const Duration(days: 10, hours: 12)),
            note: 'Delivered successfully',
            location: 'Bahir Dar',
          ),
        ],
      ),

      // Cancelled trip
      Trip(
        id: _uuid.v4(),
        transportRequestId: _uuid.v4(),
        farmerId: 'farmer_016',
        transporterId: 'transporter_003',
        vehicleId: 'vehicle_003',
        routeId: 'route_007',
        cropType: CropType.other,
        quantityKg: 200,
        pickupLocation: 'Arba Minch',
        deliveryLocation: 'Addis Ababa',
        totalCost: 3800.0,
        status: TripStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 9)),
        scheduledPickupTime: now.subtract(const Duration(days: 8)),
        statusUpdates: [
          TripStatusUpdate(
            status: TripStatus.matched,
            timestamp: now.subtract(const Duration(days: 9)),
            note: 'Trip matched',
            location: 'Arba Minch',
          ),
          TripStatusUpdate(
            status: TripStatus.cancelled,
            timestamp: now.subtract(const Duration(days: 8, hours: 12)),
            note: 'Cancelled by farmer - buyer requirements changed',
            location: 'Arba Minch',
          ),
        ],
      ),
    ];
  }

  /// Reload mock data (for testing/development)
  Future<void> reloadMockData() async {
    await _requestBox.clear();
    await _tripsBox.clear();
    await _initializeMockData();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _requestBox.clear();
    await _tripsBox.clear();
  }
}
