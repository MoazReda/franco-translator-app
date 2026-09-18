import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'history_entry.dart';
import 'history_store.dart';

/// شاشة سجل الترجمات — بتعرض الترجمات اللي اتعملت قبل كده، وتقدر تنسخها أو تمسحها.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await HistoryStore.load();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    // بنسأل المستخدم الأول قبل ما نمسح السجل كله
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('كل الترجمات المحفوظة هتتمسح. متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لأ، إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'امسح',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryStore.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'السجل',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: 'امسح الكل',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: c.textSecondary,
              ),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.brandCyan,
              ),
            )
          : _entries.isEmpty
              // لو مفيش ترجمات محفوظة
              ? Center(
                  child: Text(
                    'لسه مفيش ترجمات',
                    style: TextStyle(
                      fontSize: AppFontSize.body,
                      color: c.textSecondary,
                    ),
                  ),
                )
              // قائمة الترجمات اللي اتعملت قبل كده
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _entries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) =>
                      _HistoryCard(entry: _entries[i]),
                ),
    );
  }
}

/// كارت فيه ترجمة واحدة من السجل.
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final outIsArabic = entry.isFrancoToArabic;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الكلام الأصلي بلون هادي شوية
          Text(
            entry.source,
            style: TextStyle(
              fontSize: AppFontSize.body,
              color: c.textSecondary,
            ),
            textDirection:
                entry.isFrancoToArabic ? TextDirection.ltr : TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: c.border, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // الترجمة ومعاها زرار النسخ
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.result,
                  style: TextStyle(
                    fontSize: AppFontSize.input,
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection:
                      outIsArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: entry.result),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('اتنسخ'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.brandCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
