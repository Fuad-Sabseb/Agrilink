import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:agrolink/core/services/location_service.dart';
import 'package:agrolink/core/models/location_update.dart';
import 'dart:io';
import 'package:flutter/services.dart';

/// Unit tests for LocationService singleton structure (Task 4.1)
/// Tests singleton pattern, dependency initialization, state fields, and cleanup
/// 
/// Requirements: 2, 4
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late String tempDir;

  setUpAll(() async {
    // Create temporary directory for Hive
    tempDir = Directory.systemTemp.createTempSync('location_test_').path;
    Hive.init(tempDir);
    
    // Register LocationUpdate adapter
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LocationUpdateAdapter());
    }
    
    // Mock permission_handler plugin
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return 0; // Permission.denied
        } else if (methodCall.method == 'requestPermissions') {
          return {0: 0}; // Permission.denied
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    // Clean up Hive and temporary directory
    await Hive.close();
    try {
      Directory(tempDir).deleteSync(recursive: true);
    } catch (_) {
      // Ignore errors during cleanup
    }
    
    // Clear mock handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      null,
    );
  });
  
  tearDown(() async {
    // Clean up after each test
    final service = LocationService();
    service.dispose();
    
    // Close and delete the location_queue box if it exists
    try {
      if (Hive.isBoxOpen('location_queue')) {
        await Hive.box('location_queue').close();
      }
      await Hive.deleteBoxFromDisk('location_queue');
    } catch (_) {
      // Ignore errors
    }
  });

  group('LocationService Singleton Pattern', () {
    test('should return same instance on multiple factory calls', () {
      final instance1 = LocationService();
      final instance2 = LocationService();
      
      expect(instance1, same(instance2));
      expect(identical(instance1, instance2), true);
    });

    test('should be a singleton across multiple accesses', () {
      final instances = List.generate(5, (_) => LocationService());
      
      for (int i = 0; i < instances.length - 1; i++) {
        expect(instances[i], same(instances[i + 1]));
      }
    });
  });

  group('LocationService State Fields', () {
    test('should have initial state values', () {
      final service = LocationService();
      
      // Check initial state before initialization
      expect(service.currentPosition, isNull);
      expect(service.permissionStatus, LocationPermissionStatus.notDetermined);
      expect(service.isTracking, false);
      expect(service.offlineQueueSize, 0);
    });

    test('should have stream getters available', () {
      final service = LocationService();
      
      // Verify stream getters return Stream objects
      expect(service.positionStream, isA<Stream>());
      expect(service.permissionStream, isA<Stream>());
      expect(service.offlineQueueSizeStream, isA<Stream>());
    });

    test('stream controllers should be broadcast streams', () async {
      final service = LocationService();
      
      // Should allow multiple listeners (broadcast stream)
      final sub1 = service.positionStream.listen((_) {});
      final sub2 = service.positionStream.listen((_) {});
      
      expect(sub1, isNotNull);
      expect(sub2, isNotNull);
      
      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('LocationService Initialize', () {
    test('should initialize successfully', () async {
      final service = LocationService();
      
      // Initialize should complete without errors
      await expectLater(service.initialize(), completes);
    });

    test('should initialize only once', () async {
      final service = LocationService();
      
      await service.initialize();
      
      // Second initialization should be idempotent (no-op)
      await expectLater(service.initialize(), completes);
    });

    test('should open offline queue box during initialization', () async {
      final service = LocationService();
      
      await service.initialize();
      
      // Queue size should be available (0 initially)
      expect(service.offlineQueueSize, 0);
    });

    test('should emit initial offline queue size after initialization', () async {
      final service = LocationService();
      
      final queueSizeEmissions = <int>[];
      final subscription = service.offlineQueueSizeStream.listen((size) {
        queueSizeEmissions.add(size);
      });
      
      await service.initialize();
      
      // Wait for async emission
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(queueSizeEmissions.isNotEmpty, true);
      expect(queueSizeEmissions.first, 0);
      
      await subscription.cancel();
    });
  });

  group('LocationService Dispose', () {
    test('should dispose without errors', () {
      final service = LocationService();
      
      expect(() => service.dispose(), returnsNormally);
    });

    test('should reset initialization flag on dispose', () async {
      final service = LocationService();
      
      await service.initialize();
      
      // Dispose should reset initialization flag
      service.dispose();
      
      // Should be able to re-initialize
      await expectLater(service.initialize(), completes);
    });

    test('should cleanup tracking timer on dispose', () async {
      final service = LocationService();
      
      await service.initialize();
      
      // Note: Cannot directly test timer cancellation without mocking,
      // but we verify dispose completes without errors
      service.dispose();
      
      // Should not throw
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('LocationService Dependencies', () {
    test('should have initialized dependencies after initialize()', () async {
      final service = LocationService();
      
      await service.initialize();
      
      // Dependencies should be initialized (cannot directly test private fields,
      // but we verify the service works without errors)
      expect(service.offlineQueueSize, isA<int>());
    });

    test('should have permission status accessible', () {
      final service = LocationService();
      
      expect(service.permissionStatus, isA<LocationPermissionStatus>());
    });
  });

  group('LocationService Enums', () {
    test('LocationPermissionStatus should have all required values', () {
      expect(LocationPermissionStatus.values.length, 6);
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.notDetermined));
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.denied));
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.deniedForever));
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.restricted));
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.whileInUse));
      expect(LocationPermissionStatus.values, contains(LocationPermissionStatus.always));
    });

    test('LocationError should have all required values', () {
      expect(LocationError.values.length, 7);
      expect(LocationError.values, contains(LocationError.permissionDenied));
      expect(LocationError.values, contains(LocationError.permissionDeniedForever));
      expect(LocationError.values, contains(LocationError.serviceDisabled));
      expect(LocationError.values, contains(LocationError.timeout));
      expect(LocationError.values, contains(LocationError.networkUnavailable));
      expect(LocationError.values, contains(LocationError.invalidCoordinates));
      expect(LocationError.values, contains(LocationError.unknown));
    });
  });

  group('LocationService Supporting Classes', () {
    test('LocationResult should store success and error correctly', () {
      final successResult = LocationResult(
        success: true,
        acquisitionTime: const Duration(seconds: 2),
      );
      
      expect(successResult.success, true);
      expect(successResult.error, isNull);
      expect(successResult.position, isNull);
      expect(successResult.acquisitionTime, const Duration(seconds: 2));
      
      final errorResult = LocationResult(
        success: false,
        error: LocationError.timeout,
        acquisitionTime: const Duration(seconds: 30),
      );
      
      expect(errorResult.success, false);
      expect(errorResult.error, LocationError.timeout);
      expect(errorResult.position, isNull);
    });

    test('Market should store coordinates correctly', () {
      final market = Market(
        id: 'market-1',
        name: 'Test Market',
        latitude: 9.0,
        longitude: 38.5,
      );
      
      expect(market.id, 'market-1');
      expect(market.name, 'Test Market');
      expect(market.latitude, 9.0);
      expect(market.longitude, 38.5);
    });

    test('MarketDistance should store market and distance', () {
      final market = Market(
        id: 'market-1',
        name: 'Test Market',
        latitude: 9.0,
        longitude: 38.5,
      );
      
      final marketDistance = MarketDistance(
        market: market,
        distanceKm: 12.5,
      );
      
      expect(marketDistance.market, market);
      expect(marketDistance.distanceKm, 12.5);
    });
  });
}
