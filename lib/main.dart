import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'widgets/text_panel.dart';
import 'translator.dart';
import 'history_entry.dart';
import 'history_store.dart';
import 'history_screen.dart';
import 'settings_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

    /// بتبدّل الـ theme من أي مكان في التطبيق.
  static void toggleTheme(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.toggleTheme();
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  /// نقرا الـ theme المحفوظ عند بداية التطبيق
  Future<void> _loadTheme() async {
    final saved = await SettingsStore.loadThemeMode();
    setState(() => _themeMode = saved);
  }

  /// نبدّل بين light و dark ونحفظ الاختيار
  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    SettingsStore.saveThemeMode(_themeMode); // نحفظه على القرص
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Franco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode, // بقى متغيّر بدل الثابت
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
  Translator? _f2a; // franco -> arabic
  Translator? _a2f; // arabic -> franco
  bool _isFrancoToArabic = true;

  String _output = '';
  bool _loading = true;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {})); // يحدّث الشاشة مع كل حرف
    _init();
  }

  Future<void> _init() async {
    final f2a = await Translator.load(
      modelAsset: 'assets/franco_ar.onnx',
      srcVocabAsset: 'assets/franco_vocab.json',
      tgtVocabAsset: 'assets/arabic_vocab.json',
    );
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

  Translator? get _current => _isFrancoToArabic ? _f2a : _a2f;

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
      // نحفظ الترجمة في السجل
      await HistoryStore.add(HistoryEntry(
        source: text,
        result: result,
        isFrancoToArabic: _isFrancoToArabic,
        time: DateTime.now(),
      ));
    } catch (e) {
      setState(() => _output = 'خطأ: $e');
    } finally {
      setState(() => _translating = false);
    }
  }

  Future<void> _checkForSharedText() async {
    try {
      final sharedText = await _channel.invokeMethod<String>('getSharedText');
      if (sharedText != null && sharedText.trim().isNotEmpty) {
        final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(sharedText);
        setState(() => _isFrancoToArabic = !hasArabic);
        _controller.text = sharedText;
        await _translate();
      }
    } catch (_) {}
  }

  void _copyOutput() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الترجمة'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    // الليبلات تتكلم بلغة الاتجاه الحالي:
    // franco->عربي: بالفرانكو | عربي->franco: بالعربي
    final srcLabel = _isFrancoToArabic ? 'اكتب فرانكو' : 'ektb 3arabi';
    final buttonLabel = _isFrancoToArabic ? 'ترجم' : 'targem';
    final outputLabel = _isFrancoToArabic ? 'الترجمة' : 'eltargama';
    final outIsArabic = _isFrancoToArabic; // الناتج عربي في الاتجاه الأمامي

    return Scaffold(
            appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Franco',
              style: TextStyle(
                fontSize: AppFontSize.heading,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 8, height: 8, decoration: const BoxDecoration(
              color: AppColors.brandCyan, shape: BoxShape.circle)),
          ],
        ),
                actions: [
          IconButton(
            tooltip: 'السجل',
            icon: Icon(Icons.history_rounded, color: c.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'تبديل الوضع',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: c.textPrimary,
            ),
            onPressed: () => MyApp.toggleTheme(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شريط تبديل الاتجاه (كبسولة)
                  Center(
                    child: GestureDetector(
                      onTap: _toggleDirection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_isFrancoToArabic ? 'Franco' : 'عربي',
                                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Icon(Icons.swap_horiz, size: 18, color: AppColors.brandCyan),
                            ),
                            Text(_isFrancoToArabic ? 'عربي' : 'Franco',
                                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // بطاقة الإدخال
                  TextPanel(
                    label: srcLabel,
                    trailing: _controller.text.isEmpty
                        ? null
                        : InkWell(
                            onTap: () {
                              _controller.clear();
                              setState(() => _output = '');
                            },
                            child: Icon(Icons.close_rounded,
                                size: 18,
                                color: AppColors.of(Theme.of(context).brightness)
                                    .textSecondary),
                          ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 3,
                      style: TextStyle(fontSize: AppFontSize.input, color: c.textPrimary),
                      textDirection: _isFrancoToArabic ? TextDirection.ltr : TextDirection.rtl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintText: '...',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  ElevatedButton(
                    onPressed: (_translating || _controller.text.trim().isEmpty)
                        ? null
                        : _translate,
                    child: Text(_translating ? '...' : buttonLabel),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // بطاقة الناتج
                  TextPanel(
                    label: outputLabel,
                    trailing: _output.isEmpty
                        ? null
                        : InkWell(
                            onTap: _copyOutput,
                            child: const Icon(Icons.copy_rounded,
                                size: 18, color: AppColors.brandCyan),
                          ),
                    child: _output.isEmpty
                        ? Text(_isFrancoToArabic ? 'الترجمة هتظهر هنا' : 'eltargama hatzhar hena',
                            style: TextStyle(fontSize: AppFontSize.body, color: c.textSecondary))
                                                : Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            alignment: outIsArabic
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: Text(
                              _output,
                              style: TextStyle(
                                  fontSize: AppFontSize.output,
                                  color: c.textPrimary,
                                  height: 1.5),
                              textDirection: outIsArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}