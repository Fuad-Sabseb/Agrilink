# Settings Persistence Documentation

## Overview
This document describes which settings are persisted vs. session-only in AgroLink Phase 9.

## Persisted Settings (Stored in SharedPreferences)

These settings are saved to disk and persist across app restarts:

### 1. Theme Mode
- **Key**: `themeMode`
- **Type**: `ThemeMode` (system, light, dark)
- **Default**: `ThemeMode.system`
- **Persistence Requirement**: Within 500ms of change
- **Location**: Stored in unified settings JSON

### 2. Locale (Language)
- **Key**: `localeCode`
- **Type**: `String` (en, am, om)
- **Default**: `'en'` (English)
- **Persistence Requirement**: Within 500ms of change
- **Location**: Stored in unified settings JSON

### 3. Notification Preferences
- **Keys**: 
  - `priceAlerts` (bool)
  - `orderUpdates` (bool)
  - `marketUpdates` (bool)
  - `systemNotifications` (bool)
  - `inspectionReminders` (bool)
- **Default**: All `true`
- **Persistence Requirement**: Within 500ms of change
- **Location**: Nested in unified settings JSON

### 4. Selected Woreda (Bureau Officers Only)
- **Key**: `selectedWoredaId`
- **Type**: `String?`
- **Default**: `null`
- **Persistence Requirement**: Within 500ms of change
- **Purpose**: Remember last selected woreda for bureau officers with multiple woredas
- **Location**: Stored in unified settings JSON

## Session-Only Settings (Not Persisted)

These settings are reset when the app restarts:

### 1. Transaction Filters
- **Properties**:
  - `dateRange` (DateTimeRange?)
  - `statuses` (List<String>)
  - `commodities` (List<String>)
  - `types` (List<String>)
  - `minAmount` (double?)
  - `maxAmount` (double?)
- **Default**: `null` (no filters)
- **Why Not Persisted**: Per requirement 16.4, filters should not persist across app restarts
- **Location**: Stored in memory only via `UnifiedSettingsProvider`

## Storage Structure

### SharedPreferences Keys
- **Main Settings**: `app_settings_v1`
- **Version**: `settings_version`

### JSON Structure
```json
{
  "themeMode": "ThemeMode.system",
  "localeCode": "en",
  "notificationPreferences": {
    "priceAlerts": true,
    "orderUpdates": true,
    "marketUpdates": true,
    "systemNotifications": true,
    "inspectionReminders": true
  },
  "selectedWoredaId": "woreda_123"
}
```

## Version Migration

Current version: 1

### Migration Strategy
- Settings include a version number
- When loading settings, version is checked
- If version mismatch, migration logic runs
- Preserves user preferences across app updates
- Default values used if migration fails

### Future Versions
When adding new settings:
1. Increment `_currentVersion` in `SettingsPersistenceService`
2. Add migration logic in `_migrateSettings()`
3. Ensure backward compatibility with old JSON structure
4. Test with old settings data

## Performance Requirements

### Write Performance
- **Requirement**: Settings must persist within 500ms of change
- **Implementation**: `persistSettings()` method tracks duration
- **Warning**: Logs if persistence exceeds 500ms
- **Error Handling**: Non-blocking - app continues if persistence fails

### Load Performance
- **Requirement**: Settings must load before first screen displays
- **Implementation**: `initialize()` called in `main()` before `runApp()`
- **Fallback**: Uses defaults if load fails

## Error Handling

### Write Failures
- Logged to debug console
- App continues normally
- User sees no error message
- Changes remain in memory

### Read Failures
- Logged to debug console
- Defaults applied automatically
- App starts normally

## Usage Example

```dart
// In main.dart
final settingsProvider = UnifiedSettingsProvider();
await settingsProvider.initialize(); // Load before first screen

// Update theme
await settingsProvider.setThemeMode(ThemeMode.dark);

// Update notification preference
final prefs = settingsProvider.notificationPreferences.copyWith(
  priceAlerts: false,
);
await settingsProvider.updateNotificationPreferences(prefs);

// Set transaction filters (session-only)
settingsProvider.setTransactionFilters(
  TransactionFilters(
    statuses: ['Pending', 'Confirmed'],
  ),
);
```

## Testing Considerations

### Unit Tests
- Test JSON serialization/deserialization
- Test default value application
- Test migration logic
- Test 500ms write requirement
- Test load before first screen

### Integration Tests
- Test settings persist across app restart
- Test transaction filters DON'T persist
- Test migration from v0 to v1
- Test error recovery with corrupted data

## Related Files

- `lib/core/services/settings_persistence_service.dart` - Core persistence logic
- `lib/core/providers/unified_settings_provider.dart` - State management
- `lib/core/providers/theme_provider.dart` - Theme-specific logic (deprecated, use unified)
- `lib/core/providers/locale_provider.dart` - Locale-specific logic (deprecated, use unified)
- `lib/core/providers/preferences_provider.dart` - Notification preferences (deprecated, use unified)
