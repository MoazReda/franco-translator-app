import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
  final _controller = TextEditingController();
  Translator? _translator; // الموديل (بيتحمّل مرة واحدة)
  String _output = '';
  bool _loading = true; // بيتحمّل الموديل؟
  bool _translating = false; // بيترجم دلوقتي؟
  static const _channel = MethodChannel('franco_translator/process_text');

  @override
  void initState() {
    super.initState();
    _initTranslator();
  }

  /// نحمّل الموديل مرة واحدة عند فتح الشاشة
  Future<void> _initTranslator() async {
    final t = await Translator.load();
    setState(() {
      _translator = t;
      _loading = false;
    });

    // بعد ما الموديل يجهز: نشوف التطبيق اتفتح من "ترجم" ومعاه نص؟
    await _checkForSharedText();
  }

  /// بتسأل الـ native: فيه نص مُختار مبعوت لنا؟ لو آه، تحطّه وتترجمه.
  Future<void> _checkForSharedText() async {
    try {
      final sharedText = await _channel.invokeMethod<String>('getSharedText');
      if (sharedText != null && sharedText.trim().isNotEmpty) {
        _controller.text = sharedText;
        await _translate(); // نترجمه على طول
      }
    } catch (e) {
      // لو حصل أي مشكلة في الجسر، نتجاهلها بهدوء (التطبيق يفتح عادي)
    }
  }

  /// نترجم النص اللي في الخانة
    Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _translator == null) return;

    setState(() {
      _translating = true;
      _output = '';
    });
    try {
      final result = await _translator!.translate(text);
      setState(() => _output = result);
    } catch (e) {
      setState(() => _output = 'خطأ: $e'); // أي مشكلة هتظهر هنا بدل ما تعلّق
    } finally {
      setState(() => _translating = false); // الزرار يرجع "ترجم" دايماً
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Franco ➜ عربي')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            // لسه بنحمّل الموديل
            ? const Center(child: Text('جاري تحميل الموديل...'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // خانة الكتابة
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'اكتب franco',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // زرار الترجمة
                  ElevatedButton(
                    onPressed: _translating ? null : _translate,
                    child: Text(_translating ? 'بيترجم...' : 'ترجم'),
                  ),
                  const SizedBox(height: 24),
                  // النتيجة
                  Text(
                    _output,
                    style: const TextStyle(fontSize: 24),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
      ),
    );
  }
}