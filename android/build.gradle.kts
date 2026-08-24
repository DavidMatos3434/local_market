allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            
            // 1. Fix Namespace (o erro anterior)
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(android)
                if (namespace == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, "dev.isar.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) {}

            // 2. Fix compileSdk
            // Forçamos o SDK 36 para todos os plugins que estejam abaixo disso (Android 16)
            try {
                val getCompileSdk = android.javaClass.getMethod("getCompileSdk")
                val currentSdk = getCompileSdk.invoke(android) as? Int
                if (currentSdk == null || currentSdk < 36) {
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    setCompileSdk.invoke(android, 36)
                }
            } catch (e: Exception) {
                try {
                    val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    setCompileSdkVersion.invoke(android, 36)
                } catch (e2: Exception) {}
            }

            // 3. Fix minSdk
            // O Flutter e algumas libs exigem pelo menos SDK 23.
            try {
                val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                val getMinSdk = defaultConfig.javaClass.getMethod("getMinSdk")
                val currentMinSdk = getMinSdk.invoke(defaultConfig) as? Int
                if (currentMinSdk == null || currentMinSdk < 23) {
                    val setMinSdk = defaultConfig.javaClass.getMethod("setMinSdk", Int::class.javaPrimitiveType)
                    setMinSdk.invoke(defaultConfig, 23)
                }
            } catch (e: Exception) {
                // Fallback para versões mais antigas do AGP
                try {
                    val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                    val setMinSdkVersion = defaultConfig.javaClass.getMethod("setMinSdkVersion", Int::class.javaPrimitiveType)
                    setMinSdkVersion.invoke(defaultConfig, 23)
                } catch (e3: Exception) {}
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
