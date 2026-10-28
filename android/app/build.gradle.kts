import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ister.glucotrack.glucotrack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ister.glucotrack.glucotrack"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    sourceSets.named("main") {
        res.srcDir(layout.buildDirectory.dir("generated/res/firebase_client"))
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:35.1.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}

// Lee google-services.json local (está en .gitignore) y genera los recursos
// que Firebase.initializeApp() usa en Android. La clave no queda en Git.
// La ruta va como texto: si el archivo no existe (CI), Gradle no lo exige.
val generateFirebaseClientResources =
    tasks.register("generateFirebaseClientResources") {
        val servicesPath = file("google-services.json").absolutePath
        val outputDir = layout.buildDirectory.dir("generated/res/firebase_client")
        outputs.dir(outputDir)
        doLast {
            val valuesDir = outputDir.get().asFile.resolve("values")
            valuesDir.mkdirs()
            val xmlFile = valuesDir.resolve("values.xml")
            val source = File(servicesPath)
            if (!source.exists()) {
                xmlFile.writeText(
                    """<?xml version="1.0" encoding="utf-8"?><resources/>""",
                )
                return@doLast
            }
            fun requireMap(value: Any?, label: String): Map<*, *> {
                if (value is Map<*, *>) return value
                throw GradleException("google-services.json no trae $label")
            }
            fun requireText(value: Any?, label: String): String {
                if (value is String && value.isNotEmpty()) return value
                throw GradleException("google-services.json no trae $label")
            }
            val root = requireMap(
                groovy.json.JsonSlurper().parseText(source.readText()),
                "el objeto raíz",
            )
            val projectInfo = requireMap(root["project_info"], "project_info")
            val clients = root["client"]
            if (clients !is List<*> || clients.isEmpty()) {
                throw GradleException("google-services.json no trae client")
            }
            val client = requireMap(clients.first(), "client")
            val clientInfo = requireMap(client["client_info"], "client_info")
            val apiKeys = client["api_key"]
            if (apiKeys !is List<*> || apiKeys.isEmpty()) {
                throw GradleException("google-services.json no trae api_key")
            }
            val apiKey = requireText(
                requireMap(apiKeys.first(), "api_key")["current_key"],
                "current_key",
            )
            fun xml(value: String) =
                value
                    .replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
            xmlFile.writeText(
                """
                <?xml version="1.0" encoding="utf-8"?>
                <resources>
                    <string name="google_app_id" translatable="false">${xml(requireText(clientInfo["mobilesdk_app_id"], "mobilesdk_app_id"))}</string>
                    <string name="gcm_defaultSenderId" translatable="false">${xml(requireText(projectInfo["project_number"], "project_number"))}</string>
                    <string name="google_api_key" translatable="false">${xml(apiKey)}</string>
                    <string name="google_crash_reporting_api_key" translatable="false">${xml(apiKey)}</string>
                    <string name="google_storage_bucket" translatable="false">${xml(requireText(projectInfo["storage_bucket"], "storage_bucket"))}</string>
                    <string name="project_id" translatable="false">${xml(requireText(projectInfo["project_id"], "project_id"))}</string>
                </resources>
                """.trimIndent(),
            )
        }
    }

tasks.named("preBuild").configure {
    dependsOn(generateFirebaseClientResources)
}