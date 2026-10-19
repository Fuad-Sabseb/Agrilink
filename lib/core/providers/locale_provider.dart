import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LocaleProvider manages app locale state with persistence
///
/// Supports three locales:
/// - English (en)
/// - Amharic (am)
/// - Afaan Oromoo (om)
///
/// Locale preference is persisted to SharedPreferences with key 'locale'
class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'locale';

  Locale _locale = const Locale('en');
  final SharedPreferences _prefs;

  LocaleProvider(this._prefs);

  /// Current locale
  Locale get locale => _locale;

  /// Current language code (en, am, or om)
  String get languageCode => _locale.languageCode;

  /// Supported locales for the application
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('am'), // Amharic
    Locale('om'), // Afaan Oromoo
  ];

  /// Check if current locale is English
  bool get isEnglish => _locale.languageCode == 'en';

  /// Check if current locale is Amharic
  bool get isAmharic => _locale.languageCode == 'am';

  /// Check if current locale is Afaan Oromoo
  bool get isOromoo => _locale.languageCode == 'om';

  /// Initialize locale from persisted preference
  ///
  /// Loads the saved locale preference from SharedPreferences.
  /// If no preference exists, defaults to English (en).
  Future<void> initialize() async {
    final savedLocale = _prefs.getString(_localeKey);

    if (savedLocale != null && _isValidLocale(savedLocale)) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  /// Set locale and persist to storage
  ///
  /// Updates the current locale and saves the preference to SharedPreferences.
  /// The locale is applied immediately without requiring app restart.
  /// All user-facing text will update within 100 milliseconds.
  Future<void> setLocale(Locale locale) async {
    // Only update if the locale is different and supported
    if (_locale.languageCode == locale.languageCode) return;

    if (!_isValidLocale(locale.languageCode)) {
      throw ArgumentError(
        'Unsupported locale: ${locale.languageCode}. '
        'Supported locales are: en, am, om',
      );
    }

    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  /// Validate if a locale code is supported
  bool _isValidLocale(String localeCode) {
    return supportedLocales.any((locale) => locale.languageCode == localeCode);
  }
}
