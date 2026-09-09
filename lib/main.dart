import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Franco Translator',
      home: const AssetTestScreen(),
    );
  }
}

/// شاشة مؤقتة: بتقرا config.json من الـ assets وتعرض محتواه،
/// عشان نتأكد إن الموديل والـ vocabs موصولين صح بالـ app.
class AssetTestScreen extends StatefulWidget {
  const AssetTestScreen({super.key});

  @override
  State<AssetTestScreen> createState() => _AssetTestScreenState();
}

class _AssetTestScreenState extends State<AssetTestScreen> {
  String _status = 'جاري القراءة...';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// بتحمّل محتوى config.json من حقيبة الـ assets
  Future<void> _loadConfig() async {
    try {
      final content = await rootBundle.loadString('assets/config.json');
      setState(() => _status = 'نجح! المحتوى:\n$content');
    } catch (e) {
      setState(() => _status = 'فشل: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_status, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}