# Guardian Engine ProGuard Rules

# Keep Guardian Engine classes
-keep class com.druvatara.guardian.** { *; }

# Keep Gson serialized classes
-keep class com.druvatara.guardian.policy.** { *; }
-keep class com.druvatara.guardian.usage.** { *; }
-keep class com.druvatara.guardian.app_inventory.** { *; }
-keep class com.druvatara.guardian.app_control.** { *; }
-keep class com.druvatara.guardian.screen_time.** { *; }
-keep class com.druvatara.guardian.schedule.** { *; }
-keep class com.druvatara.guardian.vpn.** { *; }
-keep class com.druvatara.guardian.location.** { *; }
-keep class com.druvatara.guardian.geofence.** { *; }
-keep class com.druvatara.guardian.device_health.** { *; }
-keep class com.druvatara.guardian.event_queue.** { *; }
-keep class com.druvatara.guardian.sync.** { *; }
-keep class com.druvatara.guardian.boot_recovery.** { *; }
-keep class com.druvatara.guardian.tamper_detection.** { *; }
-keep class com.druvatara.guardian.permission.** { *; }
-keep class com.druvatara.guardian.capability.** { *; }
-keep class com.druvatara.guardian.identity.** { *; }

# Keep Kotlin coroutines
-keepclassmembers class kotlinx.coroutines.** { *; }

# Keep OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Okio
-keep class okio.** { *; }
-dontwarn okio.**

# Keep Gson
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Room
-keep class androidx.room.** { *; }
-keepclassmembers class * {
    @androidx.room.* <fields>;
}

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep AndroidX
-keep class androidx.** { *; }

# Keep Coroutines
-keepclassmembers class kotlinx.coroutines.** { *; }
-keepclassmembers interface kotlinx.coroutines.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}