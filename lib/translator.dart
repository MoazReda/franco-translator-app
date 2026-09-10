import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'vocab.dart';

/// المترجم: بياخد نص franco ويرجّع نص عربي.
/// بيلفّ الموديل (ONNX) + الـ vocabs + منطق الترجمة كله في مكان واحد.
class Translator {
  final OrtSession _session;
  final Vocab _francoVocab; // للـ encode (نص franco -> أرقام)
  final Vocab _arabicVocab; // للـ decode (أرقام -> نص عربي)

  Translator._(this._session, this._francoVocab, this._arabicVocab);

  /// بيجهّز المترجم: يحمّل الموديل والـ vocabs والإعدادات من الـ assets.
  /// بننادي ده مرة واحدة بس عند بداية التطبيق (لأنه تقيل شوية).
  static Future<Translator> load() async {
    // 1) نحمّل الـ vocabs
    final francoVocab = await Vocab.fromAsset('assets/franco_vocab.json');
    final arabicVocab = await Vocab.fromAsset('assets/arabic_vocab.json');

    // 3) نفتح جلسة ONNX من ملف الموديل في الـ assets
    final onnx = OnnxRuntime();
    final session = await onnx.createSessionFromAsset('assets/franco_ar.onnx');

    return Translator._(session, francoVocab, arabicVocab);
  }

  /// بتترجم جملة franco واحدة لعربي.
  Future<String> translate(String francoText) async {
    // 1) نص -> أرقام (نفس اللي اتأكدنا منه)
    final ids = _francoVocab.encode(francoText.toLowerCase());

    // 2) نعمل tensor بشكل [1, L] — الـ 1 معناه batch=جملة واحدة
    //    الموديل صدّرناه بـ int64، فبنستخدم Int64List
    final inputTensor = await OrtValue.fromList(
      Int64List.fromList(ids), // القيم كـ int64 (زي ما الموديل متوقّع)
      [1, ids.length], // الشكل [batch=1, length]
    );

    // 3) نشغّل الموديل: الـ input اسمه "src" (نفس اللي صدّرنا بيه)
    final outputs = await _session.run({'src': inputTensor});

    // 4) ناخد الـ output اسمه "tokens" ونحوّله لـ list أرقام
    final outTensor = outputs['tokens']!;
    final flat = await outTensor.asFlattenedList(); // كل الأرقام في list واحدة
    final outIds = flat.map((e) => (e as num).toInt()).toList();

    // 5) نـ decode الأرقام لعربي (الـ decode بيتجاهل pad/sos/eos تلقائياً)
    return _arabicVocab.decode(outIds);
  }
}