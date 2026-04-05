import 'package:flutter/material.dart';
import '../data/local/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  ThemeMode _themeMode;

  ThemeProvider(this._prefs)
      : _themeMode = _modeFromString(_prefs.getThemeMode());

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  static ThemeMode _modeFromString(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'system': return ThemeMode.system;
      default: return ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await _prefs.setThemeMode(modeStr);
    notifyListeners();
  }
}
