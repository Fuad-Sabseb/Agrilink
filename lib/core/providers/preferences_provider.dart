import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PreferencesProvider manages app-wide user preferences
/// 
/// Handles notification preferences, app settings, and user customizations
/// All preferences are persisted to SharedPreferences
class PreferencesProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // Notification preference keys
  static const String _priceAlertsKey = 'pref_price_alerts';
  static const String _orderUpdatesKey = 'pref_order_updates';
  static const String _marketUpdatesKey = 'pref_market_updates';
  static const String _systemNotificationsKey = 'pref_system_notifications';
  static const String _inspectionRemindersKey = 'pref_inspection_reminders';

  // Notification preferences state
  bool _priceAlerts = true;
  bool _orderUpdates = true;
  bool _marketUpdates = true;
  bool _systemNotifications = true;
  bool _inspectionReminders = true; // bureau only

  PreferencesProvider(this._prefs);

  // ============================================================================
  // GETTERS
  // ============================================================================

  bool get priceAlerts => _priceAlerts;
  bool get orderUpdates => _orderUpdates;
  bool get marketUpdates => _marketUpdates;
  bool get systemNotifications => _systemNotifications;
  bool get inspectionReminders => _inspectionReminders;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize preferences from persisted storage
  /// Loads all saved preferences or applies defaults
  Future<void> initialize() async {
    _priceAlerts = _prefs.getBool(_priceAlertsKey) ?? true;
    _orderUpdates = _prefs.getBool(_orderUpdatesKey) ?? true;
    _marketUpdates = _prefs.getBool(_marketUpdatesKey) ?? true;
    _systemNotifications = _prefs.getBool(_systemNotificationsKey) ?? true;
    _inspectionReminders = _prefs.getBool(_inspectionRemindersKey) ?? true;
    notifyListeners();
  }

  // ============================================================================
  // NOTIFICATION PREFERENCES
  // ============================================================================

  /// Set price alerts preference
  Future<void> setPriceAlerts(bool value) async {
    if (_priceAlerts == value) return;
    _priceAlerts = value;
    await _prefs.setBool(_priceAlertsKey, value);
    notifyListeners();
  }

  /// Set order updates preference
  Future<void> setOrderUpdates(bool value) async {
    if (_orderUpdates == value) return;
    _orderUpdates = value;
    await _prefs.setBool(_orderUpdatesKey, value);
    notifyListeners();
  }

  /// Set market updates preference
  Future<void> setMarketUpdates(bool value) async {
    if (_marketUpdates == value) return;
    _marketUpdates = value;
    await _prefs.setBool(_marketUpdatesKey, value);
    notifyListeners();
  }

  /// Set system notifications preference
  Future<void> setSystemNotifications(bool value) async {
    if (_systemNotifications == value) return;
    _systemNotifications = value;
    await _prefs.setBool(_systemNotificationsKey, value);
    notifyListeners();
  }

  /// Set inspection reminders preference (bureau officers only)
  Future<void> setInspectionReminders(bool value) async {
    if (_inspectionReminders == value) return;
    _inspectionReminders = value;
    await _prefs.setBool(_inspectionRemindersKey, value);
    notifyListeners();
  }

  // ============================================================================
  // SERIALIZATION
  // ============================================================================

  /// Convert preferences to JSON
  Map<String, dynamic> toJson() {
    return {
      'priceAlerts': _priceAlerts,
      'orderUpdates': _orderUpdates,
      'marketUpdates': _marketUpdates,
      'systemNotifications': _systemNotifications,
      'inspectionReminders': _inspectionReminders,
    };
  }

  /// Load preferences from JSON
  void fromJson(Map<String, dynamic> json) {
    _priceAlerts = json['priceAlerts'] as bool? ?? true;
    _orderUpdates = json['orderUpdates'] as bool? ?? true;
    _marketUpdates = json['marketUpdates'] as bool? ?? true;
    _systemNotifications = json['systemNotifications'] as bool? ?? true;
    _inspectionReminders = json['inspectionReminders'] as bool? ?? true;
    notifyListeners();
  }

  /// Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    await setPriceAlerts(true);
    await setOrderUpdates(true);
    await setMarketUpdates(true);
    await setSystemNotifications(true);
    await setInspectionReminders(true);
  }
}
