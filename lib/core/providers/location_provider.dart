import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../models/location_coordinate.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.notDetermined;
  bool _isTracking = false;
  bool _isAcquiringLocation = false;
  LocationError? _lastError;
  int _offlineQueueSize = 0;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<LocationPermissionStatus>? _permissionSubscription;
  StreamSubscription<int>? _queueSubscription;

  Position? get currentPosition => _currentPosition;
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isTracking => _isTracking;
  bool get isAcquiringLocation => _isAcquiringLocation;
  LocationError? get lastError => _lastError;
  int get offlineQueueSize => _offlineQueueSize;
  bool get hasPermission => 
      _permissionStatus == LocationPermissionStatus.whileInUse ||
      _permissionStatus == LocationPermissionStatus.always;

  Future<void> initialize() async {
    await _locationService.initialize();

    _positionSubscription = _locationService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _permissionSubscription = _locationService.permissionStream.listen((status) {
      _permissionStatus = status;
      notifyListeners();
    });

    _queueSubscription = _locationService.offlineQueueSizeStream.listen((size) {
      _offlineQueueSize = size;
      notifyListeners();
    });

    _permissionStatus = await _locationService.checkPermission();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    _permissionStatus = await _locationService.requestPermission();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _isAcquiringLocation = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _locationService.getCurrentLocation();
      
      if (result.success) {
        _currentPosition = result.position;
        _lastError = null;
      } else {
        _lastError = result.error;
      }
    } finally {
      _isAcquiringLocation = false;
      notifyListeners();
    }
  }

  Future<void> startTracking(String transportTripId) async {
    await _locationService.startTracking(transportTripId);
    _isTracking = true;
    notifyListeners();
  }

  Future<void> stopTracking() async {
    await _locationService.stopTracking();
    _isTracking = false;
    notifyListeners();
  }

  Future<double> calculateDistance(
    LocationCoordinate from,
    LocationCoordinate to,
  ) async {
    return await _locationService.calculateDistance(from, to);
  }

  Future<List<MarketDistance>> getNearestMarkets(
    LocationCoordinate farmLocation,
    List<Market> markets,
  ) async {
    return await _locationService.calculateNearestMarkets(farmLocation, markets);
  }

  Future<void> syncOfflineQueue() async {
    await _locationService.syncOfflineQueue();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _permissionSubscription?.cancel();
    _queueSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
