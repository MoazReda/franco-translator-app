/// عنصر واحد في سجل الترجمات.
/// بيمثّل ترجمة واحدة: النص الأصلي + الترجمة + الاتجاه + الوقت.
class HistoryEntry {
  final String source; // النص اللي المستخدم كتبه
  final String result; // الترجمة الناتجة
  final bool isFrancoToArabic; // الاتجاه: true = franco->عربي
  final DateTime time; // وقت الترجمة

  HistoryEntry({
    required this.source,
    required this.result,
    required this.isFrancoToArabic,
    required this.time,
  });

  /// بيحوّل العنصر لـ Map (خطوة قبل تحويله لنص JSON للتخزين).
  Map<String, dynamic> toJson() => {
        'source': source,
        'result': result,
        'isFrancoToArabic': isFrancoToArabic,
        'time': time.toIso8601String(), // الوقت كنص قياسي
      };

  /// بيبني عنصر من Map (اللي جاي من JSON المخزّن).
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        source: json['source'] as String,
        result: json['result'] as String,
        isFrancoToArabic: json['isFrancoToArabic'] as bool,
        time: DateTime.parse(json['time'] as String),
      );
}