import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsPersistenceService {
  static const String _settingsKey = 'app_settings_v1';
  static const String _versionKey = 'settings_version';
  static const int _currentVersion = 1;

  // Persist all settings to SharedPreferences
  Future<void> persistSettings(AppSettings settings) async {
    final startTime = DateTime.now();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = settings.toJson();
      await prefs.setString(_settingsKey, jsonEncode(json));
      await prefs.setInt(_versionKey, _currentVersion);
      
      final duration = DateTime.now().difference(startTime);
      if (duration.inMilliseconds > 500) {
        debugPrint('Warning: Settings persistence took ${duration.inMilliseconds}ms');
      }
    } catch (e) {
      debugPrint('Failed to persist settings: $e');
      rethrow;
    }
  }

  // Load settings from SharedPreferences
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(_versionKey) ?? 0;
      
      // Handle migration if needed
      if (version < _currentVersion) {
        await _migrateSettings(prefs, version, _currentVersion);
      }
      
      final json = prefs.getString(_settingsKey);
      if (json != null) {
        return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Failed to load settings, using defaults: $e');
    }
    
    return AppSettings.defaults();
  }

  // Migrate settings from old version to new version
  Future<void> _migrateSettings(
    SharedPreferences prefs,
    int fromVersion,
    int toVersion,
  ) async {
    debugPrint('Migrating settings from v$fromVersion to v$toVersion');
    
    // Migration logic for future versions
    if (fromVersion == 0 && toVersion == 1) {
      // First version, no migration needed
    }
    
    await prefs.setInt(_versionKey, toVersion);
  }

  // Clear all settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
    await prefs.remove(_versionKey);
  }
}

class AppSettings {
  // Persisted settings
  final ThemeMode themeMode;
  final String localeCode;
  final NotificationPreferences notificationPreferences;
  final String? selectedWoredaId; // For bureau officers

  // Session-only settings (not persisted)
  final TransactionFilters? transactionFilters;

  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.notificationPreferences,
    this.selectedWoredaId,
    this.transactionFilters,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      themeMode: ThemeMode.system,
      localeCode: 'en',
      notificationPreferences: NotificationPreferences.defaults(),
      selectedWoredaId: null,
      transactionFilters: null,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      localeCode: json['localeCode'] as String? ?? 'en',
      notificationPreferences: NotificationPreferences.fromJson(
        json['notificationPreferences'] as Map<String, dynamic>? ?? {},
      ),
      selectedWoredaId: json['selectedWoredaId'] as String?,
      // transactionFilters are session-only, not loaded
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.toString(),
      'localeCode': localeCode,
      'notificationPreferences': notificationPreferences.toJson(),
      'selectedWoredaId': selectedWoredaId,
      // transactionFilters are session-only, not persisted
    };
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    NotificationPreferences? notificationPreferences,
    String? selectedWoredaId,
    TransactionFilters? transactionFilters,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      selectedWoredaId: selectedWoredaId ?? this.selectedWoredaId,
      transactionFilters: transactionFilters ?? this.transactionFilters,
    );
  }
}

class NotificationPreferences {
  final bool priceAlerts;
  final bool orderUpdates;
  final bool marketUpdates;
  final bool systemNotifications;
  final bool inspectionReminders;

  const NotificationPreferences({
    required this.priceAlerts,
    required this.orderUpdates,
    required this.marketUpdates,
    required this.systemNotifications,
    required this.inspectionReminders,
  });

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      priceAlerts: true,
      orderUpdates: true,
      marketUpdates: true,
      systemNotifications: true,
      inspectionReminders: true,
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      priceAlerts: json['priceAlerts'] as bool? ?? true,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      marketUpdates: json['marketUpdates'] as bool? ?? true,
      systemNotifications: json['systemNotifications'] as bool? ?? true,
      inspectionReminders: json['inspectionReminders'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceAlerts': priceAlerts,
      'orderUpdates': orderUpdates,
      'marketUpdates': marketUpdates,
      'systemNotifications': systemNotifications,
      'inspectionReminders': inspectionReminders,
    };
  }

  NotificationPreferences copyWith({
    bool? priceAlerts,
    bool? orderUpdates,
    bool? marketUpdates,
    bool? systemNotifications,
    bool? inspectionReminders,
  }) {
    return NotificationPreferences(
      priceAlerts: priceAlerts ?? this.priceAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      marketUpdates: marketUpdates ?? this.marketUpdates,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      inspectionReminders: inspectionReminders ?? this.inspectionReminders,
    );
  }
}

class TransactionFilters {
  final DateTimeRange? dateRange;
  final List<String> statuses;
  final List<String> commodities;
  final List<String> types;
  final double? minAmount;
  final double? maxAmount;

  const TransactionFilters({
    this.dateRange,
    this.statuses = const [],
    this.commodities = const [],
    this.types = const [],
    this.minAmount,
    this.maxAmount,
  });

  bool get hasActiveFilters {
    return dateRange != null ||
        statuses.isNotEmpty ||
        commodities.isNotEmpty ||
        types.isNotEmpty ||
        minAmount != null ||
        maxAmount != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (dateRange != null) count++;
    if (statuses.isNotEmpty) count++;
    if (commodities.isNotEmpty) count++;
    if (types.isNotEmpty) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }
}
