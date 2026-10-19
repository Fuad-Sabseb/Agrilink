import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric Authentication Service
/// Handles fingerprint and face ID authentication
class BiometricService {
  final LocalAuthentication _localAuth;
  static const String _biometricEnabledKey = 'biometric_enabled';

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  // ==================== Device Support Check ====================

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if device has biometric hardware and enrolled biometrics
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Get human-readable string for available biometrics
  Future<String> getAvailableBiometricsString() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return 'None';

    final types = <String>[];
    if (biometrics.contains(BiometricType.face)) {
      types.add('Face ID');
    }
    if (biometrics.contains(BiometricType.fingerprint)) {
      types.add('Fingerprint');
    }
    if (biometrics.contains(BiometricType.iris)) {
      types.add('Iris');
    }
    if (biometrics.contains(BiometricType.strong)) {
      types.add('Strong Biometric');
    }
    if (biometrics.contains(BiometricType.weak)) {
      types.add('Weak Biometric');
    }

    return types.join(', ');
  }

  // ==================== Authentication ====================

  /// Authenticate user using biometrics
  /// Returns true if authentication was successful
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access AgroLink',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow device credentials as fallback
        ),
      );
    } on PlatformException catch (e) {
      // Handle specific errors
      if (e.code == 'NotAvailable') {
        // Biometric not available
        return false;
      } else if (e.code == 'NotEnrolled') {
        // No biometrics enrolled
        return false;
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        // Too many failed attempts
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Quick authentication check (without showing error dialogs)
  Future<bool> quickAuthenticate() async {
    return await authenticate(
      localizedReason: 'Quick authentication',
      useErrorDialogs: false,
      stickyAuth: false,
    );
  }

  // ==================== Settings Management ====================

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// Toggle biometric authentication
  /// Returns the new state
  Future<bool> toggleBiometric() async {
    final currentState = await isBiometricEnabled();
    if (currentState) {
      await disableBiometric();
      return false;
    } else {
      // Verify biometric before enabling
      final authenticated = await authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      if (authenticated) {
        await enableBiometric();
        return true;
      }
      return false;
    }
  }

  // ==================== Helper Methods ====================

  /// Stop ongoing authentication (if any)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get error message for common biometric errors
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device';
      case 'NotEnrolled':
        return 'No biometrics enrolled. Please set up fingerprint or face ID in your device settings';
      case 'LockedOut':
        return 'Too many failed attempts. Please try again later';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is permanently locked. Please use device credentials';
      case 'PasscodeNotSet':
        return 'Please set up a device passcode first';
      default:
        return 'Biometric authentication failed';
    }
  }
}
