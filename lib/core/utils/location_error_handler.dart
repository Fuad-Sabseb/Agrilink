import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// LocationErrorHandler - Utility class for location error handling
/// 
/// Provides localized error messages and action widgets for location errors.
/// Handles all LocationError types with appropriate user feedback.
/// 
/// Requirements: 19
class LocationErrorHandler {
  /// Get user-friendly localized error message
  /// 
  /// Maps technical LocationError to human-readable messages
  /// in the user's language (Afaan Oromoo, Amharic, English).
  static String getUserMessage(LocationError error, String currentLang) {
    switch (error) {
      case LocationError.permissionDenied:
        return _getPermissionDeniedMessage(currentLang);
      case LocationError.permissionDeniedForever:
        return _getPermissionDeniedForeverMessage(currentLang);
      case LocationError.serviceDisabled:
        return _getServiceDisabledMessage(currentLang);
      case LocationError.timeout:
        return _getTimeoutMessage(currentLang);
      case LocationError.invalidCoordinates:
        return _getInvalidCoordinatesMessage(currentLang);
      case LocationError.networkUnavailable:
        return _getNetworkErrorMessage(currentLang);
      case LocationError.unknown:
        return _getUnknownErrorMessage(currentLang);
    }
  }

  /// Get action widget for error recovery
  /// 
  /// Returns appropriate action button/widget for the error type.
  /// Actions include: request permission, open settings, retry, enable GPS.
  static Widget getErrorAction(
    LocationError error,
    BuildContext context,
    VoidCallback onAction,
  ) {
    switch (error) {
      case LocationError.permissionDenied:
        return ElevatedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.location_on),
          label: const Text('Request Permission'),
        );
      
      case LocationError.permissionDeniedForever:
        return ElevatedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.settings),
          label: const Text('Open Settings'),
        );
      
      case LocationError.serviceDisabled:
        return ElevatedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Enable GPS'),
        );
      
      case LocationError.timeout:
      case LocationError.networkUnavailable:
      case LocationError.unknown:
        return ElevatedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        );
      
      case LocationError.invalidCoordinates:
        return const SizedBox.shrink(); // No action for invalid coordinates
    }
  }

  // Localized error messages

  static String _getPermissionDeniedMessage(String lang) {
    switch (lang) {
      case 'om': // Afaan Oromoo
        return 'Hayyama bakka jiruu dhowwameera. Mee hayyama kennuudhaaf yaali.';
      case 'am': // Amharic
        return 'የአካባቢ ፈቃድ ተከልክሏል። እባክዎ ፈቃድ ይስጡ።';
      default: // English
        return 'Location permission denied. Please grant permission to continue.';
    }
  }

  static String _getPermissionDeniedForeverMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Hayyama bakka jiruu dhaabbataan dhowwameera. Mee qindaa ina keessaa banuu.';
      case 'am':
        return 'የአካባቢ ፈቃድ በቋሚነት ተከልክሏል። እባክዎ ከቅንብሮች ይክፈቱ።';
      default:
        return 'Location permission permanently denied. Please enable it in Settings.';
    }
  }

  static String _getServiceDisabledMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Tajaajilli GPS dhaabbateera. Mee GPS banuu.';
      case 'am':
        return 'የጂፒኤስ አገልግሎት ተዘግቷል። እባክዎ ጂፒኤስ ያብሩ።';
      default:
        return 'Location services are disabled. Please enable GPS.';
    }
  }

  static String _getTimeoutMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Bakka kee argachuun yeroo darbeera. Mee ammas yaali.';
      case 'am':
        return 'አካባቢዎን ለማግኘት ጊዜው አልፏል። እባክዎ እንደገና ይሞክሩ።';
      default:
        return 'Location acquisition timed out. Please try again.';
    }
  }

  static String _getInvalidCoordinatesMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Coordinates argaman sirrii miti. Mee Ethiopia keessa jiraachuu mirkaneessi.';
      case 'am':
        return 'ያገኙት መጋጠሚያዎች ልክ አይደሉም። እባክዎ ኢትዮጵያ ውስጥ መሆንዎን ያረጋግጡ።';
      default:
        return 'Invalid coordinates detected. Please ensure you are within Ethiopia.';
    }
  }

  static String _getNetworkErrorMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Dogongora network. Mee walitti dhufeenya interneetii kee mirkaneessi.';
      case 'am':
        return 'የኔትወርክ ስህተት። እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡ።';
      default:
        return 'Network error. Please check your internet connection.';
    }
  }

  static String _getUnknownErrorMessage(String lang) {
    switch (lang) {
      case 'om':
        return 'Dogongora hin beekamne uumameera. Mee ammas yaali.';
      case 'am':
        return 'ያልታወቀ ስህተት ተከስቷል። እባክዎ እንደገና ይሞክሩ።';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
