import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/location_error_handler.dart';

/// Location Test Screen - Demo UI for testing location services
/// 
/// Features:
/// - Current location display
/// - Permission status indicator
/// - Error messages with action buttons
/// - Offline queue monitoring
/// - Transport tracking controls
class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({Key? key}) : super(key: key);

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  String _currentLanguage = 'en'; // TODO: Get from app settings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Services Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: 'Switch Language (en/om/am)',
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLanguageIndicator(),
                const SizedBox(height: 16),
                _buildPermissionCard(locationProvider),
                const SizedBox(height: 16),
                _buildLocationCard(locationProvider),
                const SizedBox(height: 16),
                _buildTrackingCard(locationProvider),
                const SizedBox(height: 16),
                _buildOfflineQueueCard(locationProvider),
                const SizedBox(height: 16),
                _buildErrorCard(locationProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageIndicator() {
    final languageNames = {
      'en': 'English',
      'om': 'Afaan Oromoo',
      'am': 'አማርኛ (Amharic)',
    };
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.language, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              'Current Language: ${languageNames[_currentLanguage]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(LocationProvider provider) {
    final hasPermission = provider.hasPermission;
    final status = provider.permissionStatus;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPermission ? Icons.check_circle : Icons.error,
                  color: hasPermission ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Location Permission',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Status: ${status.toString().split('.').last}'),
            const SizedBox(height: 12),
            if (!hasPermission)
              ElevatedButton.icon(
                onPressed: () => provider.requestPermission(),
                icon: const Icon(Icons.location_on),
                label: const Text('Request Permission'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(LocationProvider provider) {
    final position = provider.currentPosition;
    final isAcquiring = provider.isAcquiringLocation;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (isAcquiring)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Acquiring location...'),
                  ],
                ),
              )
            else if (position != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: ${position.latitude.toStringAsFixed(6)}'),
                  Text('Longitude: ${position.longitude.toStringAsFixed(6)}'),
                  Text('Accuracy: ${position.accuracy.toStringAsFixed(1)}m'),
                  Text('Timestamp: ${DateTime.now().toString().substring(0, 19)}'),
                ],
              )
            else
              const Text('No location data'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isAcquiring ? null : () => provider.getCurrentLocation(),
              icon: const Icon(Icons.my_location),
              label: const Text('Get Current Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard(LocationProvider provider) {
    final isTracking = provider.isTracking;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isTracking ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Transport Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(isTracking ? 'Status: Active' : 'Status: Inactive'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isTracking
                        ? null
                        : () => provider.startTracking('test-trip-${DateTime.now().millisecondsSinceEpoch}'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isTracking ? () => provider.stopTracking() : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineQueueCard(LocationProvider provider) {
    final queueSize = provider.offlineQueueSize;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  queueSize > 0 ? Icons.cloud_queue : Icons.cloud_done,
                  color: queueSize > 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Offline Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Pending updates: $queueSize'),
            if (queueSize > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Updates will sync when online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(LocationProvider provider) {
    final error = provider.lastError;
    
    if (error == null) {
      return Card(
        color: Colors.green[50],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text(
                'No errors',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    
    final errorMessage = LocationErrorHandler.getUserMessage(error, _currentLanguage);
    
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            LocationErrorHandler.getErrorAction(
              error,
              context,
              () => _handleErrorAction(error, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _handleErrorAction(LocationError error, LocationProvider provider) {
    switch (error) {
      case LocationError.permissionDenied:
        provider.requestPermission();
        break;
      case LocationError.permissionDeniedForever:
        // TODO: Open app settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location permission in Settings')),
        );
        break;
      case LocationError.serviceDisabled:
        // TODO: Open location settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable GPS in device settings')),
        );
        break;
      default:
        provider.getCurrentLocation();
        break;
    }
  }

  void _toggleLanguage() {
    setState(() {
      if (_currentLanguage == 'en') {
        _currentLanguage = 'om';
      } else if (_currentLanguage == 'om') {
        _currentLanguage = 'am';
      } else {
        _currentLanguage = 'en';
      }
    });
  }
}
