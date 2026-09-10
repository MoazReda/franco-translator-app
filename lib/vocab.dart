import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// كلاس بيمثّل الـ vocabulary (قايمة الحروف) لتحويل النص لأرقام والعكس.
/// ده مرآة لكلاس Vocab بتاع Python.
class Vocab {
  final List<String> itos; // index -> string  (رقم -> حرف)
  final Map<String, int> stoi; // string -> index  (حرف -> رقم)

  Vocab(this.itos) : stoi = {for (var i = 0; i < itos.length; i++) itos[i]: i};

  /// بيحمّل الـ vocab من ملف JSON في الـ assets
  static Future<Vocab> fromAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final List<dynamic> list = jsonDecode(raw);
    return Vocab(list.cast<String>());
  }

  // الـ IDs الخاصة (بنقراها بالاسم بدل ما نكتب أرقام ثابتة)
  int get padId => stoi['<pad>']!;
  int get sosId => stoi['<sos>']!;
  int get eosId => stoi['<eos>']!;
  int get unkId => stoi['<unk>']!;

  int get length => itos.length;

  /// بتحوّل نص لقائمة أرقام، ملفوفة بـ <sos> و <eos>.
  /// أي حرف مش موجود ياخد رقم <unk>.
  List<int> encode(String text) {
    final ids = <int>[];
    ids.add(sosId);
    for (final ch in text.split('')) {
      ids.add(stoi[ch] ?? unkId);
    }
    ids.add(eosId);
    return ids;
  }

  /// بتحوّل قائمة أرقام لنص، مع تجاهل الرموز الخاصة.
  String decode(List<int> ids) {
    const specials = {'<pad>', '<sos>', '<eos>', '<unk>'};
    final buffer = StringBuffer();
    for (final id in ids) {
      if (id < 0 || id >= itos.length) continue;
      final tok = itos[id];
      if (specials.contains(tok)) continue;
      buffer.write(tok);
    }
    return buffer.toString();
  }
}