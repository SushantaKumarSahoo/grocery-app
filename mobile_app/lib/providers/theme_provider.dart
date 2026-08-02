import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'theme_mode_dark';

  ThemeMode mode;

  AppThemeProvider({ThemeMode initialMode = ThemeMode.light}) : mode = initialMode;

  Future<void> toggle() => setMode(mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  Future<void> setMode(ThemeMode m) async {
    mode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, m == ThemeMode.dark);
  }

  static Future<ThemeMode> loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefsKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
