import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/location_coordinate.dart';
import '../models/location_update.dart';
import '../network/api_client.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiClient _apiClient = ApiClient();
  
  Position? _currentPosition;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.notDetermined;
  bool _isTracking = false;
  String? _activeTransportTripId;
  Timer? _trackingTimer;
  Box<LocationUpdate>? _offlineQueueBox;
  final Map<String, DateTime> _distanceCache = {};

  final StreamController<Position> _positionController = StreamController.broadcast();
  final StreamController<LocationPermissionStatus> _permissionController = StreamController.broadcast();
  final StreamController<int> _offlineQueueController = StreamController.broadcast();

  Position? get currentPosition => _currentPosition;
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isTracking => _isTracking;
  int get offlineQueueSize => _offlineQueueBox?.values.where((u) => !u.synced).length ?? 0;

  Stream<Position> get positionStream => _positionController.stream;
  Stream<LocationPermissionStatus> get permissionStream => _permissionController.stream;
  Stream<int> get offlineQueueSizeStream => _offlineQueueController.stream;

  Future<void> initialize() async {
    _offlineQueueBox = await Hive.openBox<LocationUpdate>('location_queue');
    await checkPermission();
    _offlineQueueController.add(offlineQueueSize);
  }

  Future<LocationPermissionStatus> checkPermission() async {
    final permission = await Permission.location.status;
    
    if (permission.isGranted) {
      _permissionStatus = LocationPermissionStatus.whileInUse;
    } else if (permission.isDenied) {
      _permissionStatus = LocationPermissionStatus.denied;
    } else if (permission.isPermanentlyDenied) {
      _permissionStatus = LocationPermissionStatus.deniedForever;
    } else if (permission.isRestricted) {
      _permissionStatus = LocationPermissionStatus.restricted;
    } else {
      _permissionStatus = LocationPermissionStatus.notDetermined;
    }
    
    _permissionController.add(_permissionStatus);
    return _permissionStatus;
  }

  Future<LocationPermissionStatus> requestPermission() async {
    final permission = await Permission.location.request();
    
    if (permission.isGranted) {
      _permissionStatus = LocationPermissionStatus.whileInUse;
    } else if (permission.isDenied) {
      _permissionStatus = LocationPermissionStatus.denied;
    } else if (permission.isPermanentlyDenied) {
      _permissionStatus = LocationPermissionStatus.deniedForever;
    } else {
      _permissionStatus = LocationPermissionStatus.restricted;
    }
    
    _permissionController.add(_permissionStatus);
    return _permissionStatus;
  }

  Future<LocationResult> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final permStatus = await checkPermission();
      if (permStatus != LocationPermissionStatus.whileInUse &&
          permStatus != LocationPermissionStatus.always) {
        return LocationResult(
          success: false,
          error: LocationError.permissionDenied,
          acquisitionTime: DateTime.now().difference(startTime),
        );
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          error: LocationError.serviceDisabled,
          acquisitionTime: DateTime.now().difference(startTime),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: const Duration(seconds: 30),
      );

      try {
        final coordinate = LocationCoordinate(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        _currentPosition = position;
        _positionController.add(position);
        
        return LocationResult(
          success: true,
          position: position,
          acquisitionTime: DateTime.now().difference(startTime),
        );
      } on InvalidLocationException {
        return LocationResult(
          success: false,
          error: LocationError.invalidCoordinates,
          acquisitionTime: DateTime.now().difference(startTime),
        );
      }
    } on TimeoutException {
      return LocationResult(
        success: false,
        error: LocationError.timeout,
        acquisitionTime: DateTime.now().difference(startTime),
      );
    } catch (e) {
      return LocationResult(
        success: false,
        error: LocationError.unknown,
        acquisitionTime: DateTime.now().difference(startTime),
      );
    }
  }

  Future<double> calculateDistance(
    LocationCoordinate from,
    LocationCoordinate to,
  ) async {
    final cacheKey = '${from.latitude},${from.longitude}-${to.latitude},${to.longitude}';
    final cachedTime = _distanceCache[cacheKey];
    
    if (cachedTime != null && 
        DateTime.now().difference(cachedTime).inHours < 24) {
      // Cache valid
    }

    const earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(to.latitude - from.latitude);
    final dLon = _degreesToRadians(to.longitude - from.longitude);
    
    final lat1 = _degreesToRadians(from.latitude);
    final lat2 = _degreesToRadians(to.latitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;
    
    _distanceCache[cacheKey] = DateTime.now();
    
    return double.parse(distance.toStringAsFixed(1));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<List<MarketDistance>> calculateNearestMarkets(
    LocationCoordinate farmLocation,
    List<Market> markets,
  ) async {
    final distances = <MarketDistance>[];
    
    for (final market in markets) {
      final distance = await calculateDistance(
        farmLocation,
        LocationCoordinate(
          latitude: market.latitude,
          longitude: market.longitude,
        ),
      );
      distances.add(MarketDistance(market: market, distanceKm: distance));
    }
    
    distances.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return distances.take(10).toList();
  }

  Future<void> startTracking(String transportTripId) async {
    if (_isTracking) {
      await stopTracking();
    }
    
    _activeTransportTripId = transportTripId;
    _isTracking = true;
    
    _trackingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        await _updateLocation();
      },
    );
    
    await _updateLocation();
  }

  Future<void> stopTracking() async {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _activeTransportTripId = null;
    await syncOfflineQueue();
  }

  Future<void> _updateLocation() async {
    if (!_isTracking || _activeTransportTripId == null) return;
    
    final result = await getCurrentLocation();
    
    if (result.success && result.position != null) {
      final update = LocationUpdate(
        id: const Uuid().v4(),
        transportTripId: _activeTransportTripId!,
        latitude: result.position!.latitude,
        longitude: result.position!.longitude,
        timestamp: DateTime.now(),
        synced: false,
      );
      
      try {
        await _apiClient.sendLocationUpdate(update);
        final syncedUpdate = update.copyWith(synced: true);
        await _offlineQueueBox?.put(update.id, syncedUpdate);
      } catch (e) {
        await _offlineQueueBox?.put(update.id, update);
        _offlineQueueController.add(offlineQueueSize);
      }
    }
  }

  Future<void> syncOfflineQueue() async {
    if (_offlineQueueBox == null) return;
    
    final unsyncedUpdates = _offlineQueueBox!.values
        .where((u) => !u.synced)
        .toList();
    
    if (unsyncedUpdates.isEmpty) return;
    
    const batchSize = 50;
    for (var i = 0; i < unsyncedUpdates.length; i += batchSize) {
      final batch = unsyncedUpdates.skip(i).take(batchSize).toList();
      
      var retries = 0;
      var success = false;
      
      while (retries < 3 && !success) {
        try {
          await _apiClient.sendLocationBatch(batch);
          
          for (final update in batch) {
            final synced = update.copyWith(synced: true);
            await _offlineQueueBox?.put(update.id, synced);
          }
          
          success = true;
        } catch (e) {
          retries++;
          if (retries < 3) {
            await Future.delayed(Duration(seconds: pow(2, retries).toInt()));
          }
        }
      }
      
      if (!success) {
        for (final update in batch) {
          await _offlineQueueBox?.delete(update.key);
        }
      }
    }
    
    _offlineQueueController.add(offlineQueueSize);
  }

  void dispose() {
    _trackingTimer?.cancel();
    _positionController.close();
    _permissionController.close();
    _offlineQueueController.close();
  }
}

enum LocationPermissionStatus {
  notDetermined,
  denied,
  deniedForever,
  restricted,
  whileInUse,
  always,
}

enum LocationError {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  timeout,
  networkUnavailable,
  invalidCoordinates,
  unknown,
}

class LocationResult {
  final bool success;
  final Position? position;
  final LocationError? error;
  final Duration acquisitionTime;

  LocationResult({
    required this.success,
    this.position,
    this.error,
    required this.acquisitionTime,
  });
}

class Market {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Market({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class MarketDistance {
  final Market market;
  final double distanceKm;

  MarketDistance({required this.market, required this.distanceKm});
}
