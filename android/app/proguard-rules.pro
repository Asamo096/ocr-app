# Add project specific ProGuard rules here.
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.view.View

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep OCR related classes
-keep class com.ocr.app.** { *; }
-keep class com.benjaminwan.ocrlibrary.** { *; }

# Keep ONNX models
-keep class ai.onnxruntime.** { *; }

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep data classes
-keep class com.benjaminwan.ocrlibrary.OcrResult { *; }
-keep class com.benjaminwan.ocrlibrary.TextBlock { *; }
-keep class com.benjaminwan.ocrlibrary.Point { *; }
