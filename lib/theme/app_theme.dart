import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// بيبني ThemeData لـ Franco من الألوان والأبعاد بتاعتنا.
/// عندنا واحد للـ light وواحد للـ dark.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final c = AppColors.of(brightness);

    return ThemeData(
      brightness: brightness,
      fontFamily: 'Cairo', // خط Cairo لكل التطبيق
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandCyan,
        brightness: brightness,
        surface: c.surface,
      ),

      // الـ AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // الأزرار الأساسية
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandCyan,
          foregroundColor: AppColors.brandNavy, // نص غامق على الأزرق
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // خانات الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.brandCyan, width: 2),
        ),
      ),
    );
  }
}