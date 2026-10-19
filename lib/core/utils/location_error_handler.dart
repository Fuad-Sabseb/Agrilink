import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationErrorHandler {
  static String getUserMessage(LocationError error, BuildContext context) {
    switch (error) {
      case LocationError.permissionDenied:
        return 'Location permission is required to use this feature. Please grant permission.';
      case LocationError.permissionDeniedForever:
        return 'Location permission was permanently denied. Please enable it in settings.';
      case LocationError.serviceDisabled:
        return 'Location services are disabled. Please enable location in device settings.';
      case LocationError.timeout:
        return 'Unable to get your location. Please try again.';
      case LocationError.networkUnavailable:
        return 'Network location is unavailable. Please check your connection.';
      case LocationError.invalidCoordinates:
        return 'Invalid location coordinates. Please try again.';
      case LocationError.unknown:
        return 'An error occurred while getting your location.';
    }
  }

  static Widget? getErrorAction(LocationError error, VoidCallback onRetry) {
    switch (error) {
      case LocationError.permissionDenied:
        return ElevatedButton(
          onPressed: onRetry,
          child: const Text('Grant Permission'),
        );
      case LocationError.permissionDeniedForever:
        return ElevatedButton(
          onPressed: () => openAppSettings(),
          child: const Text('Open Settings'),
        );
      case LocationError.serviceDisabled:
        return ElevatedButton(
          onPressed: () => openAppSettings(),
          child: const Text('Open Settings'),
        );
      case LocationError.timeout:
      case LocationError.networkUnavailable:
      case LocationError.invalidCoordinates:
      case LocationError.unknown:
        return ElevatedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        );
    }
  }
}
