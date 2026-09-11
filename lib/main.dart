import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Franco Translator',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const TranslateScreen(),
    );
  }
}

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const _channel = MethodChannel('franco_translator/process_text');

  final _controller = TextEditingController();
  Translator? _f2a; // franco -> arabic (أمامي)
  Translator? _a2f; // arabic -> franco (عكسي)
  bool _isFrancoToArabic = true; // الاتجاه الحالي

  String _output = '';
  bool _loading = true;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// نحمّل الاتجاهين مرة واحدة عند البداية
  Future<void> _init() async {
    // الأمامي: franco -> arabic
    final f2a = await Translator.load(
      modelAsset: 'assets/franco_ar.onnx',
      srcVocabAsset: 'assets/franco_vocab.json',
      tgtVocabAsset: 'assets/arabic_vocab.json',
    );
    // العكسي: arabic -> franco (لاحظ normalizeAlef للعربي كمدخل)
    final a2f = await Translator.load(
      modelAsset: 'assets/ar_franco.onnx',
      srcVocabAsset: 'assets/rev_source_arabic_vocab.json',
      tgtVocabAsset: 'assets/rev_target_franco_vocab.json',
      normalizeAlef: true,
    );

    setState(() {
      _f2a = f2a;
      _a2f = a2f;
      _loading = false;
    });

    await _checkForSharedText();
  }

  /// المترجم الحالي حسب الاتجاه المختار
  Translator? get _current => _isFrancoToArabic ? _f2a : _a2f;

  /// نقلب الاتجاه ونمسح النتيجة القديمة
  void _toggleDirection() {
    setState(() {
      _isFrancoToArabic = !_isFrancoToArabic;
      _output = '';
    });
  }

  Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _current == null) return;

    setState(() {
      _translating = true;
      _output = '';
    });
    try {
      final result = await _current!.translate(text);
      setState(() => _output = result);
    } catch (e) {
      setState(() => _output = 'خطأ: $e');
    } finally {
      setState(() => _translating = false);
    }
  }

  /// نص جاي من تطبيق تاني (Process Text): نكتشف اتجاهه ونترجمه
  Future<void> _checkForSharedText() async {
    try {
      final sharedText = await _channel.invokeMethod<String>('getSharedText');
      if (sharedText != null && sharedText.trim().isNotEmpty) {
        // لو فيه حروف عربي → عربي (عكسي)، غير كده → franco (أمامي)
        final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(sharedText);
        setState(() => _isFrancoToArabic = !hasArabic);
        _controller.text = sharedText;
        await _translate();
      }
    } catch (e) {
      // لو مفيش نص مبعوت، نتجاهل بهدوء
    }
  }

  @override
  Widget build(BuildContext context) {
    // عناوين حسب الاتجاه
    final fromLabel = _isFrancoToArabic ? 'Franco' : 'عربي';
    final toLabel = _isFrancoToArabic ? 'عربي' : 'Franco';
    final hint = _isFrancoToArabic ? 'اكتب franco' : 'اكتب عربي';

    return Scaffold(
      appBar: AppBar(title: Text('$fromLabel ➜ $toLabel')),
      body: _loading
          ? const Center(child: Text('جاري تحميل الموديلات...'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // زرار تبديل الاتجاه
                  Center(
                    child: TextButton.icon(
                      onPressed: _toggleDirection,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text('$fromLabel ➜ $toLabel'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: hint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _translating ? null : _translate,
                    child: Text(_translating ? 'بيترجم...' : 'ترجم'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _output,
                    style: const TextStyle(fontSize: 24),
                    textDirection:
                        _isFrancoToArabic ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ],
              ),
            ),
    );
  }
}