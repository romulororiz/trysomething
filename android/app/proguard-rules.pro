# Play Core (deferred components referenced by Flutter engine)
-dontwarn com.google.android.play.core.**

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# PostHog
-keep class com.posthog.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Gson (used by some SDKs)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
