/// أبعاد Franco — سلّم ثابت للمسافات والزوايا وأحجام الخطوط.
/// كل التطبيق بيستخدم القيم دي عشان يفضل متناسق.
class AppSpacing {
  AppSpacing._();

  // ===== المسافات (padding / margins / gaps) =====
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ===== زوايا الحواف (border radius) =====
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999; // للأزرار الدائرية
}

/// أحجام الخطوط — سلّم واضح من الأصغر للأكبر.
class AppFontSize {
  AppFontSize._();

  static const double label = 13; // ليبل صغير
  static const double body = 16; // نص عادي
  static const double input = 20; // نص الإدخال
  static const double output = 26; // نص الترجمة (أكبر عشان يبان)
  static const double heading = 22; // عناوين
  static const double display = 34; // عنوان كبير (onboarding مثلاً)
}