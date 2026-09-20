# Google Mobile Ads (AdMob) + WorkManager
-keep class com.google.android.gms.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn com.google.android.gms.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# ONNX Runtime
-keep class ai.onnxruntime.** { *; }
-keep class com.google.ai.** { *; }
-dontwarn ai.onnxruntime.**