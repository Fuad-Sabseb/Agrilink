import 'package:flutter/material.dart';
import '../services/settings_persistence_service.dart';

class UnifiedSettingsProvider extends ChangeNotifier {
  final SettingsPersistenceService _persistenceService = SettingsPersistenceService();
  
  AppSettings _settings = AppSettings.defaults();
  bool _isInitialized = false;

  AppSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  // Individual getters for convenience
  ThemeMode get themeMode => _settings.themeMode;
  String get localeCode => _settings.localeCode;
  NotificationPreferences get notificationPreferences => _settings.notificationPreferences;
  String? get selectedWoredaId => _settings.selectedWoredaId;
  TransactionFilters? get transactionFilters => _settings.transactionFilters;

  // Initialize settings - call before first screen
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _settings = await _persistenceService.loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize settings: $e');
      _settings = AppSettings.defaults();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _persistSettings();
  }

  // Update locale
  Future<void> setLocale(String localeCode) async {
    _settings = _settings.copyWith(localeCode: localeCode);
    notifyListeners();
    await _persistSettings();
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(NotificationPreferences prefs) async {
    _settings = _settings.copyWith(notificationPreferences: prefs);
    notifyListeners();
    await _persistSettings();
  }

  // Update selected woreda (bureau officers only)
  Future<void> setSelectedWoreda(String? woredaId) async {
    _settings = _settings.copyWith(selectedWoredaId: woredaId);
    notifyListeners();
    await _persistSettings();
  }

  // Update transaction filters (session-only, not persisted)
  void setTransactionFilters(TransactionFilters? filters) {
    _settings = _settings.copyWith(transactionFilters: filters);
    notifyListeners();
    // Note: Not persisted as per requirements
  }

  // Persist settings with 500ms requirement
  Future<void> _persistSettings() async {
    try {
      await _persistenceService.persistSettings(_settings);
    } catch (e) {
      debugPrint('Failed to persist settings: $e');
      // Don't throw - allow app to continue even if persistence fails
    }
  }

  // Clear all settings
  Future<void> clearSettings() async {
    await _persistenceService.clearSettings();
    _settings = AppSettings.defaults();
    notifyListeners();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _settings = AppSettings.defaults();
    notifyListeners();
    await _persistSettings();
  }
}
