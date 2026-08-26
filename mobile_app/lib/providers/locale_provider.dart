import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, odia }

class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_language';

  AppLanguage language;

  LocaleProvider({AppLanguage initialLanguage = AppLanguage.english})
      : language = initialLanguage;

  Future<void> setLanguage(AppLanguage lang) async {
    if (lang == language) return;
    language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang == AppLanguage.odia ? 'or' : 'en');
  }

  static Future<AppLanguage> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'en';
    return code == 'or' ? AppLanguage.odia : AppLanguage.english;
  }
}
