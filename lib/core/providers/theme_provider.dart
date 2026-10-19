import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider manages app theme state with persistence
/// 
/// Supports three modes:
/// - System: Follows device system theme
/// - Light: Always uses light theme
/// - Dark: Always uses dark theme
/// 
/// Theme preference is persisted to SharedPreferences with key 'theme_mode'
class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs);

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Check if light mode is active
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Check if system mode is active
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Initialize theme from persisted preference
  /// 
  /// Loads the saved theme preference from SharedPreferences.
  /// If no preference exists, defaults to ThemeMode.system.
  Future<void> initialize() async {
    final savedTheme = _prefs.getString(_themeModeKey);
    
    if (savedTheme != null) {
      _themeMode = _stringToThemeMode(savedTheme);
      notifyListeners();
    }
  }

  /// Set theme mode and persist to storage
  /// 
  /// Updates the current theme and saves the preference to SharedPreferences.
  /// The theme is applied immediately without requiring app restart.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(_themeModeKey, _themeModeToString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark themes
  /// 
  /// If current mode is system, switches to light.
  /// If light, switches to dark.
  /// If dark, switches to light.
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    
    switch (_themeMode) {
      case ThemeMode.system:
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
    }
    
    await setThemeMode(newMode);
  }

  /// Convert ThemeMode to string for persistence
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// Convert string to ThemeMode from persistence
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
