import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  static const String _cacheBoxName = 'dashboard_cache';
  static const Duration _cacheValidity = Duration(minutes: 15);

  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  Map<String, dynamic>? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;
  
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidity;
  }

  /// Fetch dashboard data for specific role
  Future<void> fetchDashboardData(String role) async {
    // Return cached data if valid
    if (isCacheValid && _data != null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try loading from cache first
      await _loadFromCache(role);

      // Fetch fresh data from backend
      final response = await _apiClient.get('/dashboard/$role');
      _data = response.data as Map<String, dynamic>?;
      _lastFetchTime = DateTime.now();
      _error = null;

      // Cache the data
      await _saveToCache(role, _data);
      
    } catch (e) {
      _error = e.toString();
      
      // If we have cached data, continue using it
      if (_data == null) {
        await _loadFromCache(role);
      }
      
      debugPrint('Failed to fetch dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data (force fetch)
  Future<void> refreshDashboard(String role) async {
    _lastFetchTime = null; // Invalidate cache
    await fetchDashboardData(role);
  }

  /// Load cached dashboard data
  Future<void> _loadFromCache(String role) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final cached = box.get('dashboard_$role');
      await box.close();

      if (cached != null) {
        final cacheData = jsonDecode(cached as String) as Map<String, dynamic>;
        _data = cacheData['data'] as Map<String, dynamic>?;
        final timestamp = cacheData['timestamp'] as String?;
        if (timestamp != null) {
          _lastFetchTime = DateTime.parse(timestamp);
        }
      }
    } catch (e) {
      debugPrint('Failed to load cached dashboard: $e');
    }
  }

  /// Save dashboard data to cache
  Future<void> _saveToCache(String role, Map<String, dynamic>? data) async {
    if (data == null) return;

    try {
      final box = await Hive.openBox(_cacheBoxName);
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await box.put('dashboard_$role', jsonEncode(cacheData));
      await box.close();
    } catch (e) {
      debugPrint('Failed to cache dashboard: $e');
    }
  }

  /// Clear dashboard cache
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      await box.clear();
      await box.close();
      _data = null;
      _lastFetchTime = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear dashboard cache: $e');
    }
  }
}
