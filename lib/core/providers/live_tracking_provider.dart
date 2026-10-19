import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/location_update.dart';
import '../models/trip_model.dart';
import '../services/live_location_tracking_service.dart';
import '../services/realtime_tracking_service.dart';

/// Provider for managing live tracking state and subscriptions
/// 
/// Responsibilities:
/// - Start/stop tracking for transporters
/// - Subscribe to location updates for buyers/farmers
/// - Manage connection state
/// - Handle authorization
/// - Coordinate between tracking and viewing
class LiveTrackingProvider with ChangeNotifier {
  final LiveLocationTrackingService _trackingService = LiveLocationTrackingService();
  final RealtimeTrackingService _realtimeService = RealtimeTrackingService();

  // Tracking state (for transporters)
  bool _isTracking = false;
  String? _activeTripId;
  TrackingState _trackingState = TrackingState.stopped;
  String? _trackingError;

  // Viewing state (for buyers/farmers)
  final Map<String, LocationUpdate> _tripLocations = {};
  final Map<String, StreamSubscription<LocationUpdate>> _locationSubscriptions = {};
  final Map<String, StreamSubscription<TripStatusUpdate>> _statusSubscriptions = {};

  // Connection state
  ConnectionState _connectionState = ConnectionState.disconnected;
  StreamSubscription<ConnectionState>? _connectionSubscription;

  // Getters
  bool get isTracking => _isTracking;
  String? get activeTripId => _activeTripId;
  TrackingState get trackingState => _trackingState;
  String? get trackingError => _trackingError;
  ConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == ConnectionState.connected;

  /// Get latest location for a trip
  LocationUpdate? getLocationForTrip(String tripId) {
    return _tripLocations[tripId];
  }

  /// Initialize provider
  Future<void> initialize(String authToken) async {
    await _realtimeService.initialize(authToken);

    // Listen to connection state changes
    _connectionSubscription = _realtimeService.connectionStateStream.listen(
      (state) {
        _connectionState = state;
        notifyListeners();
      },
    );

    // Listen to tracking state changes
    _trackingService.trackingStateStream.listen(
      (state) {
        _trackingState = state;
        notifyListeners();
      },
    );
  }

  /// Start tracking (for transporter)
  Future<bool> startTracking({
    required String tripId,
    required TripStatus tripStatus,
    required String transporterId,
  }) async {
    _trackingError = null;
    notifyListeners();

    final result = await _trackingService.startTracking(
      tripId: tripId,
      tripStatus: tripStatus,
      transporterId: transporterId,
    );

    if (result.success) {
      _isTracking = true;
      _activeTripId = tripId;
    } else {
      _trackingError = result.error;
    }

    notifyListeners();
    return result.success;
  }

  /// Stop tracking (for transporter)
  Future<void> stopTracking() async {
    await _trackingService.stopTracking();
    _isTracking = false;
    _activeTripId = null;
    _trackingError = null;
    notifyListeners();
  }

  /// Update trip status (automatically stops tracking if delivered/cancelled)
  Future<void> updateTripStatus(TripStatus newStatus) async {
    await _trackingService.updateTripStatus(newStatus);

    if (newStatus == TripStatus.delivered || newStatus == TripStatus.cancelled) {
      _isTracking = false;
      _activeTripId = null;
    }

    notifyListeners();
  }

  /// Subscribe to live location updates for a trip (for buyer/farmer)
  Future<bool> subscribeToTripLocation({
    required String tripId,
    required String userId,
  }) async {
    // Already subscribed
    if (_locationSubscriptions.containsKey(tripId)) {
      return true;
    }

    try {
      // Ensure connected
      if (!_realtimeService.isConnected) {
        await _realtimeService.connect();
      }

      // Subscribe to location stream
      final stream = _realtimeService.subscribeToTripLocation(tripId, userId);
      
      final subscription = stream.listen(
        (update) {
          _tripLocations[tripId] = update;
          notifyListeners();
        },
        onError: (error) {
          print('Location subscription error: $error');
          // Handle unauthorized access
          unsubscribeFromTripLocation(tripId);
        },
      );

      _locationSubscriptions[tripId] = subscription;
      return true;
    } catch (e) {
      print('Failed to subscribe to trip location: $e');
      return false;
    }
  }

  /// Unsubscribe from trip location updates
  void unsubscribeFromTripLocation(String tripId) {
    _locationSubscriptions[tripId]?.cancel();
    _locationSubscriptions.remove(tripId);
    _tripLocations.remove(tripId);
    _realtimeService.unsubscribeFromTripLocation(tripId);
    notifyListeners();
  }

  /// Subscribe to trip status updates
  Future<bool> subscribeToTripStatus({
    required String tripId,
    required String userId,
    required Function(TripStatusUpdate) onUpdate,
  }) async {
    // Already subscribed
    if (_statusSubscriptions.containsKey(tripId)) {
      return true;
    }

    try {
      // Ensure connected
      if (!_realtimeService.isConnected) {
        await _realtimeService.connect();
      }

      // Subscribe to status stream
      final stream = _realtimeService.subscribeToTripStatus(tripId, userId);
      
      final subscription = stream.listen(
        (update) {
          onUpdate(update);
          notifyListeners();
        },
        onError: (error) {
          print('Status subscription error: $error');
          unsubscribeFromTripStatus(tripId);
        },
      );

      _statusSubscriptions[tripId] = subscription;
      return true;
    } catch (e) {
      print('Failed to subscribe to trip status: $e');
      return false;
    }
  }

  /// Unsubscribe from trip status updates
  void unsubscribeFromTripStatus(String tripId) {
    _statusSubscriptions[tripId]?.cancel();
    _statusSubscriptions.remove(tripId);
    _realtimeService.unsubscribeFromTripStatus(tripId);
    notifyListeners();
  }

  /// Clean up subscriptions for a trip
  void cleanupTrip(String tripId) {
    unsubscribeFromTripLocation(tripId);
    unsubscribeFromTripStatus(tripId);
  }

  /// Connect to real-time service
  Future<void> connect() async {
    if (!_realtimeService.isConnected) {
      await _realtimeService.connect();
    }
  }

  /// Disconnect from real-time service
  Future<void> disconnect() async {
    await _realtimeService.disconnect();
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _locationSubscriptions.values) {
      subscription.cancel();
    }
    for (final subscription in _statusSubscriptions.values) {
      subscription.cancel();
    }

    _locationSubscriptions.clear();
    _statusSubscriptions.clear();
    _tripLocations.clear();

    _connectionSubscription?.cancel();

    super.dispose();
  }
}
