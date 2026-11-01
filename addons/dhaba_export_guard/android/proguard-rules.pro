# Dhaba Rush: R8 keep rules for the Gradle RELEASE build (build optimisation,
# docs/optimise/report.md). Debug builds are not minified.
#
# The export guard (addons/dhaba_export_guard/plugin.gd) copies this file to
# android/build/proguard-rules.pro and switches R8 on in
# android/build/build.gradle (release buildType) whenever an Android Gradle
# export starts, so it survives a reinstall of the Android build template.
# To build a release WITHOUT R8: put  dhaba_minify=false  in
# android/build/gradle.properties.
#
# Measured on the 0.3.5 release export: dex 21.4 MB raw -> 5.5 MB raw,
# APK -5.8 MB, Play download -5.6 MB. Must pass a full ads / consent /
# purchase / analytics check on a phone before the first R8 release.

# Godot's Java side is reached from libgodot_android.so through JNI and from
# plugin meta-data through reflection: keep it whole (about 0.2 MB of dex).
# Also covers the Play Billing plugin (org.godotengine.plugin.googleplaybilling).
-keep class org.godotengine.** { *; }
-keep class * extends org.godotengine.godot.plugin.GodotPlugin { *; }
-keepclassmembers class * {
    @org.godotengine.godot.plugin.UsedByGodot *;
}

# GameAnalytics: libGodotGameAnalytics.so calls com/gameanalytics/sdk/GameAnalytics
# and NativeFpsTracker through JNI, which R8 cannot see.
-keep class com.gameanalytics.** { *; }

# Poing AdMob plugin (its AAR ships the same rule).
-keep class com.poingstudios.** { *; }

# JNI entry points everywhere; readable stack traces (upload the mapping
# file to Play: the AAB carries it).
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable
