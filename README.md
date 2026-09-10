# Franco → Arabic Translator

A mobile app that transliterates **Egyptian Franco-Arabic** (Arabic written in Latin letters and numbers, e.g. `3ayez` → `عايز`) into Arabic script — running a custom neural model **fully on-device and offline**.

The translation model was trained from scratch. This repo is the Flutter app that deploys it. The model, training pipeline, and evaluation live in a separate repo: **[franco-arabic-translator](https://github.com/MoazReda/franco-arabic-translator)**.

## Demo

`ezayak ya sa7by` → `ازيك يا صاحبي`

## How it works

The app runs the model on the phone with no server and no internet connection:

Franco text
→ tokenizer (Dart) → [sos, ids..., eos] (int64)
→ ONNX Runtime → tokens (greedy decode)
→ detokenizer (Dart) → Arabic text


The greedy decoding loop is baked into the exported ONNX graph, so a full translation is a single inference call from Dart.

## The model

- **Architecture:** character-level seq2seq — bidirectional GRU encoder + Bahdanau attention + GRU decoder (~1.7M parameters)
- **Framework:** trained in PyTorch, exported to ONNX for mobile
- **Performance:** CER 0.207 on a diverse human-written test set
- **Size:** ~7 MB (fp32), bundled directly in the app

## Tech stack

- **Flutter** (Dart) — cross-platform UI, Android-first
- **[flutter_onnxruntime](https://pub.dev/packages/flutter_onnxruntime)** — on-device inference
- **ONNX Runtime** — runs the exported PyTorch model

## Running locally

```bash
git clone git@github.com:MoazReda/franco-translator-app.git
cd franco-translator-app
flutter pub get
flutter run
```

Requires Flutter (3.47+) and an Android device or emulator.

## Roadmap

- [x] On-device franco → Arabic translation
- [ ] Android Process Text action — translate selected text in any app (WhatsApp, Instagram…) without opening the app
- [ ] Translation history, dark mode, alternative translations

## Author

**Moaz Elkhashab** — [GitHub](https://github.com/MoazReda)