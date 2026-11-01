import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(const Locale('ar'));

  static const String _themeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      themeModeNotifier.value = ThemeMode.light;
    } else {
      themeModeNotifier.value = ThemeMode.dark; // Default to sleek dark mode
    }

    // Load locale
    final localeStr = prefs.getString(_localeKey);
    if (localeStr == 'en') {
      localeNotifier.value = const Locale('en');
    } else {
      localeNotifier.value = const Locale('ar');
    }
  }

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;
  static bool get isArabic => localeNotifier.value.languageCode == 'ar';

  static Future<void> toggleTheme() async {
    final newMode = themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeModeNotifier.value = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  static Future<void> toggleLanguage() async {
    final newLocale = localeNotifier.value.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    localeNotifier.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
  }

  static Future<void> setLanguage(String langCode) async {
    final newLocale = Locale(langCode);
    localeNotifier.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
  }
}
