# Proguard rules for User App.

# Flutter wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Descope Auth SDK classes intact
-keep class com.descope.** { *; }

# Keep Firebase / Google Play services classes intact
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Ignore missing Play Core warnings since we don't use deferred components
-dontwarn com.google.android.play.core.**
