package com.moazreda.franco_translator

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // اسم الجسر بين Kotlin و Dart (لازم يتطابق مع اللي في Dart)
    private val channelName = "franco_translator/process_text"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // نجهّز الجسر، ونحدد إيه اللي يحصل لما Dart يطلب حاجة
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSharedText") {
                    // Dart بيسأل: "فيه نص مُختار مبعوت لنا؟"
                    result.success(getProcessTextFromIntent())
                } else {
                    result.notImplemented()
                }
            }
    }

    // بتقرا النص المُختار من الـ Intent (لو التطبيق اتفتح من "ترجم")
    private fun getProcessTextFromIntent(): String? {
        // بنتأكد إن ده intent بتاع PROCESS_TEXT
        if (intent?.action == Intent.ACTION_PROCESS_TEXT) {
            return intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        }
        return null
    }
}