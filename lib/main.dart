import 'package:flutter/material.dart';
import 'vocab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Franco Translator',
      home: const TokenizerTestScreen(),
    );
  }
}

class TokenizerTestScreen extends StatefulWidget {
  const TokenizerTestScreen({super.key});

  @override
  State<TokenizerTestScreen> createState() => _TokenizerTestScreenState();
}

class _TokenizerTestScreenState extends State<TokenizerTestScreen> {
  String _status = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    _testTokenizer();
  }

  Future<void> _testTokenizer() async {
    try {
      // نحمّل الـ franco vocab
      final francoVocab = await Vocab.fromAsset('assets/franco_vocab.json');

      // نجرّب encode على جملة تجريبية
      const testSentence = 'ezayak ya sa7by';
      final ids = francoVocab.encode(testSentence);

      setState(() {
        _status = 'الجملة: $testSentence\n\n'
            'حجم الـ vocab: ${francoVocab.length}\n'
            'pad=${francoVocab.padId} sos=${francoVocab.sosId} '
            'eos=${francoVocab.eosId} unk=${francoVocab.unkId}\n\n'
            'الأرقام (${ids.length}):\n$ids';
      });
    } catch (e) {
      setState(() => _status = 'فشل: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tokenizer Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_status, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}