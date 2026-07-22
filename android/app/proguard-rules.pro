# Google ML Kit text recognition references optional on-device language models
# (Chinese, Devanagari, Japanese, Korean) that this app does not bundle — it
# only uses the Latin recognizer. Tell R8 not to fail on those absent classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }
