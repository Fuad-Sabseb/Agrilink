import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// UserContext Helper - Provides easy access to current user information
/// Use this instead of hardcoded user IDs throughout the app
class UserContext {
  /// Get current user ID (nullable)
  static String? getCurrentUserId(BuildContext context, {bool listen = false}) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: listen);
      return authProvider.user?.id;
    } catch (e) {
      debugPrint('UserContext: Failed to get user ID: $e');
      return null;
    }
  }

  /// Get current user ID or throw exception if not authenticated
  static String getCurrentUserIdOrThrow(BuildContext context) {
    final id = getCurrentUserId(context);
    if (id == null || id.isEmpty) {
      throw Exception('User not authenticated. Please log in.');
    }
    return id;
  }

  /// Get current user role (nullable)
  static String? getCurrentUserRole(BuildContext context, {bool listen = false}) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: listen);
      return authProvider.user?.role;
    } catch (e) {
      debugPrint('UserContext: Failed to get user role: $e');
      return null;
    }
  }

  /// Get current user full name (nullable)
  static String? getCurrentUserName(BuildContext context, {bool listen = false}) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: listen);
      return authProvider.user?.fullName;
    } catch (e) {
      debugPrint('UserContext: Failed to get user name: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.isAuthenticated;
    } catch (e) {
      debugPrint('UserContext: Failed to check authentication: $e');
      return false;
    }
  }

  /// Check if user has specific role
  static bool hasRole(BuildContext context, String role) {
    final userRole = getCurrentUserRole(context);
    return userRole?.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is farmer
  static bool isFarmer(BuildContext context) {
    return hasRole(context, 'farmer');
  }

  /// Check if user is buyer
  static bool isBuyer(BuildContext context) {
    return hasRole(context, 'buyer');
  }

  /// Check if user is transporter
  static bool isTransporter(BuildContext context) {
    return hasRole(context, 'transporter');
  }

  /// Check if user is bureau officer
  static bool isBureauOfficer(BuildContext context) {
    return hasRole(context, 'bureau_officer');
  }
}
