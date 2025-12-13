# Play Core & SplitInstall / Deferred Components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# In-App Review & Update
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.review.** { *; }

# Play Core Tasks
-keep class com.google.android.play.core.tasks.** { *; }

# SplitInstall / Deferred Components
-keep class com.google.android.play.core.splitinstall.** { *; }

# Flutter specific
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }

# Google Play Services base & annotations
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**

# Kotlin metadata
-keepclassmembers class kotlin.Metadata { *; }

# Optional: Keep all public classes
-keep class * { public *; }

# Apache Commons Imaging - Ignore missing Java AWT classes (not available on Android)
-dontwarn java.awt.**
-dontwarn javax.imageio.**
-dontwarn org.apache.commons.imaging.**