import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// بطاقة نص قابلة لإعادة الاستخدام — بنستخدمها للإدخال وللناتج.
/// فيها: ليبل صغير فوق، ومحتوى (خانة كتابة أو نص ناتج) تحت.
class TextPanel extends StatelessWidget {
  final String label; // الليبل الصغير فوق ("franco" أو "عربي")
  final Widget child; // المحتوى (TextField أو Text)
  final Widget? trailing; // زرار اختياري فوق يمين (زي زرار النسخ)

  const TextPanel({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف الليبل + الزرار الاختياري
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // المحتوى
          child,
        ],
      ),
    );
  }
}