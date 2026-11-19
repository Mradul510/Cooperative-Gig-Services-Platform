import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale_code';

  Locale _locale = const Locale('en');

  ThemeMode get themeMode => ThemeMode.light;
  bool get isDarkMode => false;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(langCode);

    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    if (_locale.languageCode == langCode) return;
    _locale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
  }
}

