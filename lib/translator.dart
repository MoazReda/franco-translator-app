import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'vocab.dart';

/// المترجم: بياخد نص ويرجّع ترجمته حسب الاتجاه.
/// الكلاس عام — مش متزوّج من اتجاه معيّن. بنقوله وقت التحميل
/// أنهي موديل وأنهي قواميس يستخدم، فبيخدم الأمامي والعكسي بنفس الكود.
class Translator {
  final OrtSession _session;
  final Vocab _srcVocab; // قاموس المدخل (للـ encode)
  final Vocab _tgtVocab; // قاموس المخرج (للـ decode)
  final bool _normalizeAlef; // نرمّل الألف قبل الترجمة؟ (للعربي كمدخل)

  Translator._(this._session, this._srcVocab, this._tgtVocab, this._normalizeAlef);

  /// بيجهّز مترجم لاتجاه معيّن، من ملفاته.
  /// [modelAsset]     مسار ملف الـ onnx
  /// [srcVocabAsset]  قاموس المدخل
  /// [tgtVocabAsset]  قاموس المخرج
  /// [normalizeAlef]  لو true، بنحوّل أ/إ/آ → ا قبل الترجمة (للعربي)
  static Future<Translator> load({
    required String modelAsset,
    required String srcVocabAsset,
    required String tgtVocabAsset,
    bool normalizeAlef = false,
  }) async {
    final srcVocab = await Vocab.fromAsset(srcVocabAsset);
    final tgtVocab = await Vocab.fromAsset(tgtVocabAsset);

    final onnx = OnnxRuntime();
    final session = await onnx.createSessionFromAsset(modelAsset);

    return Translator._(session, srcVocab, tgtVocab, normalizeAlef);
  }

      /// بتترجم جملة كاملة (بتبعتها للموديل مباشرة).
  Future<String> translate(String text) async {
    return _translateChunk(text);
  }

  /// بتترجم مقطع franco واحد بالموديل (الجزء اللي كان في translate قبل كده).
  Future<String> _translateChunk(String text) async {
    var input = text.toLowerCase();
    if (_normalizeAlef) input = _normalizeAlefChars(input);

    final ids = _srcVocab.encode(input);

    final inputTensor = await OrtValue.fromList(
      Int64List.fromList(ids),
      [1, ids.length],
    );

    final outputs = await _session.run({'src': inputTensor});

    final outTensor = outputs['tokens']!;
    final flat = await outTensor.asFlattenedList();
    final outIds = flat.map((e) => (e as num).toInt()).toList();

    return _tgtVocab.decode(outIds);
  }

  /// بتحوّل أشكال الألف (أ/إ/آ/ٱ) لألف عادية — الموديل العربي اتدرّب على نص منرمل.
  String _normalizeAlefChars(String s) {
    return s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  }
}