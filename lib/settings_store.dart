import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بيحفظ ويقرا إعدادات التطبيق من قرص الموبايل (SharedPreferences).
/// مصدر واحد للحقيقة لأي إعداد بيفضل محفوظ بعد قفل التطبيق.
class SettingsStore {
  static const _themeKey = 'theme_mode'; // اسم المفتاح في التخزين

  /// بيحفظ اختيار الـ theme (light / dark / system).
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // بنحفظه كنص عشان نقدر نقراه بسهولة
    await prefs.setString(_themeKey, mode.name); // "light" / "dark" / "system"
  }

  /// بيقرا الـ theme المحفوظ. لو مفيش حاجة محفوظة، بيرجّع system (الافتراضي).
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // الافتراضي (يتبع الموبايل)
    }
  }
}