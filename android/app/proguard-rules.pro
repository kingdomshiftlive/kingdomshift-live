# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/kartikghosh/flutter/packages/flutter_tools/gradle/flutter_proguard_rules.pro
# as well as the default rules.

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Services & Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# For mediation (if used)
-keep class com.google.android.gms.ads.mediation.** { *; }
-keep class com.google.android.gms.ads.reward.** { *; }
-keep class com.google.android.gms.ads.admanager.** { *; }
