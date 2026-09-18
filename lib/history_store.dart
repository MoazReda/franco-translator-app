import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_entry.dart';

/// بيحفظ ويقرا سجل الترجمات من قرص الموبايل.
/// بيخزّن القايمة كلها كنص JSON واحد.
class HistoryStore {
  static const _key = 'translation_history';
  static const _maxEntries = 100; // نحتفظ بآخر 100 بس (منخلّيش القايمة تكبر بلا حدود)

  /// بيقرا كل السجل (الأحدث الأول).
  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    // نص JSON -> قايمة Maps -> قايمة عناصر
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// بيضيف ترجمة جديدة على رأس السجل ويحفظ.
  static Future<void> add(HistoryEntry entry) async {
    final current = await load();
    current.insert(0, entry); // الأحدث في الأول

    // نقص القايمة لو عدّت الحد الأقصى
    final trimmed =
        current.length > _maxEntries ? current.sublist(0, _maxEntries) : current;

    await _save(trimmed);
  }

  /// بيمسح السجل كله.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// بيحفظ القايمة كنص JSON.
  static Future<void> _save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    // قايمة عناصر -> قايمة Maps -> نص JSON
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}