import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/location_error_handler.dart';
import '../../core/utils/notification_error_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Error Testing Screen - Comprehensive error scenario testing
/// 
/// Tests all error types with localized messages:
/// - Location errors (7 types)
/// - Notification errors (FCM errors)
/// - Deep link errors
/// - Network errors
/// 
/// Available in DEBUG builds only
class ErrorTestingScreen extends StatefulWidget {
  const ErrorTestingScreen({Key? key}) : super(key: key);

  @override
  State<ErrorTestingScreen> createState() => _ErrorTestingScreenState();
}

class _ErrorTestingScreenState extends State<ErrorTestingScreen> {
  String _currentLanguage = 'en';
  String? _lastTestResult;
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Testing (DEBUG)'),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageCard(),
          const SizedBox(height: 16),
          _buildTestResultCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Location Errors'),
          _buildLocationErrorTests(),
          const SizedBox(height: 24),
          _buildSectionHeader('Notification Errors'),
          _buildNotificationErrorTests(),
          const SizedBox(height: 24),
          _buildSectionHeader('Deep Link Errors'),
          _buildDeepLinkErrorTests(),
          const SizedBox(height: 24),
          _buildSectionHeader('Comprehensive Test'),
          _buildComprehensiveTest(),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    final languageNames = {
      'en': 'English',
      'om': 'Afaan Oromoo',
      'am': 'አማርኛ (Amharic)',
    };
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.language, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Language',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(languageNames[_currentLanguage]!),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _toggleLanguage,
              child: const Text('Switch'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultCard() {
    if (_lastTestResult == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No test results yet. Tap a test button to begin.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Last Test Result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_lastTestResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  Widget _buildLocationErrorTests() {
    return Column(
      children: [
        _buildErrorTestButton(
          'Permission Denied',
          LocationError.permissionDenied,
          Icons.block,
        ),
        _buildErrorTestButton(
          'Permission Denied Forever',
          LocationError.permissionDeniedForever,
          Icons.not_interested,
        ),
        _buildErrorTestButton(
          'Service Disabled',
          LocationError.serviceDisabled,
          Icons.gps_off,
        ),
        _buildErrorTestButton(
          'Timeout',
          LocationError.timeout,
          Icons.hourglass_empty,
        ),
        _buildErrorTestButton(
          'Invalid Coordinates',
          LocationError.invalidCoordinates,
          Icons.location_off,
        ),
        _buildErrorTestButton(
          'Network Error',
          LocationError.networkUnavailable,
          Icons.signal_wifi_off,
        ),
        _buildErrorTestButton(
          'Unknown Error',
          LocationError.unknown,
          Icons.help_outline,
        ),
      ],
    );
  }

  Widget _buildErrorTestButton(String label, LocationError error, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: _isTesting ? null : () => _testLocationError(error),
        icon: Icon(icon),
        label: SizedBox(
          width: double.infinity,
          child: Text(label),
        ),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNotificationErrorTests() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isTesting ? null : () => _testNotificationError('permission-denied'),
          icon: const Icon(Icons.notifications_off),
          label: const SizedBox(
            width: double.infinity,
            child: Text('FCM Permission Denied'),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isTesting ? null : () => _testNotificationError('unavailable'),
          icon: const Icon(Icons.cloud_off),
          label: const SizedBox(
            width: double.infinity,
            child: Text('FCM Service Unavailable'),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isTesting ? null : () => _testNotificationError('deadline-exceeded'),
          icon: const Icon(Icons.access_time),
          label: const SizedBox(
            width: double.infinity,
            child: Text('FCM Timeout'),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDeepLinkErrorTests() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isTesting ? null : () => _testDeepLinkError('agrolink://invalid-route'),
          icon: const Icon(Icons.link_off),
          label: const SizedBox(
            width: double.infinity,
            child: Text('Invalid Deep Link Route'),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isTesting ? null : () => _testDeepLinkError('http://malformed'),
          icon: const Icon(Icons.error),
          label: const SizedBox(
            width: double.infinity,
            child: Text('Malformed Deep Link'),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildComprehensiveTest() {
    return ElevatedButton.icon(
      onPressed: _isTesting ? null : _runComprehensiveTest,
      icon: _isTesting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.play_circle_filled),
      label: const Text('Run All Tests'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _testLocationError(LocationError error) async {
    setState(() => _isTesting = true);
    
    try {
      final message = LocationErrorHandler.getUserMessage(error, _currentLanguage);
      
      await _showErrorDialog(
        'Location Error Test',
        message,
        error,
        context,
      );
      
      setState(() {
        _lastTestResult = '✓ ${error.toString().split('.').last}: Message displayed in $_currentLanguage';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '✗ Test failed: $e';
        _isTesting = false;
      });
    }
  }

  Future<void> _testNotificationError(String errorCode) async {
    setState(() => _isTesting = true);
    
    try {
      final mockError = FirebaseException(
        plugin: 'firebase_messaging',
        code: errorCode,
        message: 'Mock error for testing',
      );
      
      final message = NotificationErrorHandler.getUserMessage(mockError, _currentLanguage);
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Error Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Error Code: $errorCode'),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      
      setState(() {
        _lastTestResult = '✓ $errorCode: Message displayed in $_currentLanguage';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '✗ Test failed: $e';
        _isTesting = false;
      });
    }
  }

  Future<void> _testDeepLinkError(String deepLink) async {
    setState(() => _isTesting = true);
    
    try {
      await NotificationErrorHandler.handleDeepLinkError(
        deepLink,
        Exception('Invalid deep link format'),
      );
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Deep Link Error Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deep Link:'),
              Text(
                deepLink,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Error logged and handled gracefully.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      
      setState(() {
        _lastTestResult = '✓ Deep link error handled: $deepLink';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '✗ Test failed: $e';
        _isTesting = false;
      });
    }
  }

  Future<void> _runComprehensiveTest() async {
    setState(() => _isTesting = true);
    
    final results = <String>[];
    int passed = 0;
    int total = 0;
    
    // Test all location errors
    for (final error in LocationError.values) {
      total++;
      try {
        LocationErrorHandler.getUserMessage(error, _currentLanguage);
        results.add('✓ Location: ${error.toString().split('.').last}');
        passed++;
      } catch (e) {
        results.add('✗ Location: ${error.toString().split('.').last} - $e');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Test notification errors
    final notifErrors = ['permission-denied', 'unavailable', 'deadline-exceeded'];
    for (final code in notifErrors) {
      total++;
      try {
        final mockError = FirebaseException(
          plugin: 'firebase_messaging',
          code: code,
          message: 'Test',
        );
        NotificationErrorHandler.getUserMessage(mockError, _currentLanguage);
        results.add('✓ Notification: $code');
        passed++;
      } catch (e) {
        results.add('✗ Notification: $code - $e');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    setState(() {
      _lastTestResult = 'Comprehensive Test Complete:\n$passed/$total tests passed\n\nLanguage: $_currentLanguage';
      _isTesting = false;
    });
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprehensive Test Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$passed/$total tests passed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: passed == total ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              ...results.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(r),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(
    String title,
    String message,
    LocationError error,
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Action Button:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LocationErrorHandler.getErrorAction(
              error,
              context,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action button pressed')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      _lastTestResult = null; // Reset results when language changes
    });
  }
}
