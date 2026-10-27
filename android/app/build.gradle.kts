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

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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
val generateFirebaseClientResources =
    tasks.register("generateFirebaseClientResources") {
        val jsonFile = layout.projectDirectory.file("google-services.json")
        val outputDir = layout.buildDirectory.dir("generated/res/firebase_client")
        inputs.file(jsonFile).optional()
        outputs.dir(outputDir)
        doLast {
            val valuesDir = outputDir.get().asFile.resolve("values")
            valuesDir.mkdirs()
            val xmlFile = valuesDir.resolve("values.xml")
            val source = jsonFile.asFile
            if (!source.exists()) {
                xmlFile.writeText(
                    """<?xml version="1.0" encoding="utf-8"?><resources/>""",
                )
                return@doLast
            }
            @Suppress("UNCHECKED_CAST")
            val root =
                groovy.json.JsonSlurper().parse(source) as Map<String, Any?>
            val projectInfo = root["project_info"] as Map<String, Any?>
            val client = (root["client"] as List<*>).first() as Map<String, Any?>
            val clientInfo = client["client_info"] as Map<String, Any?>
            val apiKey =
                (
                    (client["api_key"] as List<*>).first() as Map<String, Any?>
                )["current_key"] as String
            fun xml(value: String) =
                value
                    .replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
            xmlFile.writeText(
                """
                <?xml version="1.0" encoding="utf-8"?>
                <resources>
                    <string name="google_app_id" translatable="false">${xml(clientInfo["mobilesdk_app_id"] as String)}</string>
                    <string name="gcm_defaultSenderId" translatable="false">${xml(projectInfo["project_number"] as String)}</string>
                    <string name="google_api_key" translatable="false">${xml(apiKey)}</string>
                    <string name="google_crash_reporting_api_key" translatable="false">${xml(apiKey)}</string>
                    <string name="google_storage_bucket" translatable="false">${xml(projectInfo["storage_bucket"] as String)}</string>
                    <string name="project_id" translatable="false">${xml(projectInfo["project_id"] as String)}</string>
                </resources>
                """.trimIndent(),
            )
        }
    }

tasks.named("preBuild").configure {
    dependsOn(generateFirebaseClientResources)
}