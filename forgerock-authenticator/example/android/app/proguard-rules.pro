# ===================================
# Keep attributes for debugging and proper functionality
# ===================================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile
-keepattributes LineNumberTable
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ===================================
# Gson - JSON Serialization (CRITICAL)
# ===================================
# Keep Gson TypeToken classes (fixes the TypeToken crash)
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Keep generic signature of TypeToken (solves the TypeToken issue)
-keep class com.google.gson.internal.$Gson$Types { *; }
-keep class com.google.gson.internal.** { *; }

# Gson specific classes
-dontwarn sun.misc.**
-keep class sun.misc.Unsafe { *; }

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses with members
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Keep generic type parameters for Gson
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep all classes that might be used with Gson reflection
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
}

# ===================================
# ForgeRock SDK (CRITICAL)
# ===================================
# Keep all ForgeRock classes and their generic signatures
-keep class org.forgerock.** { *; }
-keep interface org.forgerock.** { *; }

# Keep all model classes that might be serialized/deserialized
-keepclassmembers class org.forgerock.** {
    <fields>;
    <methods>;
}

# ===================================
# OkHttp3 - HTTP Client
# ===================================
# JSR 305 annotations are for embedding nullability information.
-dontwarn javax.annotation.**

# A resource is loaded with a relative path so the package of this class must be preserved.
-adaptresourcefilenames okhttp3/internal/publicsuffix/PublicSuffixDatabase.gz

# Animal Sniffer compileOnly dependency to ensure APIs are compatible with older versions of Java.
-dontwarn org.codehaus.mojo.animal_sniffer.*

# OkHttp platform used only on JVM and when Conscrypt and other security providers are available.
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep OkHttp classes
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Okio classes (OkHttp dependency)
-keep class okio.** { *; }
-dontwarn okio.**

# ===================================
# Nimbus JOSE+JWT - JWT/JWE Processing
# ===================================
# Keep Nimbus classes for JWT handling
-keep class com.nimbusds.** { *; }
-keep interface com.nimbusds.** { *; }
-dontwarn com.nimbusds.**

# Keep JWT and JWE classes
-keepclassmembers class com.nimbusds.jose.** { *; }
-keepclassmembers class com.nimbusds.jwt.** { *; }

# Keep cryptography providers
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
-keep class javax.crypto.** { *; }

# ===================================
# Kotlin and Coroutines
# ===================================
# Keep Kotlin metadata
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Kotlinx Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-keepclassmembers class kotlin.coroutines.SafeContinuation {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# ===================================
# AndroidX and Support Libraries
# ===================================
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Keep AndroidX Biometric classes (if used)
-keep class androidx.biometric.** { *; }

# ===================================
# Firebase and Google Play Services
# ===================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Firebase Messaging classes
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ===================================
# Flutter
# ===================================
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# ===================================
# Android Components
# ===================================
# Keep broadcast receivers
-keep public class * extends android.content.BroadcastReceiver
-keep class org.forgerock.android.auth.FRAMessagingReceiver { *; }

# Keep services
-keep public class * extends android.app.Service
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}