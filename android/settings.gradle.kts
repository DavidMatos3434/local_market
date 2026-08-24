// Hack: Clear conflicting environment variables via reflection
try {
    val env = System.getenv()
    val field = env.javaClass.getDeclaredField("m")
    field.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    val m = field.get(env) as MutableMap<String, String>
    m.remove("ANDROID_PREFS_ROOT")
} catch (e: Exception) {
    try {
        val processEnvironment = Class.forName("java.lang.ProcessEnvironment")
        val field = processEnvironment.getDeclaredField("theCaseInsensitiveEnvironment")
        field.isAccessible = true
        @Suppress("UNCHECKED_CAST")
        val m = field.get(null) as MutableMap<String, String>
        m.remove("ANDROID_PREFS_ROOT")
    } catch (e2: Exception) {}
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
}

include(":app")
