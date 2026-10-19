import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance = BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  final LocationService _locationService = LocationService();
  FlutterBackgroundService? _backgroundService;
  bool _isRunning = false;
  String? _activeTransportTripId;

  bool get isRunning => _isRunning;

  Future<void> initialize() async {
    _backgroundService = FlutterBackgroundService();

    await _backgroundService!.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'AgroLink',
        initialNotificationContent: 'Location tracking active',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startForegroundService(String transportTripId) async {
    if (_isRunning) {
      await stopForegroundService();
    }

    _activeTransportTripId = transportTripId;
    _isRunning = true;

    await _backgroundService?.startService();
  }

  Future<void> stopForegroundService() async {
    _isRunning = false;
    _activeTransportTripId = null;

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stopService');
    }
  }

  void onLocationUpdate(Position position) {
    // Called from background isolate
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'AgroLink',
            content: 'Tracking active trip... ${DateTime.now()}',
          );

          try {
            final position = await Geolocator.getCurrentPosition();
            
            service.invoke('update', {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            // Handle error
          }
        }
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }
}
