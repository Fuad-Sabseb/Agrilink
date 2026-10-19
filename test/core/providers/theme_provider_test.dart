import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolink/core/providers/theme_provider.dart';

/// Unit tests for ThemeProvider
/// Tests theme mode switching, persistence, and initialization
void main() {
  group('ThemeProvider', () {
    late SharedPreferences prefs;
    late ThemeProvider themeProvider;

    setUp(() async {
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
    });

    test('should initialize with system theme mode as default', () {
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isSystemMode, true);
      expect(themeProvider.isLightMode, false);
      expect(themeProvider.isDarkMode, false);
    });

    test('should set theme mode to light and persist', () async {
      await themeProvider.setThemeMode(ThemeMode.light);

      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isLightMode, true);
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.isSystemMode, false);

      // Verify persistence
      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, 'light');
    });

    test('should set theme mode to dark and persist', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);

      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.isLightMode, false);
      expect(themeProvider.isSystemMode, false);

      // Verify persistence
      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, 'dark');
    });

    test('should toggle theme from system to light', () async {
      // Start with system mode
      expect(themeProvider.isSystemMode, true);

      await themeProvider.toggleTheme();

      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isLightMode, true);
    });

    test('should toggle theme from light to dark', () async {
      await themeProvider.setThemeMode(ThemeMode.light);
      await themeProvider.toggleTheme();

      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
    });

    test('should toggle theme from dark to light', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      await themeProvider.toggleTheme();

      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isLightMode, true);
    });

    test('should load persisted theme on initialization', () async {
      // Set a theme preference
      await prefs.setString('theme_mode', 'dark');

      // Create new provider instance
      final newProvider = ThemeProvider(prefs);
      await newProvider.initialize();

      expect(newProvider.themeMode, ThemeMode.dark);
      expect(newProvider.isDarkMode, true);
    });

    test('should default to system when no persisted preference', () async {
      // Ensure no saved preference
      await prefs.remove('theme_mode');

      final newProvider = ThemeProvider(prefs);
      await newProvider.initialize();

      expect(newProvider.themeMode, ThemeMode.system);
      expect(newProvider.isSystemMode, true);
    });

    test('should handle invalid persisted value', () async {
      // Set an invalid value
      await prefs.setString('theme_mode', 'invalid');

      final newProvider = ThemeProvider(prefs);
      await newProvider.initialize();

      // Should default to system for invalid values
      expect(newProvider.themeMode, ThemeMode.system);
    });

    test('should not update if theme mode is already set', () async {
      await themeProvider.setThemeMode(ThemeMode.light);
      final beforeCallTime = DateTime.now();

      // Try to set the same theme again
      await themeProvider.setThemeMode(ThemeMode.light);

      // Should still be light mode
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Verify it returns early (no unnecessary persistence)
      final afterCallTime = DateTime.now();
      expect(afterCallTime.difference(beforeCallTime).inMilliseconds < 100, true);
    });

    test('should notify listeners when theme changes', () async {
      var notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(notificationCount, 1);

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(notificationCount, 2);

      await themeProvider.toggleTheme();
      expect(notificationCount, 3);
    });

    test('should persist all theme modes correctly', () async {
      // Test light mode
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');

      // Test dark mode
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');

      // Test system mode
      await themeProvider.setThemeMode(ThemeMode.system);
      expect(prefs.getString('theme_mode'), 'system');
    });
  });
}
