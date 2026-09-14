import 'package:flutter/material.dart';

/// ألوان Franco — مصدر واحد للحقيقة.
/// أي شاشة بتستخدم الأسماء دي، مش الأكواد المباشرة.
class AppColors {
  AppColors._(); // مبنعملش instance منه، بس ثوابت

  // ===== ألوان الهوية (ثابتة في الوضعين) =====
  static const Color brandCyan = Color(0xFF00E5FF); // اللون الأساسي
  static const Color brandNavy = Color(0xFF101820); // الغامق

  // ===== Light Mode =====
  static const _lightBg = Color(0xFFF7F9FB); // الخلفية
  static const _lightSurface = Color(0xFFFFFFFF); // الكروت
  static const _lightTextPrimary = Color(0xFF101820); // نص أساسي
  static const _lightTextSecondary = Color(0xFF5B6670); // نص ثانوي
  static const _lightBorder = Color(0xFFE3E8EC); // حدود

  // ===== Dark Mode =====
  static const _darkBg = Color(0xFF0B0F14); // خلفية غامقة
  static const _darkSurface = Color(0xFF161D24); // كروت غامقة
  static const _darkTextPrimary = Color(0xFFF2F5F7); // نص فاتح
  static const _darkTextSecondary = Color(0xFF9AA5AF); // نص ثانوي
  static const _darkBorder = Color(0xFF263039); // حدود

  // ===== حالات (نفس الفكرة) =====
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);

  // ===== دالة بترجّع مجموعة الألوان حسب الوضع =====
  static AppColorScheme of(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppColorScheme(
      background: isDark ? _darkBg : _lightBg,
      surface: isDark ? _darkSurface : _lightSurface,
      textPrimary: isDark ? _darkTextPrimary : _lightTextPrimary,
      textSecondary: isDark ? _darkTextSecondary : _lightTextSecondary,
      border: isDark ? _darkBorder : _lightBorder,
      brand: brandCyan,
    );
  }
}

/// مجموعة الألوان المختارة حسب الوضع (light/dark)
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color brand;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.brand,
  });
}